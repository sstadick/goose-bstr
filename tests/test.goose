import bstr from "..";
import simd_bytes from "github.com/sstadick/goose-simd@e11e34447d9b0f23f2fd0f63bc25f4aee838f175";

// Slice elements compare by identity in this Goose release. Check bytes.
fn expect_parts(actual: const u8[:][:], expected: const u8[:][:]) {
    assert(actual.len == expected.len);
    for part, i in actual { assert(part == expected[i]); }
}

fn search() {
    assert(bstr::find("ab\0aba\xFF", "aba") == 3);
    assert(bstr::rfind("ababa", "aba") == 2);
    assert(bstr::find("ab", "abc") == -1);
    assert(bstr::rfind("ab", "abc") == -1);
    assert(bstr::find("abc", "") == 0);
    assert(bstr::rfind("abc", "") == 3);
    assert(bstr::find("", "") == 0);
    assert(bstr::contains_str("a\xFFb", "\xFF"));
    assert(!bstr::contains_str("abc", "d"));
    assert(bstr::starts_with_str("abc", "ab"));
    assert(!bstr::starts_with_str("ab", "abc"));
    assert(bstr::ends_with_str("abc", "bc"));
    assert(!bstr::ends_with_str("abc", "ab"));
    assert(bstr::find_byte("\0x\0", 0) == 0);
    assert(bstr::rfind_byte("\0x\0", 0) == 2);
    assert(bstr::find_byte("", 0) == -1);
    assert(bstr::rfind_byte("abc", 0) == -1);
    let points = [0, 0x7F, 0x80, 0x7FF, 0x800, 0xD7FF, 0xE000, 0xFFFF, 0x10000, 0x10FFFF];
    let encoded = ["\0", "\x7F", "\xC2\x80", "\xDF\xBF", "\xE0\xA0\x80",
        "\xED\x9F\xBF", "\xEE\x80\x80", "\xEF\xBF\xBF", "\xF0\x90\x80\x80", "\xF4\x8F\xBF\xBF"];
    for cp, i in points {
        var s: u8[>..] = [];
        s.append("!\xFF"); s.append(encoded[i]); s.append("??"); s.append(encoded[i]);
        assert(bstr::find_char(s, cp) == 2);
        assert(bstr::rfind_char(s, cp) == 4 + encoded[i].len);
        assert(bstr::find_char("", cp) == -1);
        assert(bstr::rfind_char("", cp) == -1);
    }
    assert(bstr::find_char("\xFF�\xFE�", 0xFFFD) == 1);
    assert(bstr::rfind_char("\xFF�\xFE�", 0xFFFD) == 5);
    assert(bstr::find_char("\xFF", 0xFFFD) == -1);
    assert(bstr::rfind_char("\xFF", 0xFFFD) == -1);
    assert(bstr::find_byteset("abc\xFFx", "x\xFF") == 3);
    assert(bstr::rfind_byteset("abc\xFFx", "x\xFF") == 4);
    assert(bstr::find_not_byteset("aaab", "a") == 3);
    assert(bstr::rfind_not_byteset("baaa", "a") == 0);
    assert(bstr::find_byteset("abc", "") == -1);
    assert(bstr::find_not_byteset("abc", "") == 0);
    assert(bstr::rfind_not_byteset("abc", "") == 2);
    assert(bstr::rfind_byteset("", "a") == -1);
    assert(bstr::find_not_byteset("aaa", "a") == -1);
    var forward: i64[>..] = [];
    bstr::find_iter("ababa", "aba") { forward.push(it); }
    assert(forward == [0]);
    var backward: i64[>..] = [];
    bstr::rfind_iter("ababa", "aba") { backward.push(it); }
    assert(backward == [2]);
    var empty: i64[>..] = [];
    bstr::rfind_iter("é", "") { empty.push(it); }
    assert(empty == [2, 1, 0]);
}

