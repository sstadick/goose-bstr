# Run the memchr benchmark suite

Compare this goostr checkout with memchr using memchr's fixtures and the
[rebar](https://github.com/BurntSushi/rebar) harness. The default run covers
**189 matched engine/case pairs across 96 fixtures**: forward substring search,
prepared finders, forward/reverse byte searches, and two-/three-byte sets.

## Requirements

Linux x86-64, Python 3.11+, Git, CMake, a C++ compiler, Clang, Cargo/Rust, and
`taskset` from util-linux. Network access is needed for the first build. The
recorded results use Clang 18.1.3 and Rust 1.97.1; versions are recorded on every
run. Goose, goosimd, memchr and rebar revisions are pinned in `run.py`.

## Run

From the goostr repository root:

```sh
python3 bench/rebar/run.py --cpu 4 --output bench/results/my-run
```

Choose an available logical CPU with `--cpu`. Keep the machine idle during
measurement, including other cores sharing its caches. The output directory
must not exist. Builds finish before verification and serial timing begin.

The script clones and builds its dependencies in `.amp/in/rebar-bench`, adds
that scratch directory to Git's local exclude file, and uses a separate Goose
package cache pinned to the selected goosimd commit. It does not use or update
your normal package cache. `--work-dir /another/scratch/path` changes the cache
location. These checkouts belong to the runner; do not edit them. Reuse the work
directory for subsequent runs; use a fresh one when changing dependency pins.

By default, two rounds compare the eight goostr modes with their corresponding
memchr modes. `--rounds 5` collects more rounds. `--all-native` also builds and
runs the other native engines configured upstream; these can require additional
build dependencies. The report puts workloads in rows and engines in columns,
with separate tables for each operation and setup mode. Count-only and internal
algorithm variants are listed separately. All measurements remain in the CSVs.
WebAssembly is excluded.

The output contains:

- `README.md`: per-workload times for every measured engine, including all 189
  goostr/memchr comparisons, plus methodology and limitations.
- `round-*.csv`: all reported measurements, including any failures.
- `environment.json`: tool versions, pinned revisions, CPU, commands, source,
  fixture and binary hashes, and the goostr worktree status.

Regenerate a report without rerunning benchmarks:

```sh
python3 bench/rebar/report.py bench/results/my-run/round-*.csv \
  > bench/results/my-run/README.md
```

The report reads `environment.json` beside the first CSV for the machine and
compiler details. Regeneration does not rebuild runners or rerun measurements.

Report generation fails on measurement errors, missing pairs, duplicate rows,
or rounds containing different case sets. It never drops failing cases to
produce a successful comparison. For custom comparisons, use rebar's `cmp`
command on the saved CSVs with `--intersection`. Check the shared case count:
not every engine supports every workload.

## What is measured

- Goose `-O2` selects its inlining level; **Clang compiles the generated C at
  `-O3`**. Rust uses upstream release profiles: opt-level 3, one codegen unit,
  fat LTO. Neither runner adds global native-CPU flags. Library runtime SIMD
  selection applies.
- Fixtures, patterns and expected counts come from memchr 2.8.3. Registration
  changes only the engine lists. Every workload is checked against its expected
  count before timing; the timed samples are checked by rebar too. The upstream
  Rust runner identifies itself as 2.8.2, but its dependency is memchr 2.8.3.
- A sample measures a complete count or multi-needle workload, not one search
  call. Parsing and output formatting are outside timing. Prepared-finder
  construction is outside timing except for Rust std: its upstream `prebuilt`
  mode still constructs the searcher inside each timed sample. One-shot search
  construction is inside timing. The goostr and memchr runners use the
  same protocol and timing limits, without an extra FFI or black-box barrier.
- sliceslice only reports whether a match exists, not its offset. Its count
  workloads require zero or one expected match. Its timings are not an
  interchangeable comparison with offset-producing search APIs.
- Forward single-byte counting repeatedly calls one-shot search in both runners.
  Goostr's reverse byte and byte-set counts also repeatedly call public searches;
  memchr uses reusable iterators for those workloads. These comparisons include
  their different setup and iteration costs. Count-only engines in the broader
  suite do not produce individual match offsets.
- Each engine/case gets up to 50 ms warmup and 100 ms measurement, capped at
  20,000 measured samples. Each table value is the median of the round medians,
  in microseconds. No outliers are removed or replaced with confirmation runs.
  For regression comparisons, alternate complete before/after rounds on the
  same machine with the same pins and settings.
- Tiny cases approach clock overhead, and rebar rounds displayed durations.
  Differences of a few nanoseconds are not precise throughput claims. One CPU
  and this corpus cannot establish universal performance or cross-platform
  parity. These fixtures have been used during optimization, not held out.

## Other goostr benchmarks

`../compare.py` compares goostr directly with bstr, including reverse substring
search, inverted byte sets, and boundary cases not covered by this memchr run.
Use `python3 bench/compare.py --help` from the repository root for those suites.
