#!/usr/bin/env python3
"""Keep localized sample READMEs aligned with each other and checked-in code."""

from collections import Counter
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
READMES = (
    "README.md", "README.ko.md", "README.es.md", "README.de.md",
    "README.zh-Hans.md", "README.ja.md", "README.ru.md",
)
SECTIONS = re.compile(r"^<!-- section:([a-z-]+) -->$", re.MULTILINE)
FENCES = re.compile(r"^```([^\n]*)\n(.*?)\n```$", re.MULTILINE | re.DOTALL)
LINKS = re.compile(r"\]\(([^\s)]+)\)")
SOURCES = re.compile(
    r"^<!-- source:([^\n]+) -->\n```swift\n(.*?)\n```$",
    re.MULTILINE | re.DOTALL,
)
INLINE = re.compile(r"`([^`\n]+)`")


def exact_path(root: Path, relative: str) -> Path:
    """Detect public-link casing mistakes even on case-insensitive APFS."""
    path = root
    for part in Path(relative).parts:
        if part in ("..", "/"):
            raise ValueError(f"link must stay inside the repository: {relative}")
        if not path.is_dir() or part not in {child.name for child in path.iterdir()}:
            raise ValueError(f"missing path or incorrect case: {relative}")
        path /= part
    return path


def check_document(name: str, text: str, canonical: str, root: Path = ROOT) -> list[str]:
    errors = []
    sections = SECTIONS.findall(text)
    if not sections or sections != SECTIONS.findall(canonical) or len(set(sections)) != len(sections):
        errors.append("section identifiers differ from the English README")
    headings = re.findall(r"^(#{1,6}) ", text, re.MULTILINE)
    if headings != re.findall(r"^(#{1,6}) ", canonical, re.MULTILINE):
        errors.append("heading hierarchy differs from the English README")
    fences = FENCES.findall(text)
    if len(re.findall(r"^```", text, re.MULTILINE)) != 2 * len(fences):
        errors.append("unbalanced code fences")
    if fences != FENCES.findall(canonical):
        errors.append("code blocks differ from the English README")
    # Public identifiers and command tokens should not change in translation.
    prose = FENCES.sub("", text)
    canonical_prose = FENCES.sub("", canonical)
    if Counter(INLINE.findall(prose)) != Counter(INLINE.findall(canonical_prose)):
        errors.append("inline API or command tokens differ from the English README")
    if Counter(LINKS.findall(text)) != Counter(LINKS.findall(canonical)):
        errors.append("link destinations differ from the English README")
    for link in set(LINKS.findall(text)):
        url = urlsplit(link)
        if url.scheme or url.netloc or not url.path:
            continue
        try:
            exact_path(root, unquote(url.path))
        except ValueError as error:
            errors.append(str(error))

    sources = SOURCES.findall(text)
    if len(sources) != len(re.findall(r"^```swift$", text, re.MULTILINE)) or not sources:
        errors.append("every Swift example must declare its source file")
    for relative, snippet in sources:
        try:
            source = exact_path(root, relative).read_text(encoding="utf-8")
            if snippet + "\n" not in source:
                errors.append(f"example differs from source: {relative}")
        except (ValueError, OSError) as error:
            errors.append(str(error))

    manifest = (root / "Tuist/ProjectDescriptionHelpers/Dependency/TargetDependency+.swift").read_text()
    releases = re.findall(
        r"static var (innoDI|innoFlow|innoNetwork|innoRouter): Self.*?requirement: \.exact\(\"([^\"]+)\"\)",
        manifest, re.DOTALL,
    )
    if len(releases) != 4:
        errors.append("cannot read the four exact release declarations")
    for identifier, version in releases:
        library = "I" + identifier[1:]
        row = rf"\| \[{library}\]\(https://github.com/InnoSquadCorp/{library}/tree/{re.escape(version)}\) \| {re.escape(version)} \|"
        if not re.search(row, text):
            errors.append(f"release table differs from manifest: {library} {version}")
    return [f"{name}: {error}" for error in errors]


def main() -> int:
    canonical = (ROOT / READMES[0]).read_text(encoding="utf-8")
    errors = []
    for name in READMES:
        try:
            text = (ROOT / name).read_text(encoding="utf-8")
            failures = check_document(name, text, canonical)
            errors.extend(failures)
            if not failures:
                print(f"[OK] {name}: structure, APIs, examples, links and release pins")
        except OSError as error:
            errors.append(f"{name}: {error}")
    for error in errors:
        print(f"[FAIL] {error}", file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