fn splitting() {
    var parts: const u8[:][>..] = [];
    bstr::split_str("|a||b|", "|") { parts.push(it); }
    expect_parts(parts, ["", "a", "", "b", ""]);
    var reverse: const u8[:][>..] = [];
    bstr::rsplit_str("ababa", "aba") { reverse.push(it); }
    expect_parts(reverse, ["", "ab"]);
    var bytes: const u8[:][>..] = [];
    bstr::split_str("é", "") { bytes.push(it); }
    expect_parts(bytes, ["", "\xC3", "\xA9", ""]);
    var revbytes: const u8[:][>..] = [];
    bstr::rsplit_str("é", "") { revbytes.push(it); }
    expect_parts(revbytes, ["", "\xA9", "\xC3", ""]);
    var blank: const u8[:][>..] = [];
    bstr::split_str("", "") { blank.push(it); }
    expect_parts(blank, ["", ""]);
    var limited: const u8[:][>..] = [];
    bstr::splitn_str("a:b:c", ":", 2) { limited.push(it); }
    expect_parts(limited, ["a", "b:c"]);
    var revlimited: const u8[:][>..] = [];
    bstr::rsplitn_str("a:b:c", ":", 2) { revlimited.push(it); }
    expect_parts(revlimited, ["c", "a:b"]);
    var n = 0;
    bstr::splitn_str("a:b", ":", 0) { n += 1; }
    bstr::rsplitn_str("a:b", ":", 0) { n += 1; }
    assert(n == 0);
    bstr::splitn_str("a:b", ":", 1) { assert(it == "a:b"); n += 1; }
    assert(n == 1);
    let left, right, found = bstr::split_once_str("a=b=c", "=");
    assert(found && left == "a" && right == "b=c");
    let rl, rr, rf = bstr::rsplit_once_str("a=b=c", "=");
    assert(rf && rl == "a=b" && rr == "c");
    let nl, nr, nf = bstr::split_once_str("abc", "!");
    assert(!nf && nl.len == 0 && nr.len == 0);
    let el, er, ef = bstr::rsplit_once_str("abc", "");
    assert(ef && el == "abc" && er == "");
}

fn replacement() {
    assert(bstr::replace("ababa", "aba", "X") == "Xba");
    assert(bstr::replace("a\0b", "\0", "\xFF") == "a\xFFb");
    assert(bstr::replace("é", "", "-") == "-\xC3-\xA9-");
    assert(bstr::replace("", "", "X") == "X");
    assert(bstr::replace("abc", "b", "") == "ac");
    assert(bstr::replacen("aaa", "a", "bb", 2) == "bbbba");
    assert(bstr::replacen("abc", "", "-", 2) == "-a-bc");
    assert(bstr::replacen("abc", "", "-", 0) == "abc");
    var out: u8[>..] = [];
    out.append("prefix:");
    bstr::replace_into("a:a", ":", "=", out);
    bstr::replacen_into("bab", "b", "!", 1, out);
    assert(out == "prefix:a=a!ab");
    assert(bstr::repeatn("a\xFF", 3) == "a\xFFa\xFFa\xFF");
    assert(bstr::repeatn("abc", 0) == "");
    assert(bstr::repeatn("", 100) == "");
}

fn text() {
    var lines: const u8[:][>..] = [];
    bstr::lines("a\r\n\nb\rc\nlast\r") { lines.push(it); }
    expect_parts(lines, ["a", "", "b\rc", "last\r"]);
    var terminated: const u8[:][>..] = [];
    bstr::lines_with_terminator("a\r\n\nb\n") { terminated.push(it); }
    expect_parts(terminated, ["a\r\n", "\n", "b\n"]);
    var n = 0;
    bstr::lines("") { n += 1; }
    assert(n == 0);
    bstr::lines("\n") { assert(it == ""); n += 1; }
    assert(n == 1);
    assert(bstr::trim("\x0B\x0C \xFF雪　\n") == "\xFF雪");
    assert(bstr::trim("\xFF x \xFF") == "\xFF x \xFF");
    assert(bstr::trim("​x​") == "​x​"); // U+200B is NOT White_Space.
    assert(bstr::trim_start(" x ") == "x ");
    assert(bstr::trim_end(" x　") == " x");
    assert(bstr::trim_with("\xE2\x98x\xFF") { it == 0xFFFD } == "x");
    var fields: const u8[:][>..] = [];
    bstr::fields(" \x0Bα \xFF　beta\r\n") { fields.push(it); }
    expect_parts(fields, ["α", "\xFF", "beta"]);
    var custom: const u8[:][>..] = [];
    fn separator(cp: i64) -> bool { cp == ',' || cp == 0xFFFD }
    bstr::fields_with(",a\xE2\x98b,,", separator) { custom.push(it); }
    expect_parts(custom, ["a", "b"]);
    assert(bstr::is_ascii("a\0\x7F"));
    assert(!bstr::is_ascii("é"));
    assert(bstr::find_non_ascii_byte("ab\xFF") == 2);
    assert(bstr::to_ascii_lowercase("AZ[É\xFF") == "az[É\xFF");
    assert(bstr::to_ascii_uppercase("az{é\xFF") == "AZ{é\xFF");
    var lower: u8[258] = [0; 258];
    var upper: u8[258] = [0; 258];
    for i in 256 { lower[i + 1] = i as u8; upper[i + 1] = i as u8; }
    lower[0] = 'A'; lower[257] = 'Z';
    upper[0] = 'a'; upper[257] = 'z';
    bstr::make_ascii_lowercase(lower[1..257]);
    bstr::make_ascii_uppercase(upper[1..257]);
    for i in 256 {
        assert(lower[i + 1] == (if i >= 65 && i <= 90 { i + 32 } else { i }) as u8);
        assert(upper[i + 1] == (if i >= 97 && i <= 122 { i - 32 } else { i }) as u8);
    }
    bstr::make_ascii_lowercase(lower[1..1]);
    bstr::make_ascii_uppercase(upper[1..1]);
    assert(lower[0] == 'A' && lower[257] == 'Z');
    assert(upper[0] == 'a' && upper[257] == 'z');
    var mutable: u8[>..] = [];
    mutable.append("aZ\xFF");
    bstr::make_ascii_uppercase(mutable);
    assert(mutable == "AZ\xFF");
    bstr::make_ascii_lowercase(mutable);
    assert(mutable == "az\xFF");
    bstr::reverse_bytes(mutable);
    assert(mutable == "\xFFza");
    assert(bstr::escape_bytes(" é\xFF\0\t\r\n\\\"\x7F") == "\\x20é\\xFF\\0\\t\\r\\n\\\\\"\\x7F");
    assert(bstr::unescape_bytes("\\0\\n\\r\\t\\\\\\x00\\x9F\\xaB") == "\0\n\r\t\\\0\x9F\xAB");
    for s in ["", "\\", "\\x", "\\xA", "\\xZ", "\\xZZ", "\\q", "\\u{2603}", "café\xFF"] {
        assert(bstr::unescape_bytes(s) == s);
    }
    // A backslash consumed by a malformed hex escape must not start another escape.
    assert(bstr::unescape_bytes("\\x\\n") == "\\x\\n");
    assert(bstr::unescape_bytes("\\xA\\n") == "\\xA\\n");
    assert(bstr::unescape_bytes("\\xZ\\n") == "\\xZ\n");
    assert(bstr::unescape_bytes("\\xé\\n") == "\\xé\n");
    var all: u8[256] = [0; 256];
    for i in 256 { all[i] = i as u8; }
    assert(bstr::unescape_bytes(bstr::escape_bytes(all)) == all);
}

