#!/usr/bin/env python3
"""Print us or ua for the active Sway layout.

xkb's short description for Ukrainian is uk. The bar prints ua.
"""

import json
import subprocess

LAYOUT_CODE = {
    "English (US)": "us",
    "Ukrainian": "ua",
}


def active_layout_name() -> str:
    payload = subprocess.check_output(["swaymsg", "-t", "get_inputs"])
    devices = json.loads(payload)
    fallback = ""
    for device in devices:
        if device.get("type") != "keyboard":
            continue
        name = device.get("xkb_active_layout_name") or ""
        if not name:
            continue
        identifier = device.get("identifier") or ""
        if identifier.endswith("_Keyboard"):
            return name
        if not fallback:
            fallback = name
    return fallback


def print_code(previous: str) -> str:
    code = LAYOUT_CODE.get(active_layout_name(), "")
    if code and code != previous:
        print(code, flush=True)
        return code
    return previous


def main() -> None:
    shown = print_code("")
    subscription = subprocess.Popen(
        ["swaymsg", "-t", "subscribe", "-m", '["input"]'],
        stdout=subprocess.PIPE,
        text=True,
    )
    stream = subscription.stdout
    if stream is None:
        raise RuntimeError("swaymsg subscribe produced no output")
    for line in stream:
        if line.strip():
            shown = print_code(shown)


if __name__ == "__main__":
    main()
