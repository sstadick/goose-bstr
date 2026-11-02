# goostr

Search, split, and transform byte strings in [Goose](https://github.com/aardappel/goose).
Use it for text or arbitrary bytes, including NUL and malformed UTF-8.
goostr follows the core byte-string behavior of Rust's
[bstr](https://github.com/BurntSushi/bstr).

**[API reference and examples](API.md)** · [Releases](https://github.com/sstadick/goostr/releases)

## Get started

Save this as `main.goose`. Goose downloads the packages; no local library
checkout is needed. Declare both imports in your program's root file:

```goose
import goostr from "github.com/sstadick/goostr@main";
import goosimd from "github.com/sstadick/goosimd@main";

fn main() {
    let bytes = "name=goose\xFF\r\ncount=42\n";
    goostr::lines(bytes) { line =>
        let key, value, found = goostr::split_once_str(line, "=");
        if found { print(key, ": ", goostr::to_str_lossy(value)); }
    }
    print(goostr::replace("a\0b\0c", "\0", " / "));
}
```

```sh
goose run main.goose
# name: goose�
# count: 42
# a / b / c

goose build main.goose -O2 -o demo
```

Use a Goose compiler with package `c_headers` support. TinyCC works without
an external C compiler; native builds use GCC, Clang, or MSVC. CI covers Linux
x86-64 and ARM64, macOS ARM64, and Windows x86-64. The examples follow `main`; pin
imports to commits for reproducible builds. The goosimd dependency is experimental.

## Find bytes and patterns

Search returns a **byte offset**, or **-1** when nothing matches. These
examples go inside `main()` with the imports above:

```goose
assert(goostr::find("café menu", "menu") == 6);
assert(goostr::rfind("ababa", "aba") == 2);
assert(goostr::find_byteset("name=value;", "=;") == 4);
assert(goostr::find("goose", "duck") == -1);
assert(goostr::find_char("café", 0xE9) == 3); // Unicode scalar, byte offset.

// Reuse a finder when searching for the same pattern in several inputs.
let f = goostr::finder("error");
assert(goostr::find(f, "an error occurred") == 3);
assert(goostr::find(f, "all clear") == -1);
```

Finders borrow their pattern. Keep its bytes alive and unchanged while using
the finder. An empty pattern matches every byte boundary, including both ends.

## Split and transform

Iterators call your block once per result. Splits, lines, fields, and trimming
return borrowed views: keep the input alive while using them.

```goose
var parts: const u8[:][>..] = [];
goostr::split_str("red,green,blue", ",") { part => parts.push(part); }
assert(parts.len == 3 && parts[1] == "green");

assert(goostr::trim(" \tgoose\r\n") == "goose");
assert(goostr::replace("one-two-three", "-", "/") == "one/two/three");

// Functions ending in _into append to your builder; they do not clear it.
var out: u8[>..] = [];
out.append("result: ");
goostr::replace_into("a-b", "-", "/", out);
assert(out == "result: a/b");
```

Use Goose's own byte arrays and builders: inputs are `const u8[:]`, mutable
operations take `u8[:]`, and owned results use `u8[>..]`. There is no extra
string wrapper to convert to or from.

## Work with imperfect text

Byte operations do not require UTF-8. When you need readable text, use lossy
conversion to replace malformed sequences with `�`, or validate first:

```goose
assert(!goostr::is_utf8("hello\xFF"));
assert(goostr::to_str_lossy("hello\xFF") == "hello�");

let end, error = goostr::validate_utf8("ok\xE2\x82");
assert(end == 2 && error == -1); // Incomplete UTF-8 after "ok".
```

For a printable representation that preserves arbitrary bytes, use
`escape_bytes`. Decode it with `unescape_bytes`:

```goose
let bytes = "line\n\xFF";
let escaped = goostr::escape_bytes(bytes);
assert(escaped == "line\\n\\xFF");
assert(goostr::unescape_bytes(escaped) == bytes);
assert(goostr::unescape_bytes("\\q") == "\\q"); // Unknown escapes stay literal.
```

`unescape_bytes` recognizes `\0`, `\n`, `\r`, `\t`, `\\`, and `\xHH`.
It does not decode Unicode escapes such as `\u{1234}`.

## Choose an operation

| Task | Start with |
| --- | --- |
| Search forward or backward | `find`, `rfind`, `finder`, `finder_reverse` |
| Search for individual bytes or a set | `find_byte`, `find_byteset`, `find_not_byteset` and their reverse variants |
| Search for a Unicode codepoint | `find_char`, `rfind_char` (return byte offsets) |
| Iterate matches or split input | `find_iter`, `split_str`, `splitn_str`, `split_once_str` |
| Replace or repeat bytes | `replace`, `replacen`, `replace_into`, `repeatn` |
| Read lines or words | `lines`, `lines_with_terminator`, `fields` |
| Trim text | `trim`, `trim_start`, `trim_end`, `trim_with` |
| Decode or validate UTF-8 | `chars`, `char_indices`, `utf8_chunks`, `validate_utf8`, `to_str_lossy` |
| Change or inspect bytes | `is_ascii`, `to_ascii_lowercase`, `reverse_bytes`, `reverse_chars`, `escape_bytes` |
| Decode escaped bytes | `unescape_bytes` |

See the [API reference](API.md) for all signatures and examples. A few rules
are worth knowing before choosing an operation:

- Matches from iterators, splitting, and replacement do not overlap. Forward
  and reverse searches can therefore choose different matches.
- `splitn_str` limits pieces; `replacen` limits replacements.
- Lines end at LF or CRLF, not a bare CR. A final terminator adds no extra line.
- Trimming and fields recognize Unicode whitespace. ASCII case conversion
  changes only ASCII letters.
- `reverse_chars` reverses codepoints, not grapheme clusters. Unicode case
  mapping and grapheme/word/sentence segmentation are not provided.

This is not the complete bstr API, and performance parity is not guaranteed.
For optimized native searches, build with GCC or Clang. Clang on x86-64
selects supported SIMD instructions at runtime for long scans; short searches
and early matches avoid dispatch. GCC uses the build target, and TinyCC uses
scalar code. To enable runtime selection:

```sh
goose build main.goose --cc clang -O2 -o demo
```

Goose's runtime AVX2 selection also requires FMA, BMI1/2, LZCNT, POPCNT, and
OS support. Compiling emitted C with `-DGS_SIMD=0` disables runtime selection;
adding `-mavx2` selects AVX2 at compile time and requires an AVX2 CPU.

## Search performance

**We do not claim that goostr is faster than bstr.** These are the workloads
we have benchmarked so far, not a representative comparison of the libraries.
Results depend on the input, hardware, compiler, and build settings; measure
your own workload before drawing conclusions.

These warm-cache measurements were taken on November 2, 2026, on a Ryzen 9
3950X running Linux x86-64. They compare goostr with bstr 1.13.1 (memchr 2.8.3).
Goostr uses a clean checkout of Goose
[`eadca40`](https://github.com/aardappel/goose/commit/eadca409f68210893f366e60d0c2f0dc29a339be)
and Clang 18.1.3; bstr uses Rust 1.97.1. Native C and Rust builds use
optimization level 3, with runtime SIMD selection and AVX2 available.

Both runners use identical inputs and inline black-box barriers:
`std::hint::black_box` in Rust and empty, memory-clobbering assembly in Goose.
They warm up before timing, rotate execution order, check results, and run on CPU 4.
File I/O and process startup are excluded. Prepared searches exclude finder
construction on both sides. Counts use repeated one-shot searches, including
finder construction, and do not count overlapping matches.

**Ratio = goostr / bstr; lower is better for goostr.** Times below are medians
of nine batches calibrated to at least 50 ms. These are selected workloads, not an
overall score.

| Input / scenario | Operation | goostr | bstr | Ratio |
| --- | --- | ---: | ---: | ---: |
| English subtitles, `you` needle | forward count | 141.25 µs | 220.73 µs | 0.64× |
| Upstream adversarial alphabet, `qbz` needle | forward count | 28.10 µs | 155.84 µs | 0.18× |
| 31.8 MiB ripgrep executable, five-byte needle | forward count | 3.28 ms | 9.04 ms | 0.36× |
| Same executable and needle | reverse count | 3.39 ms | 14.77 ms | 0.23× |
| 1 MiB + 2 KiB, long-needle near-match miss | prepared `find` | 17.40 µs | 20.61 µs | 0.84× |
| 1 MiB repeated `a`, needle `a` × 255 + `b` | prepared `find` | 96.38 µs | 1,677.70 µs | 0.06× |
| 1 MiB repeated `zza`, 116-byte needle miss | prepared `find` | 30.68 µs | 30.55 µs | 1.00× |
| Same input and needle | prepared `rfind` | 482.92 µs | 792.72 µs | 0.61× |
| Same, needle appended at end | prepared `find` | 30.80 µs | 31.87 µs | 0.97× |
| Same, needle appended at end | reverse count | 403.90 µs | 807.24 µs | 0.50× |

[Raw measurements](bench/results/2026-11-02-clang-reverse.json) and the
[prepared reverse search](bench/results/2026-11-02-clang-reverse-prepared.json)
include individual samples, input and source hashes, and toolchain details.

## Contributing

CI targets native Linux x86-64 and ARM64, macOS ARM64, and Windows x86-64.
Each job runs documentation examples, library tests, and comparisons with bstr.
Search tests cover native vector builds and forced-scalar builds; Linux x86-64
also tests explicit AVX2 when the runner supports it.

Run the library tests from this checkout with your installed C compilers:

```sh
python3 tests/run.py --cc gcc clang
python3 tests/differential.py
```

Use `--cc clang` on macOS or `--cc msvc clang-cl` on Windows. The test runner
also exercises TinyCC and keeps generated executables in a temporary directory.

The bstr comparison requires Python 3, Cargo, and a native C compiler.
Compare search performance against bstr with the same inputs and checked results:

```sh
python3 bench/compare.py --cc clang --target runtime --suite substring --output substring.json
python3 bench/compare.py --cc clang --target runtime --suite byteset --output byteset.json
python3 bench/compare.py --cc clang --target runtime --suite boundary --output boundary.json
```

The boundary suite covers lengths around scalar/SIMD and search-algorithm
cutoffs. Use `--target avx2` only on a capable CPU, `--case 'tiny-*'` to select
cases, or `--baseline-exe` to compare with a previously built version. Timings
exclude file I/O, include a warm-up pass, and retain individual samples and
compiler/CPU details in JSON. Pin the benchmark to one CPU where possible;
run compiler/target comparisons sequentially. See `--help` for other options.

Use `--barrier external` to compare with a separately compiled C barrier in
both runners. Barrier choice can affect inlining and code layout, not just
call overhead. Prebuilt executables must use the same barrier as the comparison.

The runner builds native C and Rust code at optimization level 3. Goose's
separate `-O2` option selects its maximum inlining level; it does not limit the
native C compiler to `-O2`. For longer measurements on Linux, use:

```sh
taskset -c 4 python3 bench/compare.py \
  --cc clang --target runtime --suite substring --samples 9 --sample-ms 50 \
  --output substring-o3.json
```

Repeat with `--suite byteset` or `--suite boundary` for those operations.
Choose an available CPU on your machine. The runner explicitly sets Cargo's
release optimization level to 3, even if your environment selects another level.

### Upstream search corpora

The `upstream` suite uses all 54 single-literal count cases from
[memchr 2.8.3](https://github.com/BurntSushi/memchr/tree/5fdb40c054e1fff359a2f7bdf7f87a13b34b465d/benchmarks/definitions/memmem):
English, Russian, and Chinese OpenSubtitles, Rust library source, a ripgrep
executable, and pathological inputs. It reads the original files and patterns,
checks upstream's expected occurrence counts, and records their provenance and
hashes in the results. Corpus files stay in their upstream checkout rather than
being redistributed here. Requires Python 3.11+.

```sh
git clone --depth 1 --branch 2.8.3 https://github.com/BurntSushi/memchr ../memchr-bench
taskset -c 4 python3 bench/compare.py \
  --suite upstream --memchr-checkout ../memchr-bench --cc clang --target runtime \
  --samples 9 --sample-ms 50 --output upstream.json
```

`count` repeats one-shot forward searches for non-overlapping matches, following
memchr's one-shot count model; `rcount` is its reverse adaptation. Finder setup
is included in each one-shot search. The four `find`/`rfind` modes instead measure
the first or last match on the same inputs: they are **adapted workloads**, not
upstream count timings. Prepared modes exclude finder construction. Use
`--modes count rcount` or `--case 'subtitles/*'` to select a subset.

This is a library comparison, not a ripgrep benchmark. It excludes filesystem
traversal, regex matching, output formatting, and I/O, and does not reproduce
memchr's multi-needle `sliceslice` workloads. Large speedups on pathological
inputs alone do not establish an advantage on real-world text.

The `records` suite uses the dictionary-derived input from Georg Sauthoff's
[std::find() and memchr() Optimizations](https://gms.tf/stdfind-and-memchr-optimizations.html):
14,972 variable-length records, each containing a pipe delimiter. Both runners
find each newline, then the first pipe within that record, and check a checksum
of the prefix lengths. This exercises short, unaligned searches. It is an
**in-memory adaptation**: unlike the article, it does not time 128 KiB file
reads or printing. The corpus is hash-checked and is not production data.

```sh
git clone https://github.com/gsauthof/find-memchr ../find-memchr-bench
git -C ../find-memchr-bench checkout 6b0e99b54c9b60b9aaf615d33437a8139162524f
taskset -c 4 python3 bench/compare.py \
  --suite records --record-corpus ../find-memchr-bench/in.gz \
  --cc clang --target runtime --samples 9 --sample-ms 50 --output records.json
```

### API documentation

API documentation comes from source comments. With
[goosdoc v0.2.0](https://github.com/sstadick/goosdoc/releases/tag/v0.2.0)
checked out at `../goosdoc`, run:

```sh
scripts/docs.sh
scripts/docs.sh --check
scripts/doctest.sh
scripts/doctest.sh --cc gcc
scripts/doctest.sh --cc clang
```

Set `GOOSDOC=/path/to/goosdoc/main.goose` for another location. Edit source
comments, not `API.md`. Every API declaration needs an executable example;
see the [example conventions](https://github.com/sstadick/goosdoc#executable-examples).
CI checks the reference and runs examples and tests before publishing releases.

## License

MIT; see [LICENSE](LICENSE). goostr adapts bstr and memchr code by Andrew
Gallant and contributors; their copyright notices are retained.
