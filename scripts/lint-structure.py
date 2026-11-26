#!/usr/bin/env python3
"""结构 lint：把 ADR-0018 的差异表达约定变成 CI 门禁。

与 nixfmt / deadnix / statix 的分工：那三个管语法与死代码，这个管**结构**——
每条规则对应的都是"差异被写到了错误的轴上"的具体失误。

  R1  模块不得按主机名分支（host.name / hostname ==），一律走 host.hasTag /
      host.platform / host.form / host.profile / host.facts。
  R2  imports 不得引用 host metadata：门控写在模块体内，imports 保持无条件，
      这样每台主机都会求值每个模块，轴谓词的拼写错误在四台机上同时暴露。
  R3  Machine File（hosts/*/home.nix）只允许 zine.* 赋值。上游 option 路径与
      home.packages 是漂移的发源地：机器差异必须落在有类型、有默认值的 knob 上。
  R4  每个非 readOnly 的 mkOption 必须声明 default —— knob 必须有默认值，
      否则设备文件就成了唯一取值处，差异表达退化。
  R5  Host Inventory 的每个 host 必须有 platform / form / profile 与 facts.gpu。

用法：python3 scripts/lint-structure.py [--quiet]
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

violations: list[str] = []


def fail(path: Path, line: int, rule: str, message: str) -> None:
    rel = path.relative_to(ROOT)
    violations.append(f"{rel}:{line}: [{rule}] {message}")


def strip_comment(line: str) -> str:
    """去掉 Nix 行注释，保留字符串内的 #。"""
    out: list[str] = []
    in_string = False
    escaped = False
    for char in line:
        if escaped:
            escaped = False
            out.append(char)
            continue
        if char == "\\" and in_string:
            escaped = True
            out.append(char)
            continue
        if char == '"':
            in_string = not in_string
        elif char == "#" and not in_string:
            break
        out.append(char)
    return "".join(out)


def nix_files(*trees: str) -> list[Path]:
    files: list[Path] = []
    for tree in trees:
        files.extend(sorted((ROOT / tree).rglob("*.nix")))
    return [path for path in files if ".devenv" not in path.parts]


def code_lines(path: Path) -> list[tuple[int, str]]:
    return [
        (number, strip_comment(text))
        for number, text in enumerate(path.read_text(encoding="utf-8").splitlines(), 1)
    ]


def check_hostname_branches() -> None:
    """R1：模块里不得出现按主机名分支。"""
    for path in nix_files("modules", "programs"):
        for number, text in code_lines(path):
            if re.search(r"\bhost\.name\b", text) or re.search(r"\bhostname\s*[!=]=", text):
                fail(
                    path,
                    number,
                    "R1",
                    "模块按主机名分支；差异应写成 host.hasTag \"<tag>\"（缺席）、host.{platform,form,profile}（轴）或 zine.* knob（程度）",
                )


def check_imports_are_unconditional() -> None:
    """R2：imports 列表不得引用 host metadata。"""
    for path in nix_files("modules", "programs"):
        raw = path.read_text(encoding="utf-8")
        if "lint-allow-imports-gate" in raw:
            # 树入口整棵门控的显式豁免：文件内必须写明理由（ADR-0018）。
            continue
        text = "\n".join(strip_comment(line) for line in raw.splitlines())
        for match in re.finditer(r"\bimports\s*=", text):
            start = match.end()
            depth = 0
            end = start
            while end < len(text):
                char = text[end]
                if char in "[({":
                    depth += 1
                elif char in "])}":
                    depth -= 1
                elif char == ";" and depth == 0:
                    break
                end += 1
            body = text[start:end]
            if re.search(r"\bhost\.(hasTag|platform|form|profile|facts|name)\b", body):
                line = text.count("\n", 0, match.start()) + 1
                fail(
                    path,
                    line,
                    "R2",
                    "imports 引用了 host metadata；把门控移进模块体（config = lib.mkIf …）",
                )


