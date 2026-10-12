#!/usr/bin/env python3
"""Compare exact manifest requirements and the actual release revisions after generation."""
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
RELEASES = {
    "innodi": ("innoDI", "7.0.2", "b8b03757d659e269217cf10baaa9247b8c29991a"),
    "innoflow": ("innoFlow", "6.0.2", "1176de1e4783b638c03a9334f43cc49378957148"),
    "innonetwork": ("innoNetwork", "6.1.1", "44e4ca28c50c03f817231a077c0f3bdfdbc859c8"),
    "innorouter": ("innoRouter", "7.0.0", "33b0da7639105cfa8e6f5acffa3badb91b5e0254"),
}


def main():
    manifest = (ROOT / "Tuist/ProjectDescriptionHelpers/Dependency/TargetDependency+.swift").read_text()
    resolved = ROOT / "InnoSample.xcworkspace/xcshareddata/swiftpm/Package.resolved"
    if not resolved.exists():
        raise ValueError("Run tuist generate --no-open before verifying the resolved graph")
    pins = {pin["identity"]: pin for pin in json.loads(resolved.read_text())["pins"]}
    for identity, (member, version, revision) in RELEASES.items():
        declared = re.search(rf"static var {member}: Self.*?requirement: \.exact\(\"([^\"]+)\"\)", manifest, re.S)
        if declared is None or declared.group(1) != version:
            raise ValueError(f"{identity}: manifest requirement differs from the reviewed release")
        pin = pins.get(identity, {})
        state = pin.get("state", {})
        if pin.get("kind") != "remoteSourceControl" or state.get("version") != version or state.get("revision") != revision:
            raise ValueError(f"{identity}: resolved version/revision differs from the reviewed release")
        print(f"[PASS] {identity} {version} {revision}")
    if pins.get("swift-syntax", {}).get("state", {}).get("version") != "604.0.0":
        raise ValueError("InnoDI 7.0.2 requires the reviewed swift-syntax 604.0.0 graph")
    graph_script = (ROOT / "Scripts/check-di-graph.sh").read_text()
    if f'INNODI_RELEASE_REVISION="{RELEASES["innodi"][2]}"' not in graph_script:
        raise ValueError("The DI validator must use the same release as the consumer")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, KeyError) as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        sys.exit(1)
