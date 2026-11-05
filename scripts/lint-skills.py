#!/usr/bin/env python3
"""Lint every skill under skills/.

A skill is ``skills/<category>/<name>/SKILL.md``. The layout rules (one
directory per category, one SKILL.md per skill, unique names) live in
modules/base/agent-skills/default.nix as Nix assertions. This script covers
what an assertion cannot read cheaply: the content of the frontmatter and the
links between skills.

Errors block the run:

  - the skill directory has no SKILL.md
  - SKILL.md does not open with ``---``, or its frontmatter is not closed
  - frontmatter has no ``name`` or no ``description``
  - ``name`` differs from the directory name
  - a directory name or a skill name is not lowercase-kebab-case
  - a description reaches past the 1024-character specification limit
  - a model-invoked skill's description carries no positive trigger phrase

Warnings report drift that needs a judgement call:

  - a relative link points at a file that does not exist
  - SKILL.md exceeds the line budget
  - frontmatter uses a top-level key outside the Agent Skills specification

Usage:
  scripts/lint-skills.py [--root skills] [--max-lines N]

Exit codes: 0 = no errors, 1 = one or more errors.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

KEBAB = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")

# Top-level keys the Agent Skills specification defines.
SPEC_KEYS = {
    "name",
    "description",
    "license",
    "compatibility",
    "metadata",
    "allowed-tools",
    # Pi documents this field as part of the specification it implements.
    "disable-model-invocation",
}

# Keys hosts commonly accept beyond the specification. They are not errors,
# but a published skill carrying one can fail packaging on a strict client, so
# they are reported.
EXTRA_KEYS = {"argument-hint", "paths"}

# A description must state when the skill applies. The canonical form is
# "Use when ..."; "Use before/after/during ..." carries the same meaning, and
# the passive "should be used when ..." is common in upstream skills.
TRIGGER = re.compile(
    r"\buse(d)? (this )?when\b|\buse(d)? (this )?(before|after|during)\b",
    re.IGNORECASE,
)

# A negated clause describes an exclusion, not a trigger. Strip every negated
# clause before testing for a positive one; stripping only the first would let a
# description built entirely from exclusions pass on its leftovers.
NEGATED = re.compile(
    r"\b(do not|don't|never) use(d)? (this )?(when|before|after|during)\b[^.;]*",
    re.IGNORECASE,
)

# Markdown link target: [text](target) or [text](target "title").
LINK = re.compile(r"\[[^\]]*\]\(\s*([^)\s]+)")

EXTERNAL_PREFIXES = ("http://", "https://", "mailto:", "#")

MAX_DESCRIPTION = 1024


class Report:
    def __init__(self) -> None:
        self.errors = 0
        self.warnings = 0
        self.lines: list[str] = []

    def error(self, label: str, message: str) -> None:
        self.errors += 1
        self.lines.append(f"  ✗  {label}\n       ERROR: {message}")

    def warn(self, label: str, message: str) -> None:
        self.warnings += 1
        self.lines.append(f"  ⚠  {label}\n       WARN:  {message}")

    def ok(self, label: str) -> None:
        self.lines.append(f"  ✓  {label}")


def split_frontmatter(text: str) -> tuple[list[str] | None, str | None]:
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None, "first line must be '---' to open the frontmatter"
    for index in range(1, len(lines)):
        if lines[index].strip() == "---":
            return lines[1:index], None
    return None, "frontmatter is never closed by a '---' line"


def parse_frontmatter(block: list[str]) -> dict[str, str]:
    """Return top-level keys. Nested maps are skipped; block scalars are folded."""
    data: dict[str, str] = {}
    key: str | None = None
    folded: list[str] | None = None

    for line in block:
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        match = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line) if not line[:1].isspace() else None
        if match:
            if key is not None and folded is not None:
                data[key] = " ".join(folded).strip()
            key, raw = match.group(1), match.group(2).strip()
            if raw in ("|", ">", "|-", ">-", "|+", ">+"):
                folded = []
                data[key] = ""
            else:
                folded = None
                data[key] = unquote(raw)
        elif key is not None and folded is not None:
            folded.append(line.strip())

    if key is not None and folded is not None:
        data[key] = " ".join(folded).strip()
    return data


def unquote(value: str) -> str:
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "'\"":
        return value[1:-1]
    return value


def has_trigger(description: str) -> bool:
    return bool(TRIGGER.search(NEGATED.sub(" ", description)))


def check_links(skill_file: Path, report: Report, label: str) -> None:
    text = skill_file.read_text(encoding="utf-8")
    skill_dir = skill_file.parent
    seen: set[str] = set()
    for target in LINK.findall(text):
        if target.startswith(EXTERNAL_PREFIXES) or target in seen:
            continue
        seen.add(target)
        path = target.split("#", 1)[0]
        # A bare word such as `[title](link)` is a template placeholder, not a
        # path. Every real cross-file link carries a directory or an extension.
        if not path or ("/" not in path and not path.endswith(".md")):
            continue
        resolved = (skill_dir / path).resolve()
        if not resolved.exists():
            report.warn(label, f"link target does not exist: {target}")


def lint_skill(skill_dir: Path, report: Report, max_lines: int) -> int:
    label = f"{skill_dir.parent.name}/{skill_dir.name}"
    before = report.errors + report.warnings
    skill_file = skill_dir / "SKILL.md"
    if not skill_file.is_file():
        report.error(label, "no SKILL.md in the skill directory")
        return report.errors + report.warnings - before

    if not KEBAB.match(skill_dir.name):
        report.error(label, f"directory name '{skill_dir.name}' is not lowercase-kebab-case")

    text = skill_file.read_text(encoding="utf-8")
    block, problem = split_frontmatter(text)
    if block is None:
        report.error(label, problem or "frontmatter is unreadable")
        return report.errors + report.warnings - before

    fm = parse_frontmatter(block)
    name = fm.get("name", "")
    description = fm.get("description", "")

    if not name:
        report.error(label, "frontmatter has no 'name'")
    else:
        if not KEBAB.match(name):
            report.error(label, f"name '{name}' is not lowercase-kebab-case")
        if name != skill_dir.name:
            report.error(label, f"name '{name}' differs from the directory name '{skill_dir.name}'")

    if not description:
        report.error(label, "frontmatter has no 'description'")
    else:
        if len(description) > MAX_DESCRIPTION:
            report.error(label, f"description is {len(description)} characters, over the {MAX_DESCRIPTION} limit")
        model_invoked = fm.get("disable-model-invocation", "").lower() != "true"
        if model_invoked and not has_trigger(description):
            report.error(label, "description states no trigger ('Use when ...') for a model-invoked skill")

    for key in fm:
        if key in SPEC_KEYS:
            continue
        if key in EXTRA_KEYS:
            report.warn(label, f"frontmatter key '{key}' is outside the Agent Skills specification")
        else:
            report.warn(label, f"unknown frontmatter key '{key}'")

    line_count = len(text.splitlines())
    if line_count > max_lines:
        report.warn(label, f"SKILL.md is {line_count} lines, over the {max_lines}-line budget")

    check_links(skill_file, report, label)
    return report.errors + report.warnings - before


def main() -> int:
    parser = argparse.ArgumentParser(description="Lint every skill under skills/.")
    parser.add_argument("--root", default="skills", help="skills root directory (default: skills)")
    parser.add_argument("--max-lines", type=int, default=500, help="SKILL.md line budget (default: 500)")
    args = parser.parse_args()

    root = Path(args.root)
    if not root.is_dir():
        print(f"ERROR: skills root not found: {root}", file=sys.stderr)
        return 1

    skill_dirs = sorted(path for path in root.glob("*/*") if path.is_dir())
    if not skill_dirs:
        print(f"ERROR: no skills found under {root}", file=sys.stderr)
        return 1

    report = Report()
    for skill_dir in skill_dirs:
        if lint_skill(skill_dir, report, args.max_lines) == 0:
            report.ok(f"{skill_dir.parent.name}/{skill_dir.name}")

    print("\n".join(report.lines))
    status = "FAILED" if report.errors else ("PASSED WITH WARNINGS" if report.warnings else "PASSED")
    print(f"\n{len(skill_dirs)} skills checked — {report.errors} error(s), {report.warnings} warning(s) — {status}")
    return 0 if report.errors == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