def check_machine_files() -> None:
    """R3：hosts/*/home.nix 只允许 zine.* 赋值。"""
    for path in sorted((ROOT / "hosts").glob("*/home.nix")):
        depth = 0
        in_string = False
        escaped = False
        pending: list[str] = []
        for number, text in code_lines(path):
            pending = []
            for char in text:
                if escaped:
                    escaped = False
                elif char == "\\" and in_string:
                    escaped = True
                elif char == '"':
                    in_string = not in_string
                elif not in_string and char == "{":
                    depth += 1
                elif not in_string and char == "}":
                    depth -= 1
                elif not in_string and char == "=" and depth == 1:
                    key = "".join(pending).strip()
                    pending = []
                    if key and not key.startswith("zine."):
                        fail(
                            path,
                            number,
                            "R3",
                            f"Machine File 写了 `{key}`；只允许 zine.* knob（软件归属看 host 的标签，参数走 knob）",
                        )
                    continue
                if not in_string and char in ";" and depth == 1:
                    pending = []
                    continue
                if depth == 1 and (char.isalnum() or char in "._-\"'"):
                    pending.append(char)
                elif depth == 1 and char in " \t\n:":
                    continue


def check_option_defaults() -> None:
    """R4：非 readOnly 的 mkOption 必须有 default。"""
    for path in nix_files("modules", "programs"):
        text = "\n".join(strip_comment(line) for line in path.read_text(encoding="utf-8").splitlines())
        blocks = []
        for match in re.finditer(r"\bmkOption\s*\{", text):
            start = text.index("{", match.start())
            depth = 0
            end = start
            while end < len(text):
                if text[end] == "{":
                    depth += 1
                elif text[end] == "}":
                    depth -= 1
                    if depth == 0:
                        break
                end += 1
            body = text[start : end + 1]
            blocks.append((match.start(), start, end, bool(re.search(r"\breadOnly\s*=\s*true\b", body)), body))
        read_only_spans = [(start, end) for _, start, end, read_only, _ in blocks if read_only]
        for offset, start, end, read_only, body in blocks:
            if read_only:
                continue
            # 只读投影里的子选项由 config 赋值，不需要 default。
            if any(start > ro_start and end < ro_end for ro_start, ro_end in read_only_spans):
                continue
            if not re.search(r"\bdefault(Text)?\s*=", body):
                line = text.count("\n", 0, offset) + 1
                fail(path, line, "R4", "mkOption 没有 default；knob 必须有默认值")


def check_inventory_facts() -> None:
    """R5：每个 host 必须有 platform / form / profile 与 facts.gpu。"""
    path = ROOT / "inventory.nix"
    text = "\n".join(strip_comment(line) for line in path.read_text(encoding="utf-8").splitlines())
    for match in re.finditer(r"^  ([a-z][\w-]*)\s*=\s*\{", text, re.MULTILINE):
        name = match.group(1)
        start = text.index("{", match.start())
        depth = 0
        end = start
        while end < len(text):
            if text[end] == "{":
                depth += 1
            elif text[end] == "}":
                depth -= 1
                if depth == 0:
                    break
            end += 1
        body = text[start : end + 1]
        line = text.count("\n", 0, match.start()) + 1
        if not re.search(r"\bplatform\s*=", body):
            fail(path, line, "R5", f"host `{name}` 缺少 platform")
        if not re.search(r"\bform\s*=", body):
            fail(path, line, "R5", f"host `{name}` 缺少 form")
        if not re.search(r"\bprofile\s*=", body):
            fail(path, line, "R5", f"host `{name}` 缺少 profile")
        if not re.search(r"\bgpu\s*[.=]", body):
            fail(path, line, "R5", f"host `{name}` 缺少 facts.gpu")


def main() -> int:
    check_hostname_branches()
    check_imports_are_unconditional()
    check_machine_files()
    check_option_defaults()
    check_inventory_facts()

    if violations:
        print("结构 lint 失败：\n")
        for violation in violations:
            print(f"  {violation}")
        print(f"\n共 {len(violations)} 处。规则说明见 docs/adr/0018-differences-have-axes.md")
        return 1

    if "--quiet" not in sys.argv:
        print("结构 lint 通过：R1–R5 全部满足。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
