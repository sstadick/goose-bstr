// Differential-test driver. Input: hex haystack|hex needle|split limit.
import bstr from "..";
import simd_bytes from "github.com/sstadick/goose-simd@e11e34447d9b0f23f2fd0f63bc25f4aee838f175";
import os;

fn unhex(s: const u8[:]) -> u8[>..] {
    var out: u8[>..] = [];
    assert(s.len % 2 == 0);
    var i = 0;
    while i < s.len {
        let value, ok = parse_int(s[i..i + 2], 16);
        assert(ok);
        out.push(value as u8);
        i += 2;
    }
    return out;
}

fn hex(out: u8[>..]&, s: const u8[:]) {
    let digits = "0123456789abcdef";
    out.push('[');
    for b in s { out.push(digits[b >> 4]); out.push(digits[b & 15]); }
    out.push(']');
}

fn snapshot(s: const u8[:], needle: const u8[:], n: i64) {
    var out: u8[>..] = [];
    let cp, size, valid = bstr::decode_utf8(s);
    let rcp, rsize, rvalid = bstr::decode_last_utf8(s);
    let end, error = bstr::validate_utf8(s);
    format(out, cp, ",", size, ",", valid, ",", rcp, ",", rsize, ",", rvalid, ",", end, ",", error, "|");
    hex(out, bstr::to_str_lossy(s));
    hex(out, bstr::escape_bytes(s));
    hex(out, bstr::unescape_bytes(bstr::escape_bytes(s)));
    hex(out, bstr::unescape_bytes(bstr::to_str_lossy(s)));
    let ch, chsize = bstr::decode_utf8_lossy(needle);
    let scalar = if chsize == 0 { 0 } else { ch };
    format(out, bstr::find_char(s, scalar), ",", bstr::rfind_char(s, scalar), "|");
    hex(out, bstr::trim(s));
    hex(out, bstr::trim_start(s));
    hex(out, bstr::trim_end(s));
    hex(out, bstr::to_ascii_lowercase(s));
    hex(out, bstr::to_ascii_uppercase(s));
    var rev: u8[>..] = [];
    rev.append(s);
    bstr::reverse_chars(rev);
    hex(out, rev);
    out.push('|');
    bstr::char_indices(s) { a, b, cp => format(out, a, ",", b, ",", cp, ";"); }
    out.push('|');
    bstr::utf8_chunks(s) { good, bad => hex(out, good); hex(out, bad); }
    out.push('|');
    bstr::fields(s) { hex(out, it); }
    out.push('|');
    bstr::lines(s) { hex(out, it); }
    out.push('|');
    bstr::lines_with_terminator(s) { hex(out, it); }
    format(out, "|", bstr::find(s, needle), ",", bstr::rfind(s, needle), ",",
        bstr::find_byteset(s, needle), ",", bstr::rfind_byteset(s, needle), ",",
        bstr::find_not_byteset(s, needle), ",", bstr::rfind_not_byteset(s, needle), "|");
    bstr::find_iter(s, needle) { format(out, it, ","); }
    out.push('|');
    bstr::rfind_iter(s, needle) { format(out, it, ","); }
    out.push('|');
    bstr::split_str(s, needle) { hex(out, it); }
    out.push('|');
    bstr::rsplit_str(s, needle) { hex(out, it); }
    out.push('|');
    bstr::splitn_str(s, needle, n) { hex(out, it); }
    out.push('|');
    bstr::rsplitn_str(s, needle, n) { hex(out, it); }
    out.push('|');
    hex(out, bstr::replace(s, needle, "\xFF!"));
    hex(out, bstr::replacen(s, needle, "\xFF!", n));
    print(out);
}

fn main() {
    while true {
        var line: u8[>..] = [];
        if !read_line(line) { break; }
        let fields = split(line, '|');
        assert(fields.len == 3);
        let s = unhex(fields[0]);
        let needle = unhex(fields[1]);
        let n, ok = parse_int(fields[2]);
        assert(ok);
        snapshot(s, needle, n);
    }
}
