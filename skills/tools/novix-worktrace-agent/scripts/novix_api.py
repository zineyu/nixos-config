#!/usr/bin/env python3
"""Small helper for NovixWorkTrace agent collaboration access.

The helper is limited to test feedback, requirements, tasks, and evidence
submission routes exposed by the scoped Agent OpenAPI.
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
import mimetypes
import os
from pathlib import Path
import re
import sys
from urllib.error import HTTPError
from urllib.parse import urlencode, urljoin, urlparse
from urllib.request import HTTPRedirectHandler, Request, build_opener


DEFAULT_CREDENTIALS = Path(__file__).resolve().parents[1] / "credentials" / "novix-credentials.json"
SUPPORTED_OPERATION_PATTERNS = tuple(
    (methods, re.compile(pattern))
    for methods, pattern in [
        ({"GET"}, r"^/api/auth/me$"),
        ({"GET"}, r"^/api/agent-skill/(openapi|capabilities)$"),
        ({"POST"}, r"^/api/agent-skill/credentials/renew$"),
        ({"GET"}, r"^/api/work-trace/timeline$"),
        ({"POST"}, r"^/api/uploads/(images|files)$"),
        ({"GET"}, r"^/api/uploads/.+$"),
        ({"GET", "POST", "DELETE"}, r"^/api/test-feedback$"),
        ({"GET"}, r"^/api/test-feedback/waiting$"),
        ({"GET", "PATCH", "DELETE"}, r"^/api/test-feedback/[^/]+$"),
        ({"PATCH"}, r"^/api/test-feedback/[^/]+/(review|resubmit|close)$"),
        ({"POST"}, r"^/api/test-feedback/[^/]+/publish-to-plaza$"),
        ({"GET", "POST"}, r"^/api/requirements$"),
        ({"GET", "PATCH"}, r"^/api/requirements/[^/]+$"),
        ({"POST"}, r"^/api/requirements/[^/]+/(comments|accept|void)$"),
        ({"PATCH"}, r"^/api/requirements/[^/]+/comments/[^/]+$"),
        ({"GET"}, r"^/api/requirements/[^/]+/github-issue-comments$"),
        ({"GET", "POST"}, r"^/api/requirements/[^/]+/task-links$"),
        ({"DELETE"}, r"^/api/requirements/[^/]+/task-links/[^/]+$"),
        ({"GET", "POST"}, r"^/api/tasks$"),
        ({"GET"}, r"^/api/tasks/my$"),
        ({"GET"}, r"^/api/tasks/(acceptance-reviewers|assignable-employees)$"),
        ({"GET", "PATCH"}, r"^/api/tasks/[^/]+$"),
        ({"GET"}, r"^/api/tasks/[^/]+/actions$"),
        ({"POST"}, r"^/api/tasks/[^/]+/actions/[^/]+$"),
        ({"GET"}, r"^/api/workflow-tasks/support-data$"),
        ({"GET", "POST"}, r"^/api/tasks/[^/]+/relationships$"),
        ({"DELETE"}, r"^/api/tasks/[^/]+/relationships/[^/]+$"),
        ({"POST"}, r"^/api/tasks/[^/]+/(assign|claim|assignment-reject|start|complete|accept|reopen|void|handoff-request|handoff-accept|handoff-reject|return-to-plaza)$"),
        ({"GET"}, r"^/api/tasks/[^/]+/(events|delivery-evidence|evidence)$"),
        ({"GET"}, r"^/api/tasks/[^/]+/(github-issue-comments|pull-request-candidates)$"),
        ({"GET", "POST"}, r"^/api/tasks/[^/]+/pull-requests$"),
        ({"POST"}, r"^/api/tasks/[^/]+/(comments|evidence-comments)$"),
        ({"PATCH", "DELETE"}, r"^/api/tasks/[^/]+/comments/[^/]+$"),
        ({"POST"}, r"^/api/tasks/[^/]+/evidence/refresh$"),
        ({"PATCH", "DELETE"}, r"^/api/tasks/[^/]+/evidence/[^/]+/comment$"),
        ({"POST"}, r"^/api/tasks/[^/]+/evidence/[^/]+/(accept|accept-task|exclude|restore)$"),
        ({"POST"}, r"^/api/workflow-tasks/[^/]+/evidence$"),
    ]
)
UNSUPPORTED_MESSAGE = "该 skill 不支持此类操作，请在 NovixWorkTrace 网页或管理功能中处理。"


def load_credentials() -> dict:
    path = Path(os.environ.get("NOVIX_CREDENTIALS_FILE", DEFAULT_CREDENTIALS))
    with path.open("r", encoding="utf-8") as handle:
        credentials = json.load(handle)
    warn_if_expiring(credentials)
    return credentials


def warn_if_expiring(credentials: dict) -> None:
    auth = credentials.get("auth") or {}
    if not auth.get("enabled") or auth.get("is_permanent"):
        return
    expires_at = auth.get("expires_at")
    if not expires_at:
        return
    expires = datetime.fromisoformat(expires_at)
    if expires.tzinfo is None:
        expires = expires.replace(tzinfo=timezone.utc)
    remaining = expires - datetime.now(timezone.utc)
    if remaining.total_seconds() <= 0:
        raise SystemExit("Agent 凭证已过期或被撤销。请到 管理 -> 基础配置 -> Agent Skill 下载 -> 只更新凭证，替换 credentials/novix-credentials.json。")
    if remaining.days < 2:
        print("Agent 凭证将在 2 天内过期。请先询问用户是否续证；同意后运行 python scripts/novix_api.py renew --days 30。", file=sys.stderr)


def api_url(credentials: dict, path: str, query: dict[str, str] | None = None) -> str:
    base_url = credentials["site"]["base_url"].rstrip("/") + "/"
    url = urljoin(base_url, path.lstrip("/"))
    if query:
        separator = "&" if "?" in url else "?"
        url = f"{url}{separator}{urlencode(query)}"
    parsed = urlparse(url)
    if parsed.scheme != "https" and not (
        parsed.scheme == "http" and parsed.hostname in {"localhost", "127.0.0.1", "::1"}
    ):
        raise SystemExit(
            "Agent Skill 拒绝通过非 HTTPS 地址发送凭证。"
            "请将 site.base_url 改为正式站点的 HTTPS 地址，并从站点重新下载凭证。"
        )
    return url


class RejectRedirectHandler(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        raise HTTPError(req.full_url, code, msg, headers, fp)


def request_json(
    credentials: dict,
    method: str,
    path: str,
    payload: object | None = None,
    query: dict[str, str] | None = None,
    content: bytes | None = None,
    content_type: str | None = None,
) -> object:
    ensure_supported_operation(method, path)
    headers = {"Accept": "application/json"}
    body = None
    if content is not None:
        body = content
        headers["Content-Type"] = content_type or "application/octet-stream"
    elif payload is not None:
        body = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"
    auth = credentials.get("auth") or {}
    if auth.get("enabled") and auth.get("cookie_name") and auth.get("session_token"):
        headers["Cookie"] = f"{auth['cookie_name']}={auth['session_token']}"
    request = Request(api_url(credentials, path, query), data=body, headers=headers, method=method.upper())
    try:
        with build_opener(RejectRedirectHandler()).open(request, timeout=30) as response:
            text = response.read().decode("utf-8")
            content_type = response.headers.get("content-type", "")
    except HTTPError as error:
        text = error.read().decode("utf-8", errors="replace")
        if error.code in {301, 302, 303, 307, 308}:
            raise SystemExit(
                "请求发生重定向，已停止自动跟随，避免请求被改写或凭证被发送到其他地址。"
                "请核对凭证 site.base_url 是否为站点最终地址（正式站点应使用 HTTPS），"
                "或从站点重新下载凭证后重试。"
            ) from error
        if error.code == 401:
            raise SystemExit("Agent 凭证已过期或被撤销。请到 管理 -> 基础配置 -> Agent Skill 下载 -> 只更新凭证，替换 credentials/novix-credentials.json。") from error
        raise SystemExit(f"{method.upper()} {path} failed with HTTP {error.code}: {text}") from error
    if not text:
        return None
    if "json" not in content_type.lower():
        return text
    return json.loads(text)


def ensure_supported_operation(method: str, path_or_url: str) -> None:
    normalized_method = method.upper()
    parsed_path = urlparse(path_or_url).path or path_or_url
    normalized = parsed_path if parsed_path.startswith("/") else f"/{parsed_path}"
    if any(normalized_method in methods and pattern.fullmatch(normalized) for methods, pattern in SUPPORTED_OPERATION_PATTERNS):
        return
    raise SystemExit(UNSUPPORTED_MESSAGE)


def renew_credentials(credentials: dict, days: int, output_path: Path, revoke_current: bool = True) -> None:
    payload = {"expires_in_days": days, "revoke_current": revoke_current}
    renewed = request_json(credentials, "POST", "/api/agent-skill/credentials/renew", payload)
    output_path.write_text(json.dumps(renewed, ensure_ascii=False, indent=2), encoding="utf-8")
    expires_at = (renewed.get("auth") or {}).get("expires_at") if isinstance(renewed, dict) else None
    print(f"Agent credentials renewed. Wrote {output_path}. Expires at: {expires_at or 'permanent'}")


def fetch_openapi(credentials: dict) -> dict:
    docs = credentials.get("docs") or {}
    path = docs.get("openapi_url") or "/api/agent-skill/openapi"
    return request_json(credentials, "GET", path)


def fetch_capabilities(credentials: dict) -> dict:
    docs = credentials.get("docs") or {}
    path = docs.get("capabilities_url") or "/api/agent-skill/capabilities"
    return request_json(credentials, "GET", path)


def print_docs(credentials: dict) -> None:
    docs = credentials["docs"]
    print(f"Scoped OpenAPI JSON: {docs['openapi_url']}")
    print(f"Scoped Swagger UI:   {docs['swagger_url']}")
    print(f"Scoped ReDoc:        {docs['redoc_url']}")
    print(f"Capabilities:        {docs['capabilities_url']}")


def print_summary(credentials: dict, tag_filter: str | None = None, search: str | None = None) -> None:
    spec = fetch_openapi(credentials)
    operations = []
    normalized_tag = tag_filter.lower() if tag_filter else None
    normalized_search = search.lower() if search else None
    for path, methods in sorted((spec.get("paths") or {}).items()):
        for method, operation in sorted(methods.items()):
            if method.lower() not in {"get", "post", "put", "patch", "delete"}:
                continue
            tags = ",".join(operation.get("tags") or [])
            operation_id = operation.get("operationId", "")
            summary = operation.get("summary", "")
            haystack = f"{tags} {method} {path} {operation_id} {summary}".lower()
            if normalized_tag and normalized_tag not in tags.lower():
                continue
            if normalized_search and normalized_search not in haystack:
                continue
            operations.append((tags, method.upper(), path, operation_id, summary))
    for tags, method, path, operation_id, summary in operations:
        print(f"{method:6} {path:56} {operation_id:36} {tags} {summary}")


def parse_query(values: list[str] | None) -> dict[str, str]:
    query: dict[str, str] = {}
    for value in values or []:
        if "=" not in value:
            raise SystemExit(f"--query must use KEY=VALUE format, got: {value}")
        key, item = value.split("=", 1)
        if not key:
            raise SystemExit(f"--query key cannot be empty: {value}")
        query[key] = item
    return query


def print_result(result: object, output_path: str | None = None) -> None:
    text = result if isinstance(result, str) else json.dumps(result, ensure_ascii=False, indent=2)
    if output_path:
        Path(output_path).write_text(text, encoding="utf-8")
        print(f"Wrote {output_path}")
        return
    print(text)


def main() -> None:
    parser = argparse.ArgumentParser(description="NovixWorkTrace OpenAPI discovery and authenticated request helper.")
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("docs")
    subparsers.add_parser("capabilities")
    openapi_parser = subparsers.add_parser("openapi")
    openapi_parser.add_argument("--save")
    summary_parser = subparsers.add_parser("summary")
    summary_parser.add_argument("--tag")
    summary_parser.add_argument("--search")
    renew_parser = subparsers.add_parser("renew")
    renew_parser.add_argument("--days", type=int, default=30, choices=[1, 7, 30, 90])
    renew_parser.add_argument("--output", default=str(DEFAULT_CREDENTIALS))
    renew_parser.add_argument("--keep-current", action="store_true")
    request_parser = subparsers.add_parser("request")
    request_parser.add_argument("method")
    request_parser.add_argument("path")
    payload_group = request_parser.add_mutually_exclusive_group()
    payload_group.add_argument("--json", dest="json_file")
    payload_group.add_argument("--file", dest="file_path")
    request_parser.add_argument("--content-type")
    request_parser.add_argument("--query", action="append")
    request_parser.add_argument("--output")
    args = parser.parse_args()

    if args.command == "request" and args.content_type and not args.file_path:
        request_parser.error("--content-type requires --file")

    credentials = load_credentials()
    if args.command == "docs":
        print_docs(credentials)
        return
    if args.command == "summary":
        print_summary(credentials, tag_filter=args.tag, search=args.search)
        return
    if args.command == "capabilities":
        print(json.dumps(fetch_capabilities(credentials), ensure_ascii=False, indent=2))
        return
    if args.command == "renew":
        renew_credentials(credentials, args.days, Path(args.output), revoke_current=not args.keep_current)
        return
    if args.command == "openapi":
        spec = fetch_openapi(credentials)
        text = json.dumps(spec, ensure_ascii=False, indent=2)
        if args.save:
            Path(args.save).write_text(text, encoding="utf-8")
        else:
            print(text)
        return
    if args.command == "request":
        payload = None
        content = None
        content_type = None
        if args.json_file:
            payload = json.loads(Path(args.json_file).read_text(encoding="utf-8"))
        elif args.file_path:
            upload_path = Path(args.file_path)
            content = upload_path.read_bytes()
            content_type = args.content_type or mimetypes.guess_type(upload_path.name)[0] or "application/octet-stream"
        result = request_json(
            credentials,
            args.method,
            args.path,
            payload,
            parse_query(args.query),
            content,
            content_type,
        )
        if result is not None:
            print_result(result, args.output)
        return
    parser.print_help()
    sys.exit(2)


if __name__ == "__main__":
    main()
