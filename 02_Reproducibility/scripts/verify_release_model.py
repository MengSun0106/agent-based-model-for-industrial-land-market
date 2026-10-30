#!/usr/bin/env python3
"""Static checks for the single-model release package."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODEL = ROOT / "models" / "main_model.nlogo"
GIS = ROOT / "gis"
SEEDS_30 = [str(seed) for seed in range(1, 31)]


def experiment_block(text: str, name: str) -> str:
    match = re.search(
        rf'<experiment name="{re.escape(name)}".*?</experiment>', text, re.S
    )
    assert match, f"Missing BehaviorSpace experiment: {name}"
    return match.group(0)


def variable_values(block: str, variable: str) -> list[str]:
    match = re.search(
        rf'<enumeratedValueSet variable="{re.escape(variable)}">(.*?)</enumeratedValueSet>',
        block,
        re.S,
    )
    assert match, f"Missing BehaviorSpace variable: {variable}"
    return re.findall(r'<value value="([^"]+)"', match.group(1))


def check_experiment(
    text: str, name: str, scenarios: list[str], enclave_type: str
) -> None:
    block = experiment_block(text, name)
    tick_match = re.search(r'<exitCondition>ticks &gt;= (\d+)</exitCondition>', block)
    assert tick_match and tick_match.group(1) == "30", f"{name}: expected 30 ticks"
    assert variable_values(block, "scenario") == scenarios, f"{name}: scenario mismatch"
    assert variable_values(block, "enclave_type") == [enclave_type], (
        f"{name}: enclave_type mismatch"
    )
    assert variable_values(block, "seed_value") == SEEDS_30, f"{name}: seed mismatch"


def code_comments(code: str) -> list[str]:
    comments: list[str] = []
    for line in code.splitlines():
        in_string = False
        for index, char in enumerate(line):
            if char == '"':
                in_string = not in_string
            elif char == ";" and not in_string:
                comments.append(line[index + 1 :])
                break
    return comments


def main() -> None:
    models = sorted((ROOT / "models").rglob("*.nlogo"))
    assert models == [MODEL], f"Expected one NetLogo model, found {models}"
    assert MODEL.is_file(), f"Missing main model: {MODEL}"

    for suffix in (".shp", ".shx", ".dbf", ".prj", ".cpg"):
        assert (GIS / f"浙江地级市新新{suffix}").is_file(), (
            f"Missing GIS shapefile component: {suffix}"
        )

    text = MODEL.read_text(encoding="utf-8")
    assert 'file-exists? gis-file' in text
    assert 'word "gis/" gis-file' in text
    assert 'word "../gis/" gis-file' in text
    assert "gis:load-dataset gis-path" in text
    assert "GIS shapefile not found" in text

    for name, scenarios, enclave_type in (
        ("validate_reform_main30_baseline", ["1", "2"], "0"),
        ("validate_reform_main30_enclave", ["3", "4"], "1"),
        ("validate_reform_main30_e23", ["3", "4"], "3"),
    ):
        check_experiment(text, name, scenarios, enclave_type)

    code = text.split("@#$#@#$#@", 1)[0]
    chinese_comments = [
        comment for comment in code_comments(code)
        if re.search(r"[\u3400-\u9fff]", comment)
    ]
    assert not chinese_comments, f"Chinese code comments remain: {chinese_comments}"

    print("Single-model package structure and GIS files: OK")
    print("Main BehaviorSpace settings: six policies, 30 ticks, seeds 1–30")
    print("Code comments: English; Chinese GIS attribute keys retained as data fields")


if __name__ == "__main__":
    main()
