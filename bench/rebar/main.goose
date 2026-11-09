import bstr from "../..";
import simd_bytes from "github.com/sstadick/goose-simd@v0.2.0";
import os;

struct Benchmark {
    model: const u8[:],
    haystack: const u8[:],
    max_iters: i64,
    max_warmup_iters: i64,
    max_time: i64,
    max_warmup_time: i64,
    needles: u8[][>..],
}

struct Sample { duration: i64, count: i64 }

fn integer(s: const u8[:]) -> i64 {
    let n, ok = parse_int(s);
    assert(ok && n >= 0);
    return n;
}

// The input buffer stays alive until all benchmarks finish.
fn read_benchmark(raw: const u8[:]) -> Benchmark {
    var b = Benchmark {
        model: "", haystack: "", max_iters: 0, max_warmup_iters: 0,
        max_time: 0, max_warmup_time: 0, needles: [],
    };
    var pos = 0;
    while pos < raw.len {
        let colon = bstr::find_byte(raw[pos..], ':');
        assert(colon >= 0);
        let key = raw[pos..pos + colon];
        pos += colon + 1;
        let next = bstr::find_byte(raw[pos..], ':');
        assert(next >= 0);
        let len = integer(raw[pos..pos + next]);
        pos += next + 1;
        assert(len < raw.len - pos);
        let value = raw[pos..pos + len];
        pos += len;
        assert(raw[pos] == '\n');
        pos++;
        if key == "model" { b.model = value; }
        else if key == "pattern" { b.needles.push(bstr::unescape_bytes(value)); }
        else if key == "haystack" { b.haystack = value; }
        else if key == "max-iters" { b.max_iters = integer(value); }
        else if key == "max-warmup-iters" { b.max_warmup_iters = integer(value); }
        else if key == "max-time" { b.max_time = integer(value); }
        else if key == "max-warmup-time" { b.max_warmup_time = integer(value); }
    }
    return b;
}

// Mirrors benchmarks/shared/lib.rs::run_and_count: one operation per sample,
// setup and output outside timing, no additional black-box or FFI barrier.
fn run<F>(b: const Benchmark&) {
    let warmup_start = clock_ns();
    for _ in 0..b.max_warmup_iters {
        let count = F();
        assert(count >= 0);
        if clock_ns() - warmup_start >= b.max_warmup_time { break; }
    }
    var samples: Sample[>..] = [];
    let run_start = clock_ns();
    for _ in 0..b.max_iters {
        let start = clock_ns();
        let count = F();
        let duration = clock_ns() - start;
        samples.push(Sample { duration: duration, count: count });
        if clock_ns() - run_start >= b.max_time { break; }
    }
    for sample in samples { print(sample.duration, ",", sample.count); }
}

fn count_oneshot(s: const u8[:], needle: const u8[:]) -> i64 {
    var count = 0;
    var start = 0;
    while start <= s.len {
        let at = bstr::find(s[start..], needle);
        if at < 0 { break; }
        count++;
        start += at + max(1, needle.len);
    }
    return count;
}

fn count_prebuilt(s: const u8[:], f: const bstr::Finder&) -> i64 {
    var count = 0;
    var start = 0;
    while start <= s.len {
        let at = bstr::find(f, s[start..]);
        if at < 0 { break; }
        count++;
        start += at + max(1, f.needle.len);
    }
    return count;
}

fn count_byte(s: const u8[:], byte: u8) -> i64 {
    var count = 0;
    var start = 0;
    while start <= s.len {
        let at = bstr::find_byte(s[start..], byte);
        if at < 0 { break; }
        count++;
        start += at + 1;
    }
    return count;
}

fn count_byte_reverse(s: const u8[:], byte: u8) -> i64 {
    var count = 0;
    var end = s.len;
    while end >= 0 {
        let at = bstr::rfind_byte(s[..end], byte);
        if at < 0 { break; }
        count++;
        end = at;
    }
    return count;
}

fn count_set(s: const u8[:], set: const u8[:]) -> i64 {
    var count = 0;
    var start = 0;
    while start <= s.len {
        let at = bstr::find_byteset(s[start..], set);
        if at < 0 { break; }
        count++;
        start += at + 1;
    }
    return count;
}

fn count_set_reverse(s: const u8[:], set: const u8[:]) -> i64 {
    var count = 0;
    var end = s.len;
    while end >= 0 {
        let at = bstr::rfind_byteset(s[..end], set);
        if at < 0 { break; }
        count++;
        end = at;
    }
    return count;
}

fn main() {
    let argv = args();
    assert(argv.len == 2);
    let mode = argv[1];
    var raw: u8[>..] = [];
    read_stdin(raw);
    let b = read_benchmark(raw);
    let h = b.haystack;
    var needles: const u8[:][>..] = [];
    for n in b.needles { needles.push(n); }
    if b.model == "count" {
        assert(needles.len == 1);
        let n = needles[0];
        // Upstream's count_memmem does not advance on an empty needle.
        assert(n.len > 0);
        if mode == "memmem-oneshot" {
            run(b) { count_oneshot(h, n) }
        } else {
            assert(mode == "memmem-prebuilt");
            let f = bstr::finder(n);
            run(b) { count_prebuilt(h, f) }
        }
    } else if b.model == "count-bytes" {
        var set: u8[>..] = [];
        for n in b.needles { assert(n.len == 1); set.push(n[0]); }
        if mode == "memchr-oneshot" {
            assert(set.len == 1);
            let byte = set[0];
            run(b) { count_byte(h, byte) }
        } else if mode == "memrchr" {
            assert(set.len == 1);
            let byte = set[0];
            run(b) { count_byte_reverse(h, byte) }
        } else if mode == "memchr2" || mode == "memchr3" {
            assert(set.len == (if mode == "memchr2" { 2 } else { 3 }));
            run(b) { count_set(h, set) }
        } else {
            assert(mode == "memrchr2" || mode == "memrchr3");
            assert(set.len == (if mode == "memrchr2" { 2 } else { 3 }));
            run(b) { count_set_reverse(h, set) }
        }
    } else {
        assert(mode == "memmem-prebuilt");
        var finders: bstr::Finder[>..] = [];
        for n in needles { finders.push(bstr::finder(n)); }
        if b.model == "needles-in-needles" {
            run(b) {
                var count = 0;
                for i in 0..finders.len {
                    for j in i..needles.len {
                        if bstr::find(finders[i], needles[j]) >= 0 { count++; }
                    }
                }
                count
            }
        } else {
            assert(b.model == "needles-in-haystack");
            run(b) {
                var count = 0;
                for &f in finders { if bstr::find(f, h) >= 0 { count++; } }
                count
            }
        }
    }
}
