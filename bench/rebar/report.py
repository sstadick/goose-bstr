#!/usr/bin/env python3
"""Render paired goostr/memchr tables from complete rebar CSV rounds."""
import argparse
import csv
import math
from pathlib import Path
import re
import statistics


def read(path):
    rows = {}
    with path.open(newline="") as source:
        for row in csv.DictReader(source):
            if row["err"]:
                raise ValueError(f"{path}: {row['name']} / {row['engine']}: {row['err']}")
            key = row["name"], row["engine"]
            if key in rows:
                raise ValueError(f"{path}: duplicate {key}")
            value, unit = re.fullmatch(r"([0-9.]+)(ns|us|µs|ms|s)", row["median"]).groups()
            rows[key] = float(value) * {"ns": .001, "us": 1, "µs": 1, "ms": 1000, "s": 1e6}[unit]
    return rows


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rounds", type=Path, nargs="+")
    args = parser.parse_args()
    rounds = [read(path) for path in args.rounds]
    if not rounds[0] or any(set(r) != set(rounds[0]) for r in rounds):
        raise ValueError("rounds must contain the same nonempty set of engine/case pairs")
    times = {k: statistics.median(r[k] for r in rounds) for k in rounds[0]}
    groups = {}
    for (name, engine), elapsed in sorted(times.items()):
        if not engine.startswith("goose/goostr/"):
            continue
        mode = engine.removeprefix("goose/goostr/")
        other = times[name, "rust/memchr/" + mode]
        groups.setdefault(mode, []).append((name, elapsed, other, elapsed / other))
    if sum(map(len, groups.values())) != 189:
        raise ValueError("expected all 189 matched goostr/memchr cases")
    print("# goostr / memchr benchmark results\n")
    print(f"{len(rounds)} rounds, 189 matched engine/case pairs. All expected-count checks passed.\n")
    print(f"The CSVs contain {len(times)} engine/case pairs across {len({engine for _, engine in times})} engines.\n")
    print("Times are microseconds for the complete workload. Each value is the median of round medians. Ratios are goostr / memchr; lower is better. Tiny values near clock overhead are imprecise.\n")
    print("[Methodology and repeat commands](../../rebar/README.md) · [Environment, pins and hashes](environment.json)\n")
    print("Raw results: " + ", ".join(f"[{p.name}]({p.name})" for p in args.rounds) + "\n")
    print("## Aggregate ratios\n\n| Operation | Cases | Geometric mean |\n|---|---:|---:|")
    for mode, rows in groups.items():
        ratio = math.exp(statistics.mean(math.log(r[3]) for r in rows))
        print(f"| {mode} | {len(rows)} | {ratio:.3f}× |")
    print("\nGeometric means weight cases equally, not by runtime; they are not application speedups.\n")
    print("## Largest losses above one microsecond\n\n| Benchmark | Operation | goostr µs | memchr µs | Ratio |\n|---|---|---:|---:|---:|")
    losses = [(ratio, name, mode, ours, theirs) for mode, rows in groups.items()
              for name, ours, theirs, ratio in rows if ratio > 1 and max(ours, theirs) >= 1]
    for ratio, name, mode, ours, theirs in sorted(losses, reverse=True)[:15]:
        print(f"| {name} | {mode} | {ours:.3f} | {theirs:.3f} | {ratio:.3f}× |")
    for mode, rows in groups.items():
        print(f"\n## {mode}\n\n| Benchmark | goostr µs | memchr µs | Ratio |\n|---|---:|---:|---:|")
        for name, ours, theirs, ratio in rows:
            print(f"| {name} | {ours:.3f} | {theirs:.3f} | {ratio:.3f}× |")


if __name__ == "__main__":
    main()