fn utf8() {
    assert(bstr::is_utf8("aé雪🦆�"));
    assert(bstr::is_utf8(""));
    assert(!bstr::is_utf8("\xED\xA0\x80"));
    assert(!bstr::is_utf8("\xF4\x90\x80\x80"));
    assert(!bstr::is_utf8("\xC0\x80"));
    let cp, size, valid = bstr::decode_utf8("\xE2\x98!");
    assert(cp == 0xFFFD && size == 2 && !valid);
    let last, lastsize, lastvalid = bstr::decode_last_utf8("a\xE2\x98");
    assert(last == 0xFFFD && lastsize == 2 && !lastvalid);
    let repl, replsize, replvalid = bstr::decode_utf8("�");
    assert(repl == 0xFFFD && replsize == 3 && replvalid);
    let a, b = bstr::decode_utf8_lossy("🦆");
    assert(a == 0x1F986 && b == 4);
    let c, d = bstr::decode_last_utf8_lossy("xé");
    assert(c == 0xE9 && d == 2);
    let end, error = bstr::validate_utf8("ok\xF0\x90\x80");
    assert(end == 2 && error == -1);
    let end2, error2 = bstr::validate_utf8("ok\xF0\x90!");
    assert(end2 == 2 && error2 == 2);
    let end3, error3 = bstr::validate_utf8("\xFF");
    assert(end3 == 0 && error3 == 1);
    assert(bstr::to_str_lossy("a\xE2\x98!\xED\xA0\x80") == "a�!���");
    var out: u8[>..] = [];
    out.append("prefix:");
    bstr::to_str_lossy_into("\xFFé", out);
    assert(out == "prefix:�é");
    var indices: i64[>..] = [];
    bstr::char_indices("aé\xE2\x98!") { start, end, cp =>
        indices.push(start); indices.push(end); indices.push(cp);
    }
    assert(indices == [0, 1, 97, 1, 3, 233, 3, 5, 65533, 5, 6, 33]);
    var points: i64[>..] = [];
    bstr::chars("é\xFF") { points.push(it); }
    assert(points == [233, 65533]);
    var chunks: const u8[:][>..] = [];
    bstr::utf8_chunks("a\xE2\x98!\xFFé") { valid, invalid =>
        chunks.push(valid); chunks.push(invalid);
    }
    expect_parts(chunks, ["a", "\xE2\x98", "!", "\xFF", "é", ""]);
    var reversed: u8[>..] = [];
    reversed.append("a☃\xE2\x98!");
    bstr::reverse_chars(reversed);
    assert(reversed == "!\xE2\x98☃a");
}

// A caller can stop any callback iterator with a non-local return.
fn first_field(s: const u8[:]) -> const u8[:] {
    bstr::fields(s) { return it; }
    return s[..0];
}

fn main() {
    search();
    splitting();
    replacement();
    text();
    utf8();
    assert(first_field(" a b ") == "a");
    print("goose-bstr tests passed");
}
