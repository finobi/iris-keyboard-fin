#!/usr/bin/env python3
"""Regenerate the Rev4 keymap JSON from the Rev8 one so both boards stay identical.

Usage:  python3 sync_rev4.py
Edit keebio_iris_rev8_layout_tomi.json (e.g. via config.qmk.fm), then run this.
"""
import json

src = "keebio_iris_rev8_layout_tomi.json"
dst = "keebio_iris_rev4_layout_tomi.json"

d = json.load(open(src))
d["keyboard"] = "keebio/iris/rev4"
d["keymap"] = "keebio_iris_rev4_layout_tomi"
json.dump(d, open(dst, "w"), indent=2)
print(f"Wrote {dst} from {src}")
