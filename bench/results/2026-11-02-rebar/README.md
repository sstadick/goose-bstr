# memchr/rebar comparison — 2026-11-02

2 rounds, 96 benchmark cases, 48 native engine variants.
Successful engine/case pairs: 1286. Measurement errors: 0.
Samples per pair (rounds): {2: 1286}.

Ratios are goostr time / competitor time; lower is better. Each case uses the median of round medians, then ratios are geometrically averaged. These are paired intersections, not a ranking across different workloads.

[Methodology](#methodology) · [Environment and revisions](environment.json) · [Every case](#every-case-against-memchr)

Raw measurements: [round-1.csv](round-1.csv), [round-2.csv](round-2.csv)

## Methodology

Measured goostr source: [168e7a6](https://github.com/sstadick/goostr/commit/168e7a62d54b41ef39787e07bb04104f60399239).
The CSV engine version contains the pre-commit base revision and the measured
executable hash; the source hashes in `environment.json` match this commit.

- AMD Ryzen 9 3950X, Linux x86-64, pinned to CPU 4. Two serial timing sweeps;
  50 ms warmup, up to 100 ms measurement, at most 20,000 measured samples per pair.
- Clean Goose `eadca409f68210893f366e60d0c2f0dc29a339be`; Goose `-O2` selects its
  inlining level. **Clang 18.1.3 compiles the generated C at `-O3`.** Rust 1.97.1
  uses upstream release profiles: optimization level 3, one codegen unit, fat LTO.
  Neither build adds global native-CPU flags; library runtime SIMD selection applies.
- Fixtures and expected counts come from [memchr 2.8.3](https://github.com/BurntSushi/memchr/tree/5fdb40c054e1fff359a2f7bdf7f87a13b34b465d/benchmarks).
  Inputs and expected counts were unchanged. All 1,286 native engine/case correctness
  checks passed. WebAssembly is excluded. The current memchr runner reports
  `2.8.2` in CSV, but its dependency is 2.8.3; `memchrold` uses 2.5.0.
- Times measure a complete count or multi-needle job, not one search call.
  The local Goose runner implements rebar's KLV protocol and uses a monotonic clock.
  Input parsing, prepared-finder setup, and CSV output are outside the timed job.
  Neither runner adds an FFI call or extra black-box barrier.
- Goostr byte-set counts repeatedly call public searches; memchr2/3 use reusable
  iterators. Count-only engines do not produce individual match offsets.
- Ratios near clock overhead are imprecise. Geometric means weight each case
  equally and are not overall application speedups. A favorable aggregate does
  not imply a win on every case or even most cases.
- The 54 single-needle substring fixtures overlap earlier goostr comparisons.
  The additional coverage is 39 byte-count fixtures and three multi-needle
  workloads. These measurements are not an unseen holdout or a cross-CPU claim.
- The runner adapter and engine registration remain local, so these files alone
  do not rebuild the experiment. The two CSVs retain all reported measurements
  and allow the tables to be recalculated: take each engine/case's median of
  round medians, divide paired times, then geometrically average those ratios.

## Current memchr

| Operation | Cases | Time ratio | Goostr faster / equal / slower |
|---|---:|---:|---:|
| memchr/oneshot | 15 | 0.88× | 9 / 3 / 3 |
| memchr2 | 12 | 0.91× | 7 / 2 / 3 |
| memchr3 | 12 | 0.87× | 8 / 1 / 3 |
| memmem/oneshot | 54 | 0.74× | 35 / 1 / 18 |
| memmem/prebuilt | 57 | 0.92× | 24 / 4 / 29 |
| memrchr | 15 | 0.89× | 10 / 2 / 3 |
| memrchr2 | 12 | 0.88× | 8 / 3 / 1 |
| memrchr3 | 12 | 0.89× | 8 / 2 / 2 |

## Substring groups against current memchr

| Group | Mode | Cases | Time ratio |
|---|---|---:|---:|
| memmem/byterank | oneshot | 1 | 0.38× |
| memmem/code | oneshot | 8 | 0.94× |
| memmem/pathological | oneshot | 9 | 0.51× |
| memmem/subtitles/common | oneshot | 9 | 0.75× |
| memmem/subtitles/never | oneshot | 12 | 0.71× |
| memmem/subtitles/rare | oneshot | 15 | 0.88× |
| memmem/byterank | prebuilt | 1 | 0.38× |
| memmem/code | prebuilt | 8 | 1.10× |
| memmem/pathological | prebuilt | 9 | 0.60× |
| memmem/sliceslice | prebuilt | 3 | 1.13× |
| memmem/subtitles/common | prebuilt | 9 | 1.27× |
| memmem/subtitles/never | prebuilt | 12 | 0.83× |
| memmem/subtitles/rare | prebuilt | 15 | 0.96× |

## Substring search against other native engines

| Competitor | Mode | Shared cases | Time ratio |
|---|---|---:|---:|
| libc | oneshot | 54 | 0.31× |
| rust/jetscii | oneshot | 54 | 0.31× |
| rust/jetscii | prebuilt | 54 | 0.31× |
| rust/memchr | oneshot | 54 | 0.74× |
| rust/memchr | prebuilt | 57 | 0.92× |
| rust/memchrold | oneshot | 54 | 0.78× |
| rust/memchrold | prebuilt | 57 | 0.86× |
| rust/sliceslice | oneshot | 39 | 0.63× |
| rust/sliceslice | prebuilt | 42 | 0.68× |
| rust/std | oneshot | 53 | 0.14× |
| rust/std | prebuilt | 53 | 0.15× |
| stringzilla | oneshot | 54 | 0.71× |

## Largest losses and wins against current memchr

### Losses

| Benchmark | Operation | Goostr | memchr | Ratio |
|---|---|---:|---:|---:|
| memmem/subtitles/common/huge-en-that | memmem/prebuilt | 43.885 µs | 25.770 µs | 1.70× |
| memmem/subtitles/common/huge-en-you | memmem/prebuilt | 99.220 µs | 59.385 µs | 1.67× |
| memmem/code/rust-library-common-fn | memmem/prebuilt | 108.295 µs | 66.100 µs | 1.64× |
| memmem/sliceslice/seemingly-random | memmem/prebuilt | 185.220 µs | 113.315 µs | 1.63× |
| memmem/subtitles/common/huge-ru-not | memmem/prebuilt | 84.495 µs | 53.750 µs | 1.57× |
| memmem/subtitles/common/huge-zh-do-not | memmem/prebuilt | 68.845 µs | 44.220 µs | 1.56× |
| memmem/code/rust-library-common-let | memmem/prebuilt | 165.210 µs | 108.380 µs | 1.52× |
| memmem/subtitles/common/huge-ru-that | memmem/prebuilt | 33.595 µs | 23.195 µs | 1.45× |
| memmem/pathological/md5-huge-last-hash | memmem/prebuilt | 4.620 µs | 3.225 µs | 1.43× |
| memmem/subtitles/common/huge-zh-that | memmem/prebuilt | 30.745 µs | 22.265 µs | 1.38× |
| memchr/sherlock/common/huge1 | memchr/oneshot | 321.290 µs | 239.945 µs | 1.34× |
| memmem/pathological/md5-huge-no-hash | memmem/prebuilt | 4.365 µs | 3.260 µs | 1.34× |

### Substring losses

| Benchmark | Operation | Goostr | memchr | Ratio |
|---|---|---:|---:|---:|
| memmem/subtitles/common/huge-en-that | memmem/prebuilt | 43.885 µs | 25.770 µs | 1.70× |
| memmem/subtitles/common/huge-en-you | memmem/prebuilt | 99.220 µs | 59.385 µs | 1.67× |
| memmem/code/rust-library-common-fn | memmem/prebuilt | 108.295 µs | 66.100 µs | 1.64× |
| memmem/sliceslice/seemingly-random | memmem/prebuilt | 185.220 µs | 113.315 µs | 1.63× |
| memmem/subtitles/common/huge-ru-not | memmem/prebuilt | 84.495 µs | 53.750 µs | 1.57× |
| memmem/subtitles/common/huge-zh-do-not | memmem/prebuilt | 68.845 µs | 44.220 µs | 1.56× |
| memmem/code/rust-library-common-let | memmem/prebuilt | 165.210 µs | 108.380 µs | 1.52× |
| memmem/subtitles/common/huge-ru-that | memmem/prebuilt | 33.595 µs | 23.195 µs | 1.45× |

### Wins

| Benchmark | Operation | Goostr | memchr | Ratio |
|---|---|---:|---:|---:|
| memmem/pathological/defeat-simple-vector-repeated-alphabet | memmem/prebuilt | 61.025 µs | 1000.000 µs | 0.06× |
| memmem/pathological/defeat-simple-vector-repeated-alphabet | memmem/oneshot | 61.435 µs | 1000.000 µs | 0.06× |
| memmem/pathological/defeat-simple-vector-alphabet | memmem/oneshot | 28.450 µs | 156.050 µs | 0.18× |
| memmem/pathological/defeat-simple-vector-alphabet | memmem/prebuilt | 28.520 µs | 155.775 µs | 0.18× |
| memmem/byterank/binary | memmem/oneshot | 3340.000 µs | 8810.000 µs | 0.38× |
| memmem/byterank/binary | memmem/prebuilt | 3330.000 µs | 8770.000 µs | 0.38× |
| memmem/subtitles/never/teeny-ru-john-watson | memmem/oneshot | 0.020 µs | 0.050 µs | 0.40× |
| memmem/pathological/rare-repeated-small-match | memmem/oneshot | 1.665 µs | 3.465 µs | 0.48× |
| memmem/pathological/rare-repeated-huge-match | memmem/oneshot | 872.700 µs | 1805.000 µs | 0.48× |
| memmem/subtitles/common/huge-en-one-space | memmem/oneshot | 607.190 µs | 1230.000 µs | 0.49× |
| memchr/sherlock/rare/tiny1 | memrchr | 0.020 µs | 0.040 µs | 0.50× |
| memmem/subtitles/never/teeny-en-all-common-bytes | memmem/oneshot | 0.020 µs | 0.040 µs | 0.50× |

## All native engine comparisons

Byte engines below perform the same count job, but bytecount and memchr/onlycount use specialized counting rather than producing individual match offsets. Multi-byte goostr counts repeatedly call its public byteset search, whereas memchr2/3 use reusable iterators.

| Goostr operation | Competitor | Shared cases | Time ratio |
|---|---|---:|---:|
| memchr/oneshot | libc/memchr/oneshot | 15 | 0.99× |
| memchr/oneshot | rust/bytecount/memchr/oneshot | 15 | 1.68× |
| memchr/oneshot | rust/memchr/memchr/fallback | 15 | 0.62× |
| memchr/oneshot | rust/memchr/memchr/naive | 15 | 0.27× |
| memchr/oneshot | rust/memchr/memchr/oneshot | 15 | 0.88× |
| memchr/oneshot | rust/memchr/memchr/onlycount | 15 | 2.04× |
| memchr/oneshot | rust/memchr/memchr/prebuilt | 15 | 0.88× |
| memchr/oneshot | rust/memchr/memrchr | 15 | 0.83× |
| memchr/oneshot | rust/memchrold/memchr/naive | 14 | 0.37× |
| memchr/oneshot | rust/memchrold/memchr/oneshot | 15 | 1.04× |
| memchr/oneshot | rust/memchrold/memchr/prebuilt | 15 | 1.06× |
| memchr/oneshot | rust/memchrold/memrchr | 15 | 1.03× |
| memchr2 | rust/memchr/memchr2 | 12 | 0.91× |
| memchr2 | rust/memchr/memchr2/fallback | 12 | 0.50× |
| memchr2 | rust/memchr/memchr2/naive | 12 | 0.24× |
| memchr2 | rust/memchr/memrchr2 | 12 | 0.85× |
| memchr2 | rust/memchrold/memchr2 | 12 | 1.03× |
| memchr2 | rust/memchrold/memrchr2 | 12 | 1.03× |
| memchr3 | rust/memchr/memchr3 | 12 | 0.87× |
| memchr3 | rust/memchr/memchr3/fallback | 12 | 0.48× |
| memchr3 | rust/memchr/memchr3/naive | 12 | 0.28× |
| memchr3 | rust/memchr/memrchr3 | 12 | 0.81× |
| memchr3 | rust/memchrold/memchr3 | 12 | 1.06× |
| memchr3 | rust/memchrold/memrchr3 | 12 | 0.99× |
| memmem/oneshot | libc/memmem/oneshot | 54 | 0.31× |
| memmem/oneshot | rust/jetscii/memmem/oneshot | 54 | 0.31× |
| memmem/oneshot | rust/jetscii/memmem/prebuilt | 54 | 0.35× |
| memmem/oneshot | rust/memchr/memmem/binary | 1 | 2.01× |
| memmem/oneshot | rust/memchr/memmem/oneshot | 54 | 0.74× |
| memmem/oneshot | rust/memchr/memmem/prebuilt | 54 | 1.01× |
| memmem/oneshot | rust/memchr/memmem/rabinkarp | 54 | 0.12× |
| memmem/oneshot | rust/memchr/memmem/shiftor | 40 | 0.19× |
| memmem/oneshot | rust/memchr/memmem/twoway | 54 | 0.19× |
| memmem/oneshot | rust/memchrold/memmem/oneshot | 54 | 0.78× |
| memmem/oneshot | rust/memchrold/memmem/prebuilt | 54 | 0.96× |
| memmem/oneshot | rust/sliceslice/memmem/oneshot | 39 | 0.63× |
| memmem/oneshot | rust/sliceslice/memmem/prebuilt | 39 | 0.70× |
| memmem/oneshot | rust/std/memmem/oneshot | 53 | 0.14× |
| memmem/oneshot | rust/std/memmem/prebuilt | 53 | 0.17× |
| memmem/oneshot | stringzilla/memmem/oneshot | 54 | 0.71× |
| memmem/prebuilt | libc/memmem/oneshot | 54 | 0.28× |
| memmem/prebuilt | rust/jetscii/memmem/oneshot | 54 | 0.28× |
| memmem/prebuilt | rust/jetscii/memmem/prebuilt | 54 | 0.31× |
| memmem/prebuilt | rust/memchr/memmem/binary | 1 | 2.00× |
| memmem/prebuilt | rust/memchr/memmem/oneshot | 54 | 0.66× |
| memmem/prebuilt | rust/memchr/memmem/prebuilt | 57 | 0.92× |
| memmem/prebuilt | rust/memchr/memmem/rabinkarp | 54 | 0.11× |
| memmem/prebuilt | rust/memchr/memmem/shiftor | 40 | 0.17× |
| memmem/prebuilt | rust/memchr/memmem/twoway | 54 | 0.17× |
| memmem/prebuilt | rust/memchrold/memmem/oneshot | 54 | 0.70× |
| memmem/prebuilt | rust/memchrold/memmem/prebuilt | 57 | 0.86× |
| memmem/prebuilt | rust/sliceslice/memmem/oneshot | 39 | 0.61× |
| memmem/prebuilt | rust/sliceslice/memmem/prebuilt | 42 | 0.68× |
| memmem/prebuilt | rust/std/memmem/oneshot | 53 | 0.13× |
| memmem/prebuilt | rust/std/memmem/prebuilt | 53 | 0.15× |
| memmem/prebuilt | stringzilla/memmem/oneshot | 54 | 0.63× |
| memrchr | libc/memchr/oneshot | 15 | 1.06× |
| memrchr | rust/bytecount/memchr/oneshot | 15 | 1.80× |
| memrchr | rust/memchr/memchr/fallback | 15 | 0.66× |
| memrchr | rust/memchr/memchr/naive | 15 | 0.29× |
| memrchr | rust/memchr/memchr/oneshot | 15 | 0.94× |
| memrchr | rust/memchr/memchr/onlycount | 15 | 2.18× |
| memrchr | rust/memchr/memchr/prebuilt | 15 | 0.94× |
| memrchr | rust/memchr/memrchr | 15 | 0.89× |
| memrchr | rust/memchrold/memchr/naive | 14 | 0.39× |
| memrchr | rust/memchrold/memchr/oneshot | 15 | 1.11× |
| memrchr | rust/memchrold/memchr/prebuilt | 15 | 1.14× |
| memrchr | rust/memchrold/memrchr | 15 | 1.10× |
| memrchr2 | rust/memchr/memchr2 | 12 | 0.93× |
| memrchr2 | rust/memchr/memchr2/fallback | 12 | 0.51× |
| memrchr2 | rust/memchr/memchr2/naive | 12 | 0.24× |
| memrchr2 | rust/memchr/memrchr2 | 12 | 0.88× |
| memrchr2 | rust/memchrold/memchr2 | 12 | 1.06× |
| memrchr2 | rust/memchrold/memrchr2 | 12 | 1.05× |
| memrchr3 | rust/memchr/memchr3 | 12 | 0.95× |
| memrchr3 | rust/memchr/memchr3/fallback | 12 | 0.53× |
| memrchr3 | rust/memchr/memchr3/naive | 12 | 0.31× |
| memrchr3 | rust/memchr/memrchr3 | 12 | 0.89× |
| memrchr3 | rust/memchrold/memchr3 | 12 | 1.16× |
| memrchr3 | rust/memchrold/memrchr3 | 12 | 1.08× |

## Every case against memchr

All 189 goostr entries are listed below. Times are medians of round medians, in microseconds.

### memchr/oneshot

| Benchmark | Goostr (µs) | memchr (µs) | Ratio |
|---|---:|---:|---:|
| memchr/sherlock/common/huge1 | 321.290 | 239.945 | 1.34× |
| memchr/sherlock/common/small1 | 0.200 | 0.290 | 0.69× |
| memchr/sherlock/common/tiny1 | 0.060 | 0.080 | 0.75× |
| memchr/sherlock/never/empty1 | 0.020 | 0.020 | 1.00× |
| memchr/sherlock/never/huge1 | 5.730 | 5.395 | 1.06× |
| memchr/sherlock/never/small1 | 0.030 | 0.030 | 1.00× |
| memchr/sherlock/never/tiny1 | 0.020 | 0.030 | 0.67× |
| memchr/sherlock/rare/huge1 | 6.970 | 6.875 | 1.01× |
| memchr/sherlock/rare/small1 | 0.030 | 0.030 | 1.00× |
| memchr/sherlock/rare/tiny1 | 0.020 | 0.030 | 0.67× |
| memchr/sherlock/uncommon/huge1 | 86.440 | 93.555 | 0.92× |
| memchr/sherlock/uncommon/small1 | 0.060 | 0.075 | 0.80× |
| memchr/sherlock/uncommon/tiny1 | 0.040 | 0.050 | 0.80× |
| memchr/sherlock/verycommon/huge1 | 454.165 | 485.020 | 0.94× |
| memchr/sherlock/verycommon/small1 | 0.450 | 0.545 | 0.83× |

### memchr2

| Benchmark | Goostr (µs) | memchr (µs) | Ratio |
|---|---:|---:|---:|
| memchr/sherlock/common/huge2 | 409.950 | 396.390 | 1.03× |
| memchr/sherlock/common/small2 | 0.360 | 0.435 | 0.83× |
| memchr/sherlock/never/empty2 | 0.020 | 0.020 | 1.00× |
| memchr/sherlock/never/huge2 | 7.390 | 7.255 | 1.02× |
| memchr/sherlock/never/small2 | 0.040 | 0.030 | 1.33× |
| memchr/sherlock/never/tiny2 | 0.020 | 0.030 | 0.67× |
| memchr/sherlock/rare/huge2 | 10.160 | 11.170 | 0.91× |
| memchr/sherlock/rare/small2 | 0.040 | 0.040 | 1.00× |
| memchr/sherlock/rare/tiny2 | 0.030 | 0.040 | 0.75× |
| memchr/sherlock/uncommon/huge2 | 159.980 | 190.840 | 0.84× |
| memchr/sherlock/uncommon/small2 | 0.100 | 0.120 | 0.83× |
| memchr/sherlock/uncommon/tiny2 | 0.060 | 0.070 | 0.86× |

### memchr3

| Benchmark | Goostr (µs) | memchr (µs) | Ratio |
|---|---:|---:|---:|
| memchr/sherlock/common/huge3 | 516.460 | 653.035 | 0.79× |
| memchr/sherlock/common/small3 | 0.575 | 0.695 | 0.83× |
| memchr/sherlock/never/empty3 | 0.020 | 0.020 | 1.00× |
| memchr/sherlock/never/huge3 | 9.285 | 9.210 | 1.01× |
| memchr/sherlock/never/small3 | 0.040 | 0.030 | 1.33× |
| memchr/sherlock/never/tiny3 | 0.020 | 0.030 | 0.67× |
| memchr/sherlock/rare/huge3 | 13.335 | 14.880 | 0.90× |
| memchr/sherlock/rare/small3 | 0.050 | 0.060 | 0.83× |
| memchr/sherlock/rare/tiny3 | 0.030 | 0.050 | 0.60× |
| memchr/sherlock/uncommon/huge3 | 267.190 | 241.055 | 1.11× |
| memchr/sherlock/uncommon/small3 | 0.150 | 0.185 | 0.81× |
| memchr/sherlock/uncommon/tiny3 | 0.090 | 0.115 | 0.78× |

### memmem/oneshot

| Benchmark | Goostr (µs) | memchr (µs) | Ratio |
|---|---:|---:|---:|
| memmem/byterank/binary | 3340.000 | 8810.000 | 0.38× |
| memmem/code/rust-library-common-fn | 122.440 | 127.665 | 0.96× |
| memmem/code/rust-library-common-fn-is-empty | 30.225 | 30.035 | 1.01× |
| memmem/code/rust-library-common-let | 190.510 | 208.455 | 0.91× |
| memmem/code/rust-library-common-paren | 447.265 | 684.455 | 0.65× |
| memmem/code/rust-library-never-fn-quux | 26.050 | 25.585 | 1.02× |
| memmem/code/rust-library-never-fn-strength | 28.495 | 28.195 | 1.01× |
| memmem/code/rust-library-never-fn-strength-paren | 29.085 | 28.480 | 1.02× |
| memmem/code/rust-library-rare-fn-from-str | 29.120 | 29.000 | 1.00× |
| memmem/pathological/defeat-simple-vector-alphabet | 28.450 | 156.050 | 0.18× |
| memmem/pathological/defeat-simple-vector-freq-alphabet | 39.170 | 51.635 | 0.76× |
| memmem/pathological/defeat-simple-vector-repeated-alphabet | 61.435 | 1000.000 | 0.06× |
| memmem/pathological/md5-huge-last-hash | 4.580 | 3.795 | 1.21× |
| memmem/pathological/md5-huge-no-hash | 4.440 | 3.525 | 1.26× |
| memmem/pathological/rare-repeated-huge-match | 872.700 | 1805.000 | 0.48× |
| memmem/pathological/rare-repeated-huge-tricky | 7.640 | 7.665 | 1.00× |
| memmem/pathological/rare-repeated-small-match | 1.665 | 3.465 | 0.48× |
| memmem/pathological/rare-repeated-small-tricky | 0.060 | 0.080 | 0.75× |
| memmem/subtitles/common/huge-en-one-space | 607.190 | 1230.000 | 0.49× |
| memmem/subtitles/common/huge-en-that | 51.875 | 46.265 | 1.12× |
| memmem/subtitles/common/huge-en-you | 139.380 | 188.330 | 0.74× |
| memmem/subtitles/common/huge-ru-not | 106.980 | 135.145 | 0.79× |
| memmem/subtitles/common/huge-ru-one-space | 465.595 | 626.620 | 0.74× |
| memmem/subtitles/common/huge-ru-that | 45.535 | 52.150 | 0.87× |
| memmem/subtitles/common/huge-zh-do-not | 86.160 | 113.640 | 0.76× |
| memmem/subtitles/common/huge-zh-one-space | 186.265 | 304.030 | 0.61× |
| memmem/subtitles/common/huge-zh-that | 37.520 | 47.505 | 0.79× |
| memmem/subtitles/never/huge-en-all-common-bytes | 15.850 | 14.720 | 1.08× |
| memmem/subtitles/never/huge-en-john-watson | 9.540 | 9.475 | 1.01× |
| memmem/subtitles/never/huge-en-some-rare-bytes | 9.490 | 9.395 | 1.01× |
| memmem/subtitles/never/huge-en-two-space | 9.555 | 8.315 | 1.15× |
| memmem/subtitles/never/huge-ru-john-watson | 9.560 | 9.835 | 0.97× |
| memmem/subtitles/never/huge-zh-john-watson | 10.950 | 10.445 | 1.05× |
| memmem/subtitles/never/teeny-en-all-common-bytes | 0.020 | 0.040 | 0.50× |
| memmem/subtitles/never/teeny-en-john-watson | 0.020 | 0.040 | 0.50× |
| memmem/subtitles/never/teeny-en-some-rare-bytes | 0.020 | 0.040 | 0.50× |
| memmem/subtitles/never/teeny-en-two-space | 0.020 | 0.040 | 0.50× |
| memmem/subtitles/never/teeny-ru-john-watson | 0.020 | 0.050 | 0.40× |
| memmem/subtitles/never/teeny-zh-john-watson | 0.020 | 0.040 | 0.50× |
| memmem/subtitles/rare/huge-en-huge-needle | 12.480 | 11.010 | 1.13× |
| memmem/subtitles/rare/huge-en-long-needle | 10.330 | 9.205 | 1.12× |
| memmem/subtitles/rare/huge-en-medium-needle | 11.625 | 11.450 | 1.02× |
| memmem/subtitles/rare/huge-en-sherlock | 9.805 | 10.020 | 0.98× |
| memmem/subtitles/rare/huge-en-sherlock-holmes | 9.815 | 9.570 | 1.03× |
| memmem/subtitles/rare/huge-ru-sherlock | 9.670 | 9.505 | 1.02× |
| memmem/subtitles/rare/huge-ru-sherlock-holmes | 9.520 | 9.530 | 1.00× |
| memmem/subtitles/rare/huge-zh-sherlock | 10.215 | 10.255 | 1.00× |
| memmem/subtitles/rare/huge-zh-sherlock-holmes | 10.700 | 11.020 | 0.97× |
| memmem/subtitles/rare/teeny-en-sherlock | 0.030 | 0.040 | 0.75× |
| memmem/subtitles/rare/teeny-en-sherlock-holmes | 0.040 | 0.040 | 1.00× |
| memmem/subtitles/rare/teeny-ru-sherlock | 0.030 | 0.060 | 0.50× |
| memmem/subtitles/rare/teeny-ru-sherlock-holmes | 0.030 | 0.060 | 0.50× |
| memmem/subtitles/rare/teeny-zh-sherlock | 0.030 | 0.040 | 0.75× |
| memmem/subtitles/rare/teeny-zh-sherlock-holmes | 0.040 | 0.050 | 0.80× |

### memmem/prebuilt

| Benchmark | Goostr (µs) | memchr (µs) | Ratio |
|---|---:|---:|---:|
| memmem/byterank/binary | 3330.000 | 8770.000 | 0.38× |
| memmem/code/rust-library-common-fn | 108.295 | 66.100 | 1.64× |
| memmem/code/rust-library-common-fn-is-empty | 30.040 | 28.940 | 1.04× |
| memmem/code/rust-library-common-let | 165.210 | 108.380 | 1.52× |
| memmem/code/rust-library-common-paren | 364.810 | 425.165 | 0.86× |
| memmem/code/rust-library-never-fn-quux | 26.030 | 25.525 | 1.02× |
| memmem/code/rust-library-never-fn-strength | 28.510 | 29.010 | 0.98× |
| memmem/code/rust-library-never-fn-strength-paren | 29.010 | 28.465 | 1.02× |
| memmem/code/rust-library-rare-fn-from-str | 29.015 | 30.155 | 0.96× |
| memmem/pathological/defeat-simple-vector-alphabet | 28.520 | 155.775 | 0.18× |
| memmem/pathological/defeat-simple-vector-freq-alphabet | 39.150 | 51.445 | 0.76× |
| memmem/pathological/defeat-simple-vector-repeated-alphabet | 61.025 | 1000.000 | 0.06× |
| memmem/pathological/md5-huge-last-hash | 4.620 | 3.225 | 1.43× |
| memmem/pathological/md5-huge-no-hash | 4.365 | 3.260 | 1.34× |
| memmem/pathological/rare-repeated-huge-match | 341.215 | 418.655 | 0.82× |
| memmem/pathological/rare-repeated-huge-tricky | 7.630 | 7.660 | 1.00× |
| memmem/pathological/rare-repeated-small-match | 0.560 | 0.860 | 0.65× |
| memmem/pathological/rare-repeated-small-tricky | 0.050 | 0.040 | 1.25× |
| memmem/sliceslice/i386 | 16310.000 | 14715.000 | 1.11× |
| memmem/sliceslice/seemingly-random | 185.220 | 113.315 | 1.63× |
| memmem/sliceslice/short | 7785.000 | 9705.000 | 0.80× |
| memmem/subtitles/common/huge-en-one-space | 459.515 | 657.675 | 0.70× |
| memmem/subtitles/common/huge-en-that | 43.885 | 25.770 | 1.70× |
| memmem/subtitles/common/huge-en-you | 99.220 | 59.385 | 1.67× |
| memmem/subtitles/common/huge-ru-not | 84.495 | 53.750 | 1.57× |
| memmem/subtitles/common/huge-ru-one-space | 364.765 | 340.155 | 1.07× |
| memmem/subtitles/common/huge-ru-that | 33.595 | 23.195 | 1.45× |
| memmem/subtitles/common/huge-zh-do-not | 68.845 | 44.220 | 1.56× |
| memmem/subtitles/common/huge-zh-one-space | 148.040 | 179.770 | 0.82× |
| memmem/subtitles/common/huge-zh-that | 30.745 | 22.265 | 1.38× |
| memmem/subtitles/never/huge-en-all-common-bytes | 16.785 | 15.110 | 1.11× |
| memmem/subtitles/never/huge-en-john-watson | 9.860 | 9.675 | 1.02× |
| memmem/subtitles/never/huge-en-some-rare-bytes | 9.370 | 9.630 | 0.97× |
| memmem/subtitles/never/huge-en-two-space | 9.470 | 8.490 | 1.12× |
| memmem/subtitles/never/huge-ru-john-watson | 9.460 | 9.400 | 1.01× |
| memmem/subtitles/never/huge-zh-john-watson | 10.690 | 10.690 | 1.00× |
| memmem/subtitles/never/teeny-en-all-common-bytes | 0.020 | 0.030 | 0.67× |
| memmem/subtitles/never/teeny-en-john-watson | 0.020 | 0.030 | 0.67× |
| memmem/subtitles/never/teeny-en-some-rare-bytes | 0.020 | 0.030 | 0.67× |
| memmem/subtitles/never/teeny-en-two-space | 0.020 | 0.030 | 0.67× |
| memmem/subtitles/never/teeny-ru-john-watson | 0.020 | 0.030 | 0.67× |
| memmem/subtitles/never/teeny-zh-john-watson | 0.020 | 0.030 | 0.67× |
| memmem/subtitles/rare/huge-en-huge-needle | 9.780 | 8.525 | 1.15× |
| memmem/subtitles/rare/huge-en-long-needle | 9.370 | 8.555 | 1.10× |
| memmem/subtitles/rare/huge-en-medium-needle | 11.350 | 11.200 | 1.01× |
| memmem/subtitles/rare/huge-en-sherlock | 10.060 | 9.775 | 1.03× |
| memmem/subtitles/rare/huge-en-sherlock-holmes | 9.610 | 9.460 | 1.02× |
| memmem/subtitles/rare/huge-ru-sherlock | 9.640 | 9.470 | 1.02× |
| memmem/subtitles/rare/huge-ru-sherlock-holmes | 9.445 | 9.415 | 1.00× |
| memmem/subtitles/rare/huge-zh-sherlock | 11.060 | 10.215 | 1.08× |
| memmem/subtitles/rare/huge-zh-sherlock-holmes | 10.695 | 10.965 | 0.98× |
| memmem/subtitles/rare/teeny-en-sherlock | 0.030 | 0.030 | 1.00× |
| memmem/subtitles/rare/teeny-en-sherlock-holmes | 0.030 | 0.030 | 1.00× |
| memmem/subtitles/rare/teeny-ru-sherlock | 0.030 | 0.030 | 1.00× |
| memmem/subtitles/rare/teeny-ru-sherlock-holmes | 0.020 | 0.030 | 0.67× |
| memmem/subtitles/rare/teeny-zh-sherlock | 0.030 | 0.040 | 0.75× |
| memmem/subtitles/rare/teeny-zh-sherlock-holmes | 0.030 | 0.040 | 0.75× |

### memrchr

| Benchmark | Goostr (µs) | memchr (µs) | Ratio |
|---|---:|---:|---:|
| memchr/sherlock/common/huge1 | 335.575 | 264.610 | 1.27× |
| memchr/sherlock/common/small1 | 0.250 | 0.290 | 0.86× |
| memchr/sherlock/common/tiny1 | 0.070 | 0.080 | 0.88× |
| memchr/sherlock/never/empty1 | 0.020 | 0.020 | 1.00× |
| memchr/sherlock/never/huge1 | 5.715 | 5.435 | 1.05× |
| memchr/sherlock/never/small1 | 0.030 | 0.030 | 1.00× |
| memchr/sherlock/never/tiny1 | 0.020 | 0.030 | 0.67× |
| memchr/sherlock/rare/huge1 | 7.290 | 7.065 | 1.03× |
| memchr/sherlock/rare/small1 | 0.030 | 0.035 | 0.86× |
| memchr/sherlock/rare/tiny1 | 0.020 | 0.040 | 0.50× |
| memchr/sherlock/uncommon/huge1 | 86.955 | 96.515 | 0.90× |
| memchr/sherlock/uncommon/small1 | 0.070 | 0.080 | 0.88× |
| memchr/sherlock/uncommon/tiny1 | 0.040 | 0.050 | 0.80× |
| memchr/sherlock/verycommon/huge1 | 507.125 | 523.065 | 0.97× |
| memchr/sherlock/verycommon/small1 | 0.575 | 0.605 | 0.95× |

### memrchr2

| Benchmark | Goostr (µs) | memchr (µs) | Ratio |
|---|---:|---:|---:|
| memchr/sherlock/common/huge2 | 464.820 | 437.410 | 1.06× |
| memchr/sherlock/common/small2 | 0.460 | 0.490 | 0.94× |
| memchr/sherlock/never/empty2 | 0.020 | 0.020 | 1.00× |
| memchr/sherlock/never/huge2 | 7.220 | 7.605 | 0.95× |
| memchr/sherlock/never/small2 | 0.030 | 0.030 | 1.00× |
| memchr/sherlock/never/tiny2 | 0.020 | 0.020 | 1.00× |
| memchr/sherlock/rare/huge2 | 10.070 | 12.125 | 0.83× |
| memchr/sherlock/rare/small2 | 0.040 | 0.050 | 0.80× |
| memchr/sherlock/rare/tiny2 | 0.030 | 0.050 | 0.60× |
| memchr/sherlock/uncommon/huge2 | 165.740 | 201.550 | 0.82× |
| memchr/sherlock/uncommon/small2 | 0.110 | 0.130 | 0.85× |
| memchr/sherlock/uncommon/tiny2 | 0.070 | 0.090 | 0.78× |

### memrchr3

| Benchmark | Goostr (µs) | memchr (µs) | Ratio |
|---|---:|---:|---:|
| memchr/sherlock/common/huge3 | 607.995 | 726.940 | 0.84× |
| memchr/sherlock/common/small3 | 0.780 | 0.770 | 1.01× |
| memchr/sherlock/never/empty3 | 0.020 | 0.020 | 1.00× |
| memchr/sherlock/never/huge3 | 9.055 | 9.440 | 0.96× |
| memchr/sherlock/never/small3 | 0.040 | 0.040 | 1.00× |
| memchr/sherlock/never/tiny3 | 0.020 | 0.030 | 0.67× |
| memchr/sherlock/rare/huge3 | 13.255 | 15.780 | 0.84× |
| memchr/sherlock/rare/small3 | 0.050 | 0.060 | 0.83× |
| memchr/sherlock/rare/tiny3 | 0.040 | 0.050 | 0.80× |
| memchr/sherlock/uncommon/huge3 | 268.950 | 256.055 | 1.05× |
| memchr/sherlock/uncommon/small3 | 0.180 | 0.200 | 0.90× |
| memchr/sherlock/uncommon/tiny3 | 0.110 | 0.125 | 0.88× |
