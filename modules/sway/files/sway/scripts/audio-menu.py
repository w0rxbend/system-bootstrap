#!/usr/bin/env python3
"""Fuzzel menus for the default PipeWire output and input."""

import json
import subprocess
import sys


def run(args):
    return subprocess.run(args, check=True, text=True, capture_output=True).stdout


def fuzzel(prompt, lines):
    result = subprocess.run(
        [
            "fuzzel",
            "--dmenu",
            "--prompt",
            prompt,
            "--width",
            "56",
            "--lines",
            str(min(max(len(lines), 1), 12)),
        ],
        input="\n".join(lines) + "\n",
        text=True,
        capture_output=True,
    )
    if result.returncode != 0:
        return None
    return result.stdout.strip()


def devices(kind):
    data = json.loads(run(["pactl", "-f", "json", "list", kind]))
    which = "sink" if kind == "sinks" else "source"
    default = run(["pactl", f"get-default-{which}"]).strip()
    labels = {}
    ordered = []
    for item in data:
        name = item["name"]
        if kind == "sources" and name.endswith(".monitor"):
            continue
        desc = item.get("description") or name
        mark = "* " if name == default else "  "
        label = f"{mark}{desc}"
        if label in labels:
            label = f"{mark}{desc} ({name})"
        labels[label] = name
        ordered.append(label)
    return ordered, labels


def main():
    choice = fuzzel("audio> ", ["Outputs", "Inputs"])
    if choice == "Outputs":
        kind, setter, prompt = "sinks", "set-default-sink", "output> "
    elif choice == "Inputs":
        kind, setter, prompt = "sources", "set-default-source", "input> "
    else:
        return 0

    ordered, labels = devices(kind)
    if not ordered:
        subprocess.run(["notify-send", "Audio", f"No {choice.lower()}"], check=False)
        return 1

    picked = fuzzel(prompt, ordered)
    if picked is None:
        return 0
    name = labels.get(picked)
    if name is None:
        return 1
    subprocess.run(["pactl", setter, name], check=True)
    subprocess.run(["notify-send", "Audio", picked.strip()], check=False)
    return 0


if __name__ == "__main__":
    sys.exit(main())
