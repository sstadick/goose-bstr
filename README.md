# goose-bstr

Search, split, and transform byte strings in [Goose](https://github.com/aardappel/goose).
Use it for text or arbitrary bytes, including NUL and malformed UTF-8.
goose-bstr follows the core byte-string behavior of Rust's
[bstr](https://github.com/BurntSushi/bstr).

**[API reference and examples](API.md)** · [Releases](https://github.com/sstadick/goose-bstr/releases)

## Get started

Save this as `main.goose`. Goose downloads the packages; no local library
checkout is needed. Declare both imports in your program's root file:

```goose
import bstr from "github.com/sstadick/goose-bstr@main";
import simd_bytes from "github.com/sstadick/goose-simd@v0.2.0";

fn main() {
    let bytes = "name=goose\xFF\r\ncount=42\n";
    bstr::lines(bytes) { line =>
        let key, value, found = bstr::split_once_str(line, "=");
        if found { print(key, ": ", bstr::to_str_lossy(value)); }
    }
    print(bstr::replace("a\0b\0c", "\0", " / "));
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
imports to commits for reproducible builds. The goose-simd dependency is experimental.

## Find bytes and patterns

Search returns a **byte offset**, or **-1** when nothing matches. These
examples go inside `main()` with the imports above:

```goose
assert(bstr::find("café menu", "menu") == 6);
assert(bstr::rfind("ababa", "aba") == 2);
assert(bstr::find_byteset("name=value;", "=;") == 4);
assert(bstr::find("goose", "duck") == -1);
assert(bstr::find_char("café", 0xE9) == 3); // Unicode scalar, byte offset.

// Reuse a finder when searching for the same pattern in several inputs.
let f = bstr::finder("error");
assert(bstr::find(f, "an error occurred") == 3);
assert(bstr::find(f, "all clear") == -1);
```

Finders borrow their pattern. Keep its bytes alive and unchanged while using
the finder. An empty pattern matches every byte boundary, including both ends.

## Split and transform

Iterators call your block once per result. Splits, lines, fields, and trimming
return borrowed views: keep the input alive while using them.

```goose
var parts: const u8[:][>..] = [];
bstr::split_str("red,green,blue", ",") { part => parts.push(part); }
assert(parts.len == 3 && parts[1] == "green");

assert(bstr::trim(" \tgoose\r\n") == "goose");
assert(bstr::replace("one-two-three", "-", "/") == "one/two/three");

// Functions ending in _into append to your builder; they do not clear it.
var out: u8[>..] = [];
out.append("result: ");
bstr::replace_into("a-b", "-", "/", out);
assert(out == "result: a/b");
```

Use Goose's own byte arrays and builders: inputs are `const u8[:]`, mutable
operations take `u8[:]`, and owned results use `u8[>..]`. There is no extra
string wrapper to convert to or from.

## Work with imperfect text

Byte operations do not require UTF-8. When you need readable text, use lossy
conversion to replace malformed sequences with `�`, or validate first:

```goose
assert(!bstr::is_utf8("hello\xFF"));
assert(bstr::to_str_lossy("hello\xFF") == "hello�");

let end, error = bstr::validate_utf8("ok\xE2\x82");
assert(end == 2 && error == -1); // Incomplete UTF-8 after "ok".
```

For a printable representation that preserves arbitrary bytes, use
`escape_bytes`. Decode it with `unescape_bytes`:

```goose
let bytes = "line\n\xFF";
let escaped = bstr::escape_bytes(bytes);
assert(escaped == "line\\n\\xFF");
assert(bstr::unescape_bytes(escaped) == bytes);
assert(bstr::unescape_bytes("\\q") == "\\q"); // Unknown escapes stay literal.
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

In our tests we seem to be on par with bstr.

[Results from memchr's benchmark suite](bench/results/2026-11-02-rebar-clang/README.md)
include every matched comparison, raw measurements, and outliers.
See the [benchmark instructions](bench/rebar/README.md) for methodology,
limitations, and commands to repeat the run or include other native engines.

## Contributing

CI targets native Linux x86-64 and ARM64, macOS ARM64, and Windows x86-64.
Each job runs documentation examples, library tests, and comparisons with bstr.
Search tests cover native vector builds and forced-scalar builds; Linux x86-64
also tests explicit AVX2 when the runner supports it.

The CI compiler is pinned to Goose
[`4602c98660676b2cb94bc9b06fec8c65b37fce92`](https://github.com/aardappel/goose/commit/4602c98660676b2cb94bc9b06fec8c65b37fce92)
(`goose v2026.4-26-g4602c986`, runtime `d521138194f1`), built in Debug mode with
`-DGOOSE_BUILTIN_LIBS=`. Use that revision to reproduce CI; the historical
benchmark runner retains its own compiler pin for reproducibility.

This revision verifies the code executed by `checkfree` callers transitively;
callees do not need their own annotations. goose-bstr does not promise that
every operation can be called from a `checkfree` function: retained bounds or
slice checks still cause errors, and proof success can depend on optimization
level. `--no-bce` disables this verification and warns; it does not establish
the guarantee.

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
[goose-doc](https://github.com/sstadick/goose-doc/commit/f7292c9ee395596fa39eb709f90dc71ef124a0eb)
checked out at `../goose-doc`, run:

```sh
scripts/docs.sh
scripts/docs.sh --check
scripts/doctest.sh
scripts/doctest.sh --cc gcc
scripts/doctest.sh --cc clang
```

Set `GOOSE_DOC=/path/to/goose-doc/main.goose` for another location. Edit source
comments, not `API.md`. Every API declaration needs an executable example;
see the [example conventions](https://github.com/sstadick/goose-doc#executable-examples).
CI checks the reference and runs examples and tests before publishing releases.

## Migration from goostr

The repository is now [sstadick/goose-bstr](https://github.com/sstadick/goose-bstr).
Replace `import goostr from "github.com/sstadick/goostr@<ref>";` with
`import bstr from "github.com/sstadick/goose-bstr@<migration-or-later-ref>";`
and change `goostr::` to `bstr::`. The entry file is `bstr.goose`.
Function and type names are unchanged; owned-struct UFCS remains supported.
Old release tags retain the old entry file and namespace, so do not use the
new import identifier with a pre-migration revision. No compatibility wrapper
is provided.

Runtime dependencies use published release tags; published tags must not be
moved. Declare the same tag in root programs to avoid dependency-ref warnings.
`goose-bstr` releases before v0.3.0 retain the old namespace. Compiler and
documentation-tool CI pins remain exact commits. The documentation scripts use
`GOOSE_DOC`, defaulting to `../goose-doc/main.goose`.

- `goose-doc`: `f7292c9ee395596fa39eb709f90dc71ef124a0eb`
- `goose-simd`: `v0.2.0`

## License

MIT; see [LICENSE](LICENSE). goose-bstr adapts bstr and memchr code by Andrew
Gallant and contributors; their copyright notices are retained.
