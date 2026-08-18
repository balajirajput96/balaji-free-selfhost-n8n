#!/usr/bin/env python3
"""Create safe, inactive n8n workflow import files without exposing credentials."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "workflows" / "pharma-review"
TARGET = ROOT / "workflows" / "inactive-import"

TARGET.mkdir(parents=True, exist_ok=True)

for source_path in sorted(SOURCE.glob("*.json")):
    data = json.loads(source_path.read_text(encoding="utf-8"))
    data.pop("id", None)
    data.pop("versionId", None)
    data.pop("meta", None)
    data["active"] = False
    data["name"] = f"[Review before activation] {data.get('name', source_path.stem)}"
    target_path = TARGET / source_path.name
    target_path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(target_path.name)

print(f"Prepared {len(list(TARGET.glob('*.json')))} inactive workflows in {TARGET}")
