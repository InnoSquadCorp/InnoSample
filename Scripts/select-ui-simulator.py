#!/usr/bin/env python3
"""Select a dedicated iPad mini for real compact/split orientation regressions."""
import json
import os
import subprocess
import sys


def simctl(*arguments):
    return subprocess.check_output(["xcrun", "simctl", *arguments], text=True).strip()


def main():
    expected_version = os.environ.get("UI_TEST_RUNTIME_VERSION")
    runtimes = json.loads(simctl("list", "runtimes", "--json"))["runtimes"]
    preferred = ["iPad mini (A17 Pro)", "iPad mini (6th generation)"]
    candidates = []
    for runtime in runtimes:
        if not runtime.get("isAvailable") or ".iOS-" not in runtime["identifier"]:
            continue
        version = tuple(int(part) for part in runtime["version"].split("."))
        if version < (18, 0) or (expected_version and runtime["version"].split(".")[:2] != expected_version.split(".")[:2]):
            continue
        # Some runtimes (such as Duo-only iOS 27.1) do not support iPad.
        types = runtime.get("supportedDeviceTypes", [])
        device_type = next((item for name in preferred for item in types if item["name"] == name), None)
        if device_type:
            candidates.append((version, runtime, device_type))
    if not candidates:
        raise ValueError(f"Install an iOS {expected_version or '18 or newer'} Simulator runtime supporting iPad mini")
    _, runtime, device_type = max(candidates, key=lambda item: item[0])
    name = "InnoSample UI Regression"
    devices = json.loads(simctl("list", "devices", "available", "--json"))["devices"].get(runtime["identifier"], [])
    existing = next((item for item in devices if item["name"] == name
                     and item["deviceTypeIdentifier"] == device_type["identifier"]), None)
    identifier = existing["udid"] if existing else simctl("create", name, device_type["identifier"], runtime["identifier"])
    print(f"Selected {device_type['name']} on iOS {runtime['version']}", file=sys.stderr)
    print(identifier)


if __name__ == "__main__":
    try:
        main()
    except (ValueError, KeyError, subprocess.CalledProcessError) as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        sys.exit(1)
