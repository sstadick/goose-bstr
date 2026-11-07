import bstr from "..";
import simd_bytes from "github.com/sstadick/goose-simd@e11e34447d9b0f23f2fd0f63bc25f4aee838f175";

fn main() {
    let data = "  name=goose\xFF\r\n  count=42\n";
    bstr::lines(data) { line =>
        let key, value, found = bstr::split_once_str(bstr::trim(line), "=");
        if found { print(key, ": ", bstr::to_str_lossy(value)); }
    }
    print(bstr::replace("a\0b\0c", "\0", " / "));
    bstr::char_indices("a☃\xE2\x98!") { start, end, cp =>
        print(start, "..", end, ": ", cp);
    }
}
