#!/usr/bin/env python3
"""Build pinned runners and compare goostr with memchr on Linux x86-64."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import subprocess
import sys
import tomllib

ROOT = Path(__file__).resolve().parents[2]
PINS = {
    "goose": ("aardappel/goose", "eadca409f68210893f366e60d0c2f0dc29a339be"),
    "goosimd": ("sstadick/goosimd", "983f3bb2bfee95affd09f4f5530be249d7d6040b"),
    "memchr": ("BurntSushi/memchr", "5fdb40c054e1fff359a2f7bdf7f87a13b34b465d"),
    "rebar": ("BurntSushi/rebar", "463d00f31887e84c38467805b9e3122c314b9521"),
}
ENGINES = {
    "memchr/oneshot": "memchr-oneshot", "memrchr": "memrchr",
    "memchr2": "memchr2", "memchr3": "memchr3",
    "memrchr2": "memrchr2", "memrchr3": "memrchr3",
    "memmem/oneshot": "memmem-oneshot", "memmem/prebuilt": "memmem-prebuilt",
}


def run(*args, **kwargs):
    print("+", " ".join(map(str, args)), flush=True)
    return subprocess.run(list(map(str, args)), check=True, **kwargs)


def output(*args):
    return subprocess.check_output(list(map(str, args)), text=True).strip()


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checkout(work, name):
    repo, revision = PINS[name]
    path = work / name
    if not path.exists():
        run("git", "clone", f"https://github.com/{repo}.git", path)
        run("git", "-C", path, "checkout", "--detach", revision)
    if output("git", "-C", path, "rev-parse", "HEAD") != revision:
        raise ValueError(f"{path}: expected {revision}; use a fresh work directory")
    if name != "memchr" and output("git", "-C", path, "status", "--porcelain"):
        raise ValueError(f"{path}: expected a clean checkout")
    return path


def register(memchr):
    """Only engine lists change; fixtures, patterns and expected counts do not."""
    def original(path):
        return output("git", "-C", memchr, "show", f"HEAD:{path.relative_to(memchr)}") + "\n"

    config = memchr / "benchmarks/engines.toml"
    text = original(config)
    for name, mode in ENGINES.items():
        text += f'''
[[engine]]
name = "goose/goostr/{name}"
cwd = "./engines/goostr"
[engine.version]
bin = "cat"
args = ["version.txt"]
[engine.run]
bin = "./main"
args = ["{mode}"]
'''
    config.write_text(text)
    for path in (memchr / "benchmarks/definitions").rglob("*.toml"):
        before = original(path)

        def add(match):
            block = match[0]
            additions = [f'  "goose/goostr/{name}",\n' for name in ENGINES
                         if f'"rust/memchr/{name}"' in block]
            return block[:-1] + "".join(additions) + "]"

        after = re.sub(r"engines\s*=\s*\[[^\]]*\]", add, before)
        if after == before:
            continue
        old, new = tomllib.loads(before), tomllib.loads(after)
        for case in new["bench"]:
            case["engines"] = [e for e in case["engines"] if not e.startswith("goose/goostr/")]
        if old != new:
            raise ValueError(f"fixture changed: {path}")
        if after != before:
            path.write_text(after)
    # Reject edits to source code or data in an existing benchmark checkout.
    for changed in output("git", "-C", memchr, "diff", "HEAD", "--name-only").splitlines():
        # Cargo refreshes stale versions of local path dependencies upstream.
        if changed.startswith("benchmarks/engines/") and changed.endswith("/Cargo.lock"):
            continue
        if changed != "benchmarks/engines.toml" and not changed.startswith("benchmarks/definitions/"):
            raise ValueError(f"unexpected modification: {memchr / changed}")


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--work-dir", type=Path, default=ROOT / ".amp/in/rebar-bench")
    p.add_argument("--output", type=Path, required=True, help="new results directory")
    p.add_argument("--cpu", type=int, default=4, help="logical CPU for serial measurements")
    p.add_argument("--rounds", type=int, default=2)
    p.add_argument("--all-native", action="store_true", help="also build/run other upstream native engines")
    args = p.parse_args()
    if platform.system() != "Linux" or platform.machine() != "x86_64":
        p.error("this runner currently supports Linux x86-64")
    if args.cpu not in os.sched_getaffinity(0) or args.rounds < 1:
        p.error("choose an available CPU and at least one round")
    work, dest = args.work_dir.resolve(), args.output.resolve()
    if work.is_relative_to(ROOT / ".amp/in") or dest.is_relative_to(ROOT / ".amp/in"):
        exclude = Path(output("git", "-C", ROOT, "rev-parse", "--path-format=absolute", "--git-path", "info/exclude"))
        text = exclude.read_text() if exclude.exists() else ""
        if "/.amp/in/" not in text.splitlines():
            exclude.parent.mkdir(parents=True, exist_ok=True)
            exclude.write_text(text + "\n/.amp/in/\n")
    dest.mkdir(parents=True, exist_ok=False)
    work.mkdir(parents=True, exist_ok=True)
    repos = {name: checkout(work, name) for name in PINS}
    goose = repos["goose"] / "build/goose"
    if not goose.exists():
        run("cmake", "-S", repos["goose"], "-B", goose.parent,
            "-DCMAKE_BUILD_TYPE=Release", "-DGOOSE_BUILTIN_LIBS=")
        run("cmake", "--build", goose.parent, "--parallel", "2")
    rebar = repos["rebar"] / "target/release/rebar"
    run("cargo", "build", "--locked", "--release", cwd=repos["rebar"])
    home = work / "home"
    dependency = home / "pkg/github.com/sstadick/goosimd/main"
    dependency.parent.mkdir(parents=True, exist_ok=True)
    if not dependency.exists():
        dependency.symlink_to(repos["goosimd"], target_is_directory=True)
    if dependency.resolve() != repos["goosimd"]:
        raise ValueError(f"unexpected package cache: {dependency}")
    env = {**os.environ, "GOOSE_HOME": str(home)}
    engine = repos["memchr"] / "benchmarks/engines/goostr"
    engine.mkdir(exist_ok=True)
    run(goose, "--standalone", "-O2", "-o", engine / "main.c", ROOT / "bench/rebar/main.goose", env=env)
    run("clang", "-O3", engine / "main.c", "-o", engine / "main", "-lm", "-pthread", "-ldl")
    (engine / "version.txt").write_text(sha(engine / "main") + "\n")
    register(repos["memchr"])
    filters = (["-E", "wasm32"] if args.all_native else
               ["-e", "^goose/goostr/", "-e", "^rust/memchr/(memmem/(oneshot|prebuilt)|memchr/oneshot|memchr[23]|memrchr[23]?)$"])
    common = [rebar, "-d", repos["memchr"] / "benchmarks"]
    run(common[0], "build", *common[1:], *filters)
    timing = ["--max-time", "100ms", "--max-warmup-time", "50ms", "--max-iters", "20000", "--timeout", "30s"]
    measure = ["taskset", "-c", str(args.cpu), common[0], "measure", *common[1:], *filters, *timing]
    run(*measure, "--verify")
    sources = [ROOT / p for p in ("search.goose", "goostr.goose", "utf8.goose", "src/dispatch.h",
                                "bench/rebar/main.goose", "bench/rebar/run.py", "bench/rebar/report.py")]
    metadata = dict(timestamp_utc=datetime.now(timezone.utc).isoformat(), platform=platform.platform(),
                    cpu=next(line.split(":", 1)[1].strip() for line in Path("/proc/cpuinfo").read_text().splitlines() if line.startswith("model name")),
                    cpu_affinity=args.cpu, rounds=args.rounds, pins=PINS,
                    goostr_revision=output("git", "-C", ROOT, "rev-parse", "HEAD"),
                    goostr_status=output("git", "-C", ROOT, "status", "--porcelain"),
                    versions={"goose": output(goose, "--version"), "clang": output("clang", "--version"), "rustc": output("rustc", "--version")},
                    goose_flags=["--standalone", "-O2"], c_flags=["-O3"], rust_profile="upstream release (opt-level 3, one codegen unit, fat LTO)",
                    command=list(map(str, measure)), source_hashes={str(p.relative_to(ROOT)): sha(p) for p in sources},
                    dependency_hashes={p: sha(repos["goosimd"] / p) for p in ("goosimd.goose", "include/goosimd.h")},
                    cargo_lock_hashes={str(p.relative_to(repos["memchr"])): sha(p) for p in sorted((repos["memchr"] / "benchmarks/engines").rglob("Cargo.lock"))},
                    fixture_hashes={str(p.relative_to(repos["memchr"])): sha(p) for folder in ("definitions", "haystacks") for p in sorted((repos["memchr"] / "benchmarks" / folder).rglob("*")) if p.is_file()},
                    runner_sha256=sha(engine / "main"), rust_runner_sha256=sha(repos["memchr"] / "benchmarks/engines/rust-memchr/target/release/main"))
    (dest / "environment.json").write_text(json.dumps(metadata, indent=2) + "\n")
    csvs = []
    for i in range(1, args.rounds + 1):
        path = dest / f"round-{i}.csv"
        with path.open("w") as out:
            run(*measure, stdout=out)
        csvs.append(path)
    with (dest / "README.md").open("w") as out:
        run(sys.executable, ROOT / "bench/rebar/report.py", *csvs, stdout=out)


if __name__ == "__main__":
    main()
