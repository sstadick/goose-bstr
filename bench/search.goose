import bstr from "..";
import simd_bytes from "github.com/sstadick/goose-simd@v0.2.0";
import os;

// Hide input lengths from the optimizer on every timed iteration.
extern fn opaque_len(s: const u8[:]) -> i64 = "goostr_bench_opaque_len";
extern fn setup() -> i64 = "goostr_bench_setup";
fn opaque(s: const u8[:]) -> const u8[:] { s[..opaque_len(s)] }

// Non-overlapping counts using one-shot search, matching memchr's count model.
fn count_matches(s: const u8[:], needle: const u8[:]) -> i64 {
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

fn count_reverse(s: const u8[:], needle: const u8[:]) -> i64 {
    var count = 0;
    var end = s.len;
    while end >= 0 {
        let at = bstr::rfind(s[..end], needle);
        if at < 0 { break; }
        count++;
        end = at - (if needle.len == 0 { 1 } else { 0 });
    }
    return count;
}

// In-memory record parsing: find each newline, then its first pipe delimiter.
fn record_prefixes(s: const u8[:]) -> i64 {
    var checksum = 0;
    var start = 0;
    while start < s.len {
        let newline = bstr::find_byte(s[start..], 10);
        let end = if newline < 0 { s.len } else { start + newline };
        checksum += bstr::find_byte(s[start..end], 124) + 1;
        start = end + 1;
    }
    return checksum;
}

fn main() {
    assert(setup() == 0);
    let argv = args();
    assert(argv.len == 5);
    var haystack: u8[>..] = [];
    var needle: u8[>..] = [];
    assert(read_file(argv[1], haystack));
    assert(read_file(argv[2], needle));
    let iterations, ok = parse_int(argv[4]);
    assert(ok && iterations > 0);
    var checksum = 0;
    var elapsed = 0;
    let forward = bstr::finder(needle);
    let reverse = bstr::finder_reverse(needle);
    // Discard one full pass to warm code/data and reduce CPU ramp-up noise.
    for pass in 2 {
        checksum = 0;
        let start = clock_ns();
        if argv[3] == "find" {
            for i in iterations { checksum += bstr::find(opaque(haystack), opaque(needle)) + 1; }
        } else if argv[3] == "count" {
            for i in iterations { checksum += count_matches(opaque(haystack), opaque(needle)) + 1; }
        } else if argv[3] == "rcount" {
            for i in iterations { checksum += count_reverse(opaque(haystack), opaque(needle)) + 1; }
        } else if argv[3] == "records" {
            for i in iterations { checksum += record_prefixes(opaque(haystack)) + 1; }
        } else if argv[3] == "prepared-find" {
            for i in iterations { checksum += bstr::find(forward, opaque(haystack)) + 1; }
        } else if argv[3] == "prepared-rfind" {
            for i in iterations { checksum += bstr::rfind(reverse, opaque(haystack)) + 1; }
        } else if argv[3] == "find-set" {
            for i in iterations { checksum += bstr::find_byteset(opaque(haystack), opaque(needle)) + 1; }
        } else if argv[3] == "rfind-set" {
            for i in iterations { checksum += bstr::rfind_byteset(opaque(haystack), opaque(needle)) + 1; }
        } else if argv[3] == "find-not-set" {
            for i in iterations { checksum += bstr::find_not_byteset(opaque(haystack), opaque(needle)) + 1; }
        } else if argv[3] == "rfind-not-set" {
            for i in iterations { checksum += bstr::rfind_not_byteset(opaque(haystack), opaque(needle)) + 1; }
        } else {
            assert(argv[3] == "rfind");
            for i in iterations { checksum += bstr::rfind(opaque(haystack), opaque(needle)) + 1; }
        }
        elapsed = clock_ns() - start;
    }
    print(elapsed, " ", checksum);
}
