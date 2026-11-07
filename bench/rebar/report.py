#!/usr/bin/env python3
"""Render goose-bstr comparisons from complete rebar CSV rounds."""
import argparse
import csv
from decimal import Decimal
import json
from pathlib import Path
import re
import statistics


ENGINES = {
    "goose/goostr": "goose-bstr",
    "rust/memchr": "memchr",
    "stringzilla": "StringZilla",
    "libc": "libc",
    "rust/sliceslice": "sliceslice (existence-only)",
    "rust/jetscii": "jetscii",
    "rust/std": "Rust std",
    "rust/memchrold": "memchr 2.5",
    "rust/bytecount": "bytecount",
}
OPERATIONS = {
    "memmem/oneshot": "One-shot substring search",
    "memmem/prebuilt": "Prepared substring search",
    "memchr/oneshot": "Forward single-byte search",
    "memrchr": "Reverse single-byte search",
    "memchr2": "Forward two-byte search",
    "memrchr2": "Reverse two-byte search",
    "memchr3": "Forward three-byte search",
    "memrchr3": "Reverse three-byte search",
}


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
            rows[key] = Decimal(value) * {"ns": Decimal(".001"), "us": 1, "µs": 1, "ms": 1000, "s": 1000000}[unit]
    return rows


def matrix(times, columns):
    names = sorted({name for name, engine in times if engine in columns})
    print("| Benchmark | " + " | ".join(columns.values()) + " |")
    print("|---|" + "---:|" * len(columns))
    for name in names:
        cells = []
        best = min(times[name, engine] for engine in columns if (name, engine) in times)
        for engine in columns:
            value = times.get((name, engine))
            if value is None:
                cells.append("—")
                continue
            color = "🟩" if value <= best * Decimal("1.1") else "🟨" if value <= best * Decimal("1.5") else "🟧" if value <= best * 2 else "🟥"
            cell = f"**{value:.3f}**" if value == best else f"{value:.3f}"
            cells.append(f"{color} {cell}")
        label = name.removeprefix("memmem/").removeprefix("memchr/sherlock/")
        print(f"| {label} | " + " | ".join(cells) + " |")
    print()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rounds", type=Path, nargs="+")
    args = parser.parse_args()
    rounds = [read(path) for path in args.rounds]
    if not rounds[0] or any(set(r) != set(rounds[0]) for r in rounds):
        raise ValueError("rounds must contain the same nonempty set of engine/case pairs")
    times = {k: statistics.median(r[k] for r in rounds) for k in rounds[0]}
    ours = [(name, engine.removeprefix("goose/goostr/")) for name, engine in times
            if engine.startswith("goose/goostr/")]
    if len(ours) != 189 or any((name, "rust/memchr/" + mode) not in times for name, mode in ours):
        raise ValueError("expected all 189 matched goose-bstr/memchr cases")

    engines = sorted({engine for _, engine in times})
    groups = {mode: {} for mode in OPERATIONS}
    specialized = {}
    for family, label in ENGINES.items():
        for engine in engines:
            if not engine.startswith(family + "/"):
                continue
            operation = engine[len(family) + 1:]
            if operation in groups and family != "rust/bytecount":
                groups[operation][engine] = "Rust std (setup timed)" if engine == "rust/std/memmem/prebuilt" else label
            else:
                # Internal substring algorithms prepare their finder outside timing.
                mode = "memmem/prebuilt" if operation.startswith("memmem/") else operation.split("/")[0]
                if mode == "memchr":
                    mode = "memchr/oneshot"
                variant = operation.split("/")[-1]
                specialized.setdefault(mode, {})[engine] = label if family == "rust/bytecount" else f"{label} {variant}"
    represented = {engine for columns in [*groups.values(), *specialized.values()] for engine in columns}
    if represented != set(engines):
        raise ValueError(f"unrecognized engines: {set(engines) - represented}")

    metadata_path = args.rounds[0].parent / "environment.json"
    metadata = json.loads(metadata_path.read_text()) if metadata_path.exists() else None
    date = " — " + metadata["timestamp_utc"][:10] if metadata else ""
    print(f"# goose-bstr search benchmarks{date}\n")
    print("Results from memchr's benchmark suite. These measurements describe this corpus and machine, not a general performance ranking.\n")
    print(f"{len(rounds)} rounds · {len({name for name, _ in times})} workloads · {len(engines)} engine configurations · {len(times):,} engine/case pairs per round. No reported measurement errors.\n")
    print("[Substring search](#substring-search) · [Byte search](#byte-search) · [Specialized variants](#specialized-variants) · [Methodology](#methodology)\n")
    print("Raw results: " + ", ".join(f"[{p.name}]({p.name})" for p in args.rounds) + "\n")
    print("**Times are microseconds; lower is better.** Each row is a workload and each column is an engine. Values are medians of round medians for the complete workload, not individual search calls. **Bold** marks the lowest reported time, including ties.\n")
    print("Color is relative to the fastest measured engine in each row: 🟩 ≤1.10× · 🟨 >1.10–1.50× · 🟧 >1.50–2.00× · 🟥 >2.00×. These bands are descriptive, not statistical significance or application speedups; tiny timings and differing APIs need the caveats below.\n")
    print("**—** means that engine was not measured on that workload, not that it failed. All measured engine/case pairs are included below. Benchmark names omit the common `memmem/` or `memchr/sherlock/` prefix. Versions are recorded in the CSVs; `unknown` means the runner did not report a version.\n")

    for heading, substring in (("Substring search", True), ("Byte search", False)):
        print(f"## {heading}\n")
        if substring and any(engine.startswith("rust/sliceslice/") for engine in engines):
            print("**sliceslice is existence-only:** it reports whether a match exists, not its offset. Its count workloads are restricted to zero or one expected match. These timings therefore compare different API work, not interchangeable search operations.\n")
        for mode, title in OPERATIONS.items():
            if mode.startswith("memmem/") != substring:
                continue
            print(f"### {title}\n")
            if "rust/std/memmem/prebuilt" in groups[mode]:
                print("**Rust std includes setup:** upstream calls this mode `prebuilt`, but `haystack.matches(needle).count()` constructs the searcher inside each timed sample. The other prepared searchers are constructed outside timing.\n")
            matrix(times, groups[mode])

    print("## Specialized variants\n")
    if specialized:
        print("These are reference comparisons, not interchangeable search APIs. `bytecount` and `onlycount` count without producing match offsets; `prebuilt` byte search uses an iterator. Internal substring algorithms are compared with prepared finders, with setup outside timing. Fallback and naive variants bypass runtime SIMD selection. goose-bstr and current memchr are repeated for reference.\n")
        for mode, variants in specialized.items():
            print(f"### {OPERATIONS[mode]} variants\n")
            columns = {f"{family}/{mode}": ENGINES[family] for family in ("goose/goostr", "rust/memchr")}
            matrix(times, columns | variants)
    else:
        print("No specialized variants were measured. Use `run.py --all-native` to include them.\n")

    print("## Methodology\n")
    if metadata:
        versions = metadata["versions"]
        print(f"- **Machine:** {metadata['cpu']}; {metadata['platform']}; pinned to logical CPU {metadata['cpu_affinity']}.\n"
              f"- **Compiler:** {versions['clang'].splitlines()[0]}; generated C flags `{' '.join(metadata['c_flags'])}`. Goose `-O2` selects frontend inlining, not C optimization. Rust: `{versions['rustc']}`; {metadata['rust_profile']}. No global native-CPU flags; library runtime SIMD selection applies.\n"
              f"- **Goose:** clean `{versions['goose']}`. Measured goose-bstr: [{metadata['goostr_revision'][:7]}](https://github.com/sstadick/goose-bstr/commit/{metadata['goostr_revision']}).")
    print("- Fixtures, patterns and expected counts come from memchr 2.8.3. Counts are verified before timing and in timed samples. WebAssembly is excluded. The memchr runner's CSV version label is 2.8.2; its dependency is 2.8.3. `memchrold` is 2.5.0.\n"
          "- Serial sweeps, up to 50 ms warmup and 100 ms measurement per engine/case, capped at 20,000 measured samples. No outliers are removed.\n"
          "- Input parsing and output formatting are outside timing. Prepared-finder construction is outside timing except for Rust std, whose searcher is constructed inside each timed sample even in upstream's `prebuilt` mode. One-shot finder construction is inside timing. The Goose adapter adds no extra FFI or black-box barrier.\n"
          "- goose-bstr repeatedly calls public searches for byte counts. Memchr does the same for forward one-shot byte search, but uses reusable iterators for reverse byte and two-/three-byte-set searches. Count-only engines do not produce individual match offsets. These are complete-workload comparisons, including those API differences.\n"
          "- Tiny timings approach clock overhead and are rounded in rebar's CSV output. A few nanoseconds are not a precise throughput claim.\n"
          "- These fixtures have been used during optimization, not held out. One corpus on one CPU does not establish performance on other inputs or architectures.\n")
    print("[Environment, revisions and hashes](environment.json) · [Build and repeat instructions](../../rebar/README.md)")


if __name__ == "__main__":
    main()
