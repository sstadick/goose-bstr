# goostr search benchmarks — 2026-11-02

Results from memchr's benchmark suite. These measurements describe this corpus and machine, not a general performance ranking.

2 rounds · 96 workloads · 48 engine configurations · 1,286 engine/case pairs per round. No reported measurement errors.

[Substring search](#substring-search) · [Byte search](#byte-search) · [Specialized variants](#specialized-variants) · [Methodology](#methodology)

Raw results: [round-1.csv](round-1.csv), [round-2.csv](round-2.csv)

**Times are microseconds; lower is better.** Each row is a workload and each column is an engine. Values are medians of round medians for the complete workload, not individual search calls. 🟢 **Green markers and bold** identify the lowest reported time in that row, including ties; they do not establish statistical significance.

**—** means that engine was not measured on that workload, not that it failed. All measured engine/case pairs are included below. Benchmark names omit the common `memmem/` or `memchr/sherlock/` prefix. Versions are recorded in the CSVs; `unknown` means the runner did not report a version.

## Substring search

**sliceslice is existence-only:** it reports whether a match exists, not its offset. Its count workloads are restricted to zero or one expected match. These timings therefore compare different API work, not interchangeable search operations.

### One-shot substring search

| Benchmark | goostr | memchr | StringZilla | libc | sliceslice (existence-only) | jetscii | Rust std | memchr 2.5 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| byterank/binary | 3335.000 | 8615.000 | 🟢 **2065.000** | 12750.000 | 6740.000 | 9300.000 | — | 8255.000 |
| code/rust-library-common-fn | 109.620 | 129.530 | 98.030 | 793.750 | — | 209.200 | 934.465 | 🟢 **91.735** |
| code/rust-library-common-fn-is-empty | 32.595 | 🟢 **29.525** | 45.345 | 154.075 | — | 144.510 | 1030.000 | 38.575 |
| code/rust-library-common-let | 180.800 | 211.485 | 🟢 **128.855** | 661.505 | — | 293.630 | 1125.000 | 150.335 |
| code/rust-library-common-paren | 338.130 | 673.675 | 🟢 **336.825** | 366.355 | — | 698.815 | 1880.000 | 677.625 |
| code/rust-library-never-fn-quux | 28.420 | 🟢 **25.235** | 47.005 | 214.290 | 29.375 | 142.265 | 970.000 | 35.675 |
| code/rust-library-never-fn-strength | 30.760 | 27.700 | 44.845 | 173.640 | 🟢 **26.150** | 145.535 | 1050.000 | 37.375 |
| code/rust-library-never-fn-strength-paren | 30.930 | 28.390 | 45.350 | 150.515 | 🟢 **28.300** | 145.515 | 970.000 | 37.550 |
| code/rust-library-rare-fn-from-str | 31.185 | 28.490 | 44.785 | 111.400 | 🟢 **7.385** | 139.470 | 940.845 | 37.745 |
| pathological/defeat-simple-vector-alphabet | 28.005 | 157.165 | 🟢 **15.005** | 131.975 | 119.750 | 91.605 | 88.610 | 191.195 |
| pathological/defeat-simple-vector-freq-alphabet | 44.785 | 50.905 | 511.710 | 47.270 | 597.300 | 50.645 | 🟢 **31.985** | 44.875 |
| pathological/defeat-simple-vector-repeated-alphabet | 60.290 | 985.000 | 🟢 **19.795** | 1120.000 | 3045.000 | 4955.000 | 819.975 | 980.000 |
| pathological/md5-huge-last-hash | 3.600 | 🟢 **3.530** | 4.570 | 5.275 | 5.975 | 14.605 | 17.050 | 3.975 |
| pathological/md5-huge-no-hash | 3.560 | 🟢 **3.345** | 4.525 | 4.805 | 6.120 | 14.260 | 16.045 | 4.020 |
| pathological/rare-repeated-huge-match | 903.690 | 1820.000 | 771.010 | 1210.000 | — | 🟢 **751.970** | 1595.000 | 1105.000 |
| pathological/rare-repeated-huge-tricky | 8.535 | 7.655 | 13.505 | 40.250 | 🟢 **6.750** | 35.600 | 344.830 | 7.445 |
| pathological/rare-repeated-small-match | 1.700 | 3.400 | 1.690 | 2.370 | — | 🟢 **1.480** | 3.260 | 2.220 |
| pathological/rare-repeated-small-tricky | 0.050 | 0.080 | 0.060 | 0.120 | 🟢 **0.040** | 0.100 | 0.725 | 0.050 |
| subtitles/common/huge-en-one-space | 460.205 | 1210.000 | 🟢 **456.365** | 534.665 | — | 1475.000 | 2085.000 | 1205.000 |
| subtitles/common/huge-en-that | 37.045 | 46.055 | 🟢 **33.370** | 207.005 | — | 105.830 | 241.260 | 34.365 |
| subtitles/common/huge-en-you | 144.075 | 185.910 | 🟢 **79.710** | 400.570 | — | 176.585 | 373.495 | 124.870 |
| subtitles/common/huge-ru-not | 97.985 | 131.660 | 206.180 | 390.610 | — | 325.710 | 614.110 | 🟢 **88.720** |
| subtitles/common/huge-ru-one-space | 248.770 | 623.215 | 🟢 **239.440** | 278.885 | — | 821.690 | 1210.000 | 613.800 |
| subtitles/common/huge-ru-that | 🟢 **39.130** | 50.895 | 48.825 | 279.735 | — | 144.970 | 536.105 | 39.750 |
| subtitles/common/huge-zh-do-not | 85.605 | 112.675 | 🟢 **58.660** | 305.210 | — | 161.930 | 270.725 | 73.130 |
| subtitles/common/huge-zh-one-space | 134.550 | 299.095 | 🟢 **123.385** | 150.765 | — | 353.990 | 804.790 | 300.430 |
| subtitles/common/huge-zh-that | 37.240 | 48.425 | 33.910 | 206.300 | — | 71.825 | 158.740 | 🟢 **33.235** |
| subtitles/never/huge-en-all-common-bytes | 16.515 | 🟢 **15.855** | 17.995 | 56.795 | 17.850 | 59.885 | 172.005 | 17.080 |
| subtitles/never/huge-en-john-watson | 10.485 | 9.295 | 16.655 | 53.550 | 🟢 **8.660** | 43.645 | 310.890 | 9.150 |
| subtitles/never/huge-en-some-rare-bytes | 10.400 | 9.460 | 16.550 | 71.280 | 🟢 **9.320** | 44.950 | 141.225 | 9.435 |
| subtitles/never/huge-en-two-space | 9.395 | 9.345 | 16.560 | 280.985 | 🟢 **8.445** | 118.555 | 514.980 | 9.280 |
| subtitles/never/huge-ru-john-watson | 10.445 | 9.460 | 16.710 | 140.730 | 72.960 | 202.110 | 244.665 | 🟢 **9.250** |
| subtitles/never/huge-zh-john-watson | 11.365 | 🟢 **10.200** | 16.580 | 43.065 | 11.595 | 55.655 | 88.425 | 13.950 |
| subtitles/never/teeny-en-all-common-bytes | 🟢 **0.020** | 0.040 | 0.050 | 0.040 | 0.025 | 0.040 | 0.040 | 0.040 |
| subtitles/never/teeny-en-john-watson | 🟢 **0.020** | 0.040 | 0.050 | 0.040 | 0.030 | 0.040 | 0.050 | 0.040 |
| subtitles/never/teeny-en-some-rare-bytes | 🟢 **0.020** | 0.040 | 0.040 | 0.040 | 🟢 **0.020** | 0.040 | 0.040 | 0.040 |
| subtitles/never/teeny-en-two-space | 🟢 **0.020** | 0.040 | 0.030 | 0.030 | 0.030 | 0.040 | 0.040 | 0.040 |
| subtitles/never/teeny-ru-john-watson | 🟢 **0.020** | 0.050 | 0.050 | 0.040 | 0.030 | 0.040 | 0.060 | 0.050 |
| subtitles/never/teeny-zh-john-watson | 🟢 **0.020** | 0.040 | 0.040 | 0.040 | 0.030 | 0.040 | 0.050 | 0.040 |
| subtitles/rare/huge-en-huge-needle | 12.320 | 🟢 **10.430** | 16.410 | 35.270 | 25.125 | 45.055 | 74.795 | 24.740 |
| subtitles/rare/huge-en-long-needle | 10.100 | 🟢 **9.125** | 16.885 | 18.670 | 19.595 | 50.870 | 72.205 | 10.170 |
| subtitles/rare/huge-en-medium-needle | 12.010 | 🟢 **11.165** | 17.815 | 22.800 | 30.820 | 59.870 | 120.000 | 14.395 |
| subtitles/rare/huge-en-sherlock | 10.730 | 9.670 | 16.685 | 65.985 | 🟢 **8.660** | 45.650 | 182.940 | 13.670 |
| subtitles/rare/huge-en-sherlock-holmes | 10.830 | 9.435 | 16.745 | 43.730 | 🟢 **9.215** | 45.705 | 195.605 | 13.365 |
| subtitles/rare/huge-ru-sherlock | 10.600 | 🟢 **9.780** | 16.570 | 182.585 | 18.750 | 194.625 | 315.260 | 13.270 |
| subtitles/rare/huge-ru-sherlock-holmes | 10.485 | 9.455 | 16.605 | 112.910 | 58.375 | 197.495 | 206.560 | 🟢 **9.185** |
| subtitles/rare/huge-zh-sherlock | 11.175 | 🟢 **10.085** | 16.540 | 64.410 | 16.415 | 72.965 | 149.315 | 13.730 |
| subtitles/rare/huge-zh-sherlock-holmes | 11.725 | 🟢 **10.665** | 19.565 | 29.890 | 21.315 | 75.505 | 116.735 | 13.935 |
| subtitles/rare/teeny-en-sherlock | 0.030 | 0.040 | 0.060 | 0.060 | 🟢 **0.025** | 0.050 | 0.070 | 0.040 |
| subtitles/rare/teeny-en-sherlock-holmes | 0.040 | 0.040 | 0.050 | 0.050 | 🟢 **0.030** | 0.050 | 0.100 | 0.040 |
| subtitles/rare/teeny-ru-sherlock | 🟢 **0.030** | 0.050 | 0.080 | 0.070 | 🟢 **0.030** | 0.050 | 0.090 | 0.045 |
| subtitles/rare/teeny-ru-sherlock-holmes | 🟢 **0.025** | 0.050 | 0.060 | 0.060 | 0.030 | 0.040 | 0.135 | 0.050 |
| subtitles/rare/teeny-zh-sherlock | 🟢 **0.030** | 0.040 | 0.070 | 0.060 | 🟢 **0.030** | 0.050 | 0.080 | 0.040 |
| subtitles/rare/teeny-zh-sherlock-holmes | 0.040 | 0.050 | 0.060 | 0.050 | 🟢 **0.030** | 0.040 | 0.125 | 0.040 |

### Prepared substring search

**Rust std includes setup:** upstream calls this mode `prebuilt`, but `haystack.matches(needle).count()` constructs the searcher inside each timed sample. The other prepared searchers are constructed outside timing.

| Benchmark | goostr | memchr | sliceslice (existence-only) | jetscii | Rust std (setup timed) | memchr 2.5 |
|---|---:|---:|---:|---:|---:|---:|
| byterank/binary | 🟢 **3335.000** | 8590.000 | 6740.000 | 9345.000 | — | 8240.000 |
| code/rust-library-common-fn | 71.260 | 🟢 **67.635** | — | 196.680 | 953.940 | 74.490 |
| code/rust-library-common-fn-is-empty | 31.580 | 🟢 **28.880** | — | 144.070 | 1045.000 | 38.350 |
| code/rust-library-common-let | 116.015 | 🟢 **111.795** | — | 268.500 | 1095.000 | 113.860 |
| code/rust-library-common-paren | 🟢 **339.610** | 417.780 | — | 567.605 | 1095.000 | 397.725 |
| code/rust-library-never-fn-quux | 28.435 | 🟢 **25.180** | 29.890 | 142.720 | 995.000 | 35.655 |
| code/rust-library-never-fn-strength | 30.620 | 27.705 | 🟢 **26.185** | 145.525 | 1060.000 | 37.320 |
| code/rust-library-never-fn-strength-paren | 31.970 | 28.225 | 🟢 **27.995** | 145.095 | 985.000 | 37.670 |
| code/rust-library-rare-fn-from-str | 31.090 | 28.490 | 🟢 **7.410** | 139.635 | 947.355 | 37.835 |
| pathological/defeat-simple-vector-alphabet | 🟢 **27.915** | 157.920 | 120.230 | 91.395 | 100.950 | 189.815 |
| pathological/defeat-simple-vector-freq-alphabet | 44.480 | 50.665 | 598.795 | 50.655 | 🟢 **29.565** | 44.575 |
| pathological/defeat-simple-vector-repeated-alphabet | 🟢 **59.890** | 980.000 | 3045.000 | 4950.000 | 831.605 | 980.000 |
| pathological/md5-huge-last-hash | 3.430 | 🟢 **3.280** | 6.005 | 14.540 | 18.815 | 4.010 |
| pathological/md5-huge-no-hash | 3.490 | 🟢 **3.350** | 6.050 | 14.365 | 17.640 | 3.935 |
| pathological/rare-repeated-huge-match | 🟢 **332.470** | 424.545 | — | 423.235 | 333.560 | 469.705 |
| pathological/rare-repeated-huge-tricky | 8.525 | 7.585 | 🟢 **6.780** | 35.575 | 402.640 | 7.515 |
| pathological/rare-repeated-small-match | 🟢 **0.505** | 0.870 | — | 0.845 | 0.675 | 0.970 |
| pathological/rare-repeated-small-tricky | 🟢 **0.040** | 🟢 **0.040** | 🟢 **0.040** | 0.095 | 0.830 | 🟢 **0.040** |
| sliceslice/i386 | 15880.000 | 🟢 **14430.000** | 16930.000 | — | — | 17920.000 |
| sliceslice/seemingly-random | 119.610 | 115.355 | 🟢 **93.295** | — | — | 130.885 |
| sliceslice/short | 🟢 **4835.000** | 9510.000 | 29195.000 | — | — | 26565.000 |
| subtitles/common/huge-en-one-space | 🟢 **484.765** | 647.365 | — | 919.620 | 910.520 | 553.735 |
| subtitles/common/huge-en-that | 26.005 | 26.090 | — | 100.705 | 239.355 | 🟢 **23.895** |
| subtitles/common/huge-en-you | 59.035 | 🟢 **58.025** | — | 143.110 | 309.005 | 74.180 |
| subtitles/common/huge-ru-not | 🟢 **52.115** | 55.305 | — | 304.235 | 578.915 | 56.440 |
| subtitles/common/huge-ru-one-space | 🟢 **255.920** | 339.260 | — | 574.205 | 587.950 | 294.570 |
| subtitles/common/huge-ru-that | 🟢 **23.330** | 23.750 | — | 140.905 | 529.025 | 26.420 |
| subtitles/common/huge-zh-do-not | 45.730 | 🟢 **44.080** | — | 142.680 | 242.500 | 49.625 |
| subtitles/common/huge-zh-one-space | 🟢 **133.205** | 176.840 | — | 265.025 | 445.025 | 165.630 |
| subtitles/common/huge-zh-that | 🟢 **23.185** | 23.645 | — | 66.495 | 162.190 | 24.875 |
| subtitles/never/huge-en-all-common-bytes | 16.050 | 🟢 **14.455** | 17.925 | 59.880 | 178.800 | 17.075 |
| subtitles/never/huge-en-john-watson | 10.455 | 9.200 | 🟢 **8.955** | 43.655 | 306.605 | 9.115 |
| subtitles/never/huge-en-some-rare-bytes | 10.395 | 9.625 | 9.335 | 44.740 | 151.925 | 🟢 **9.280** |
| subtitles/never/huge-en-two-space | 9.405 | 9.315 | 🟢 **8.490** | 118.080 | 401.490 | 9.245 |
| subtitles/never/huge-ru-john-watson | 10.450 | 9.295 | 72.745 | 201.395 | 252.540 | 🟢 **9.205** |
| subtitles/never/huge-zh-john-watson | 11.355 | 🟢 **10.275** | 11.455 | 55.685 | 90.185 | 13.840 |
| subtitles/never/teeny-en-all-common-bytes | 🟢 **0.020** | 0.030 | 🟢 **0.020** | 0.030 | 0.040 | 0.030 |
| subtitles/never/teeny-en-john-watson | 🟢 **0.020** | 0.030 | 🟢 **0.020** | 0.030 | 0.050 | 0.030 |
| subtitles/never/teeny-en-some-rare-bytes | 🟢 **0.020** | 0.030 | 🟢 **0.020** | 0.030 | 0.040 | 0.030 |
| subtitles/never/teeny-en-two-space | 🟢 **0.020** | 0.030 | 🟢 **0.020** | 0.030 | 0.040 | 0.030 |
| subtitles/never/teeny-ru-john-watson | 🟢 **0.020** | 0.030 | 🟢 **0.020** | 0.030 | 0.060 | 0.030 |
| subtitles/never/teeny-zh-john-watson | 🟢 **0.020** | 0.030 | 🟢 **0.020** | 0.030 | 0.050 | 0.030 |
| subtitles/rare/huge-en-huge-needle | 9.765 | 🟢 **8.395** | 25.950 | 44.660 | 76.270 | 23.165 |
| subtitles/rare/huge-en-long-needle | 9.385 | 🟢 **8.705** | 19.635 | 50.925 | 73.890 | 9.395 |
| subtitles/rare/huge-en-medium-needle | 12.115 | 🟢 **11.275** | 33.205 | 59.815 | 122.125 | 14.490 |
| subtitles/rare/huge-en-sherlock | 11.215 | 10.050 | 🟢 **8.640** | 45.620 | 192.500 | 13.445 |
| subtitles/rare/huge-en-sherlock-holmes | 10.460 | 9.335 | 🟢 **9.195** | 45.725 | 193.670 | 13.300 |
| subtitles/rare/huge-ru-sherlock | 10.555 | 🟢 **9.335** | 18.630 | 194.330 | 314.515 | 13.215 |
| subtitles/rare/huge-ru-sherlock-holmes | 10.550 | 9.320 | 58.155 | 198.885 | 211.210 | 🟢 **9.150** |
| subtitles/rare/huge-zh-sherlock | 10.990 | 🟢 **10.140** | 16.405 | 72.875 | 153.635 | 13.705 |
| subtitles/rare/huge-zh-sherlock-holmes | 11.615 | 🟢 **10.750** | 27.330 | 75.145 | 119.620 | 13.860 |
| subtitles/rare/teeny-en-sherlock | 0.030 | 0.030 | 🟢 **0.020** | 0.040 | 0.050 | 0.030 |
| subtitles/rare/teeny-en-sherlock-holmes | 0.030 | 0.030 | 🟢 **0.020** | 0.040 | 0.070 | 0.030 |
| subtitles/rare/teeny-ru-sherlock | 0.030 | 0.030 | 🟢 **0.025** | 0.040 | 0.060 | 0.040 |
| subtitles/rare/teeny-ru-sherlock-holmes | 🟢 **0.030** | 🟢 **0.030** | 🟢 **0.030** | 0.040 | 0.090 | 🟢 **0.030** |
| subtitles/rare/teeny-zh-sherlock | 0.030 | 0.040 | 🟢 **0.020** | 0.040 | 0.050 | 0.040 |
| subtitles/rare/teeny-zh-sherlock-holmes | 0.030 | 0.040 | 🟢 **0.020** | 0.040 | 0.080 | 0.040 |

## Byte search

### Forward single-byte search

| Benchmark | goostr | memchr | libc | memchr 2.5 |
|---|---:|---:|---:|---:|
| common/huge1 | 227.915 | 236.780 | 219.080 | 🟢 **196.980** |
| common/small1 | 0.200 | 0.290 | 0.220 | 🟢 **0.190** |
| common/tiny1 | 🟢 **0.060** | 0.080 | 0.070 | 🟢 **0.060** |
| never/empty1 | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** |
| never/huge1 | 5.545 | 5.410 | 🟢 **5.330** | 5.390 |
| never/small1 | 🟢 **0.030** | 🟢 **0.030** | 🟢 **0.030** | 🟢 **0.030** |
| never/tiny1 | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** |
| rare/huge1 | 6.935 | 6.860 | 🟢 **6.605** | 6.660 |
| rare/small1 | 🟢 **0.030** | 🟢 **0.030** | 🟢 **0.030** | 🟢 **0.030** |
| rare/tiny1 | 🟢 **0.020** | 0.030 | 0.030 | 0.030 |
| uncommon/huge1 | 83.285 | 92.585 | 🟢 **70.510** | 80.700 |
| uncommon/small1 | 🟢 **0.060** | 0.070 | 🟢 **0.060** | 🟢 **0.060** |
| uncommon/tiny1 | 🟢 **0.040** | 0.050 | 🟢 **0.040** | 🟢 **0.040** |
| verycommon/huge1 | 470.110 | 481.695 | 447.330 | 🟢 **369.925** |
| verycommon/small1 | 0.445 | 0.560 | 0.510 | 🟢 **0.430** |

### Reverse single-byte search

| Benchmark | goostr | memchr | memchr 2.5 |
|---|---:|---:|---:|
| common/huge1 | 237.225 | 261.495 | 🟢 **219.465** |
| common/small1 | 0.250 | 0.290 | 🟢 **0.220** |
| common/tiny1 | 0.070 | 0.080 | 🟢 **0.060** |
| never/empty1 | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** |
| never/huge1 | 5.490 | 5.390 | 🟢 **5.350** |
| never/small1 | 🟢 **0.030** | 🟢 **0.030** | 🟢 **0.030** |
| never/tiny1 | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** |
| rare/huge1 | 6.980 | 6.915 | 🟢 **6.605** |
| rare/small1 | 🟢 **0.030** | 0.040 | 🟢 **0.030** |
| rare/tiny1 | 🟢 **0.020** | 0.040 | 🟢 **0.020** |
| uncommon/huge1 | 83.775 | 95.640 | 🟢 **74.570** |
| uncommon/small1 | 0.070 | 0.080 | 🟢 **0.060** |
| uncommon/tiny1 | 🟢 **0.040** | 0.050 | 🟢 **0.040** |
| verycommon/huge1 | 508.230 | 521.740 | 🟢 **438.340** |
| verycommon/small1 | 0.560 | 0.595 | 🟢 **0.505** |

### Forward two-byte search

| Benchmark | goostr | memchr | memchr 2.5 |
|---|---:|---:|---:|
| common/huge2 | 407.260 | 395.660 | 🟢 **318.065** |
| common/small2 | 0.355 | 0.430 | 🟢 **0.340** |
| never/empty2 | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** |
| never/huge2 | 7.235 | 7.175 | 🟢 **7.155** |
| never/small2 | 0.035 | 🟢 **0.030** | 🟢 **0.030** |
| never/tiny2 | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** |
| rare/huge2 | 🟢 **10.040** | 11.205 | 10.380 |
| rare/small2 | 🟢 **0.040** | 🟢 **0.040** | 🟢 **0.040** |
| rare/tiny2 | 🟢 **0.030** | 0.040 | 🟢 **0.030** |
| uncommon/huge2 | 🟢 **158.400** | 188.950 | 163.705 |
| uncommon/small2 | 🟢 **0.100** | 0.120 | 0.110 |
| uncommon/tiny2 | 🟢 **0.060** | 0.080 | 🟢 **0.060** |

### Reverse two-byte search

| Benchmark | goostr | memchr | memchr 2.5 |
|---|---:|---:|---:|
| common/huge2 | 461.320 | 445.085 | 🟢 **364.350** |
| common/small2 | 0.450 | 0.515 | 🟢 **0.400** |
| never/empty2 | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** |
| never/huge2 | 7.190 | 7.500 | 🟢 **7.140** |
| never/small2 | 🟢 **0.030** | 🟢 **0.030** | 🟢 **0.030** |
| never/tiny2 | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** |
| rare/huge2 | 🟢 **9.675** | 12.105 | 10.385 |
| rare/small2 | 🟢 **0.040** | 0.050 | 🟢 **0.040** |
| rare/tiny2 | 🟢 **0.030** | 0.040 | 🟢 **0.030** |
| uncommon/huge2 | 163.745 | 200.200 | 🟢 **158.025** |
| uncommon/small2 | 0.110 | 0.130 | 🟢 **0.100** |
| uncommon/tiny2 | 0.070 | 0.090 | 🟢 **0.060** |

### Forward three-byte search

| Benchmark | goostr | memchr | memchr 2.5 |
|---|---:|---:|---:|
| common/huge3 | 511.340 | 650.565 | 🟢 **479.740** |
| common/small3 | 0.575 | 0.690 | 🟢 **0.520** |
| never/empty3 | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** |
| never/huge3 | 🟢 **8.845** | 9.040 | 9.105 |
| never/small3 | 0.040 | 🟢 **0.030** | 🟢 **0.030** |
| never/tiny3 | 🟢 **0.020** | 0.025 | 🟢 **0.020** |
| rare/huge3 | 🟢 **13.095** | 14.690 | 13.485 |
| rare/small3 | 🟢 **0.050** | 0.060 | 🟢 **0.050** |
| rare/tiny3 | 🟢 **0.030** | 0.050 | 🟢 **0.030** |
| uncommon/huge3 | 257.905 | 237.245 | 🟢 **212.115** |
| uncommon/small3 | 🟢 **0.150** | 0.180 | 🟢 **0.150** |
| uncommon/tiny3 | 0.090 | 0.110 | 🟢 **0.085** |

### Reverse three-byte search

| Benchmark | goostr | memchr | memchr 2.5 |
|---|---:|---:|---:|
| common/huge3 | 596.945 | 722.840 | 🟢 **560.635** |
| common/small3 | 0.780 | 0.770 | 🟢 **0.600** |
| never/empty3 | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** |
| never/huge3 | 🟢 **8.875** | 9.295 | 9.065 |
| never/small3 | 0.040 | 0.040 | 🟢 **0.030** |
| never/tiny3 | 🟢 **0.020** | 0.030 | 🟢 **0.020** |
| rare/huge3 | 13.150 | 15.800 | 🟢 **13.010** |
| rare/small3 | 🟢 **0.050** | 0.060 | 🟢 **0.050** |
| rare/tiny3 | 0.035 | 0.050 | 🟢 **0.030** |
| uncommon/huge3 | 268.315 | 250.085 | 🟢 **207.175** |
| uncommon/small3 | 0.180 | 0.200 | 🟢 **0.150** |
| uncommon/tiny3 | 0.110 | 0.120 | 🟢 **0.090** |

## Specialized variants

These are reference comparisons, not interchangeable search APIs. `bytecount` and `onlycount` count without producing match offsets; `prebuilt` byte search uses an iterator. Internal substring algorithms are compared with prepared finders, with setup outside timing. Fallback and naive variants bypass runtime SIMD selection. Goostr and current memchr are repeated for reference.

### Forward single-byte search variants

| Benchmark | goostr | memchr | memchr fallback | memchr naive | memchr onlycount | memchr prebuilt | memchr 2.5 naive | memchr 2.5 prebuilt | bytecount |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| common/huge1 | 227.915 | 236.780 | 563.670 | 431.740 | 🟢 **14.290** | 232.295 | 430.970 | 197.250 | 22.150 |
| common/small1 | 0.200 | 0.290 | 0.210 | 0.290 | 🟢 **0.040** | 0.275 | 0.280 | 0.190 | 0.050 |
| common/tiny1 | 0.060 | 0.080 | 0.050 | 0.050 | 🟢 **0.030** | 0.070 | 0.050 | 0.060 | 🟢 **0.030** |
| never/empty1 | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** |
| never/huge1 | 5.545 | 5.410 | 34.555 | 270.560 | 14.310 | 🟢 **5.370** | 260.315 | 5.375 | 22.080 |
| never/small1 | 🟢 **0.030** | 🟢 **0.030** | 0.060 | 0.305 | 0.040 | 🟢 **0.030** | 0.305 | 🟢 **0.030** | 0.050 |
| never/tiny1 | 🟢 **0.020** | 🟢 **0.020** | 0.025 | 0.040 | 0.030 | 🟢 **0.020** | 0.045 | 🟢 **0.020** | 0.025 |
| rare/huge1 | 6.935 | 6.860 | 36.770 | 255.270 | 14.240 | 6.700 | — | 🟢 **6.460** | 22.015 |
| rare/small1 | 🟢 **0.030** | 🟢 **0.030** | 0.060 | 0.320 | 0.040 | 🟢 **0.030** | 0.305 | 🟢 **0.030** | 0.050 |
| rare/tiny1 | 🟢 **0.020** | 0.030 | 0.030 | 0.050 | 0.030 | 0.040 | 0.050 | 0.030 | 0.025 |
| uncommon/huge1 | 83.285 | 92.585 | 130.090 | 286.740 | 🟢 **14.190** | 91.920 | 289.130 | 80.325 | 22.005 |
| uncommon/small1 | 0.060 | 0.070 | 0.090 | 0.325 | 🟢 **0.040** | 0.070 | 0.330 | 0.060 | 0.050 |
| uncommon/tiny1 | 0.040 | 0.050 | 0.040 | 0.040 | 0.030 | 0.040 | 0.045 | 0.040 | 🟢 **0.025** |
| verycommon/huge1 | 470.110 | 481.695 | 949.180 | 742.395 | 🟢 **14.230** | 448.120 | 876.490 | 368.615 | 22.055 |
| verycommon/small1 | 0.445 | 0.560 | 0.415 | 0.320 | 🟢 **0.040** | 0.510 | 0.320 | 0.430 | 0.050 |

### Forward two-byte search variants

| Benchmark | goostr | memchr | memchr fallback | memchr naive |
|---|---:|---:|---:|---:|
| common/huge2 | 407.260 | 🟢 **395.660** | 1120.000 | 668.205 |
| common/small2 | 🟢 **0.355** | 0.430 | 0.415 | 0.390 |
| never/empty2 | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** |
| never/huge2 | 7.235 | 🟢 **7.175** | 69.925 | 276.850 |
| never/small2 | 0.035 | 🟢 **0.030** | 0.100 | 0.335 |
| never/tiny2 | 🟢 **0.020** | 🟢 **0.020** | 0.030 | 0.050 |
| rare/huge2 | 🟢 **10.040** | 11.205 | 74.205 | 275.220 |
| rare/small2 | 🟢 **0.040** | 🟢 **0.040** | 0.100 | 0.605 |
| rare/tiny2 | 🟢 **0.030** | 0.040 | 0.040 | 0.080 |
| uncommon/huge2 | 🟢 **158.400** | 188.950 | 267.645 | 370.705 |
| uncommon/small2 | 🟢 **0.100** | 0.120 | 0.145 | 0.380 |
| uncommon/tiny2 | 🟢 **0.060** | 0.080 | 🟢 **0.060** | 🟢 **0.060** |

### Forward three-byte search variants

| Benchmark | goostr | memchr | memchr fallback | memchr naive |
|---|---:|---:|---:|---:|
| common/huge3 | 🟢 **511.340** | 650.565 | 1540.000 | 1025.000 |
| common/small3 | 🟢 **0.575** | 0.690 | 0.585 | 0.595 |
| never/empty3 | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** | 🟢 **0.020** |
| never/huge3 | 🟢 **8.845** | 9.040 | 90.350 | 365.870 |
| never/small3 | 0.040 | 🟢 **0.030** | 0.120 | 0.430 |
| never/tiny3 | 🟢 **0.020** | 0.025 | 0.030 | 0.060 |
| rare/huge3 | 🟢 **13.095** | 14.690 | 95.620 | 407.125 |
| rare/small3 | 🟢 **0.050** | 0.060 | 0.130 | 0.485 |
| rare/tiny3 | 🟢 **0.030** | 0.050 | 0.040 | 0.060 |
| uncommon/huge3 | 257.905 | 🟢 **237.245** | 374.800 | 537.275 |
| uncommon/small3 | 🟢 **0.150** | 0.180 | 0.230 | 0.485 |
| uncommon/tiny3 | 0.090 | 0.110 | 0.080 | 🟢 **0.070** |

### Prepared substring search variants

| Benchmark | goostr | memchr | memchr binary | memchr rabinkarp | memchr shiftor | memchr twoway |
|---|---:|---:|---:|---:|---:|---:|
| byterank/binary | 3335.000 | 8590.000 | 🟢 **1660.000** | 22810.000 | 15440.000 | 12075.000 |
| code/rust-library-common-fn | 71.260 | 🟢 **67.635** | — | 1215.000 | 801.310 | 930.560 |
| code/rust-library-common-fn-is-empty | 31.580 | 🟢 **28.880** | — | 1130.000 | 768.160 | 1075.000 |
| code/rust-library-common-let | 116.015 | 🟢 **111.795** | — | 1235.000 | 810.325 | 1135.000 |
| code/rust-library-common-paren | 🟢 **339.610** | 417.780 | — | 1375.000 | 1035.000 | 1305.000 |
| code/rust-library-never-fn-quux | 28.435 | 🟢 **25.180** | — | 1120.000 | 759.325 | 1005.000 |
| code/rust-library-never-fn-strength | 30.620 | 🟢 **27.705** | — | 1130.000 | 761.220 | 1095.000 |
| code/rust-library-never-fn-strength-paren | 31.970 | 🟢 **28.225** | — | 1130.000 | 762.035 | 1025.000 |
| code/rust-library-rare-fn-from-str | 31.090 | 🟢 **28.490** | — | 1125.000 | — | 995.000 |
| pathological/defeat-simple-vector-alphabet | 🟢 **27.915** | 157.920 | — | 376.710 | 265.205 | 107.660 |
| pathological/defeat-simple-vector-freq-alphabet | 44.480 | 50.665 | — | 487.640 | — | 🟢 **38.495** |
| pathological/defeat-simple-vector-repeated-alphabet | 🟢 **59.890** | 980.000 | — | 487.460 | — | 718.490 |
| pathological/md5-huge-last-hash | 3.430 | 🟢 **3.280** | — | 102.030 | — | 14.755 |
| pathological/md5-huge-no-hash | 3.490 | 🟢 **3.350** | — | 102.020 | — | 14.475 |
| pathological/rare-repeated-huge-match | 332.470 | 424.545 | — | 275.400 | 🟢 **256.240** | 328.325 |
| pathological/rare-repeated-huge-tricky | 8.525 | 🟢 **7.585** | — | 338.605 | 229.035 | 294.670 |
| pathological/rare-repeated-small-match | 🟢 **0.505** | 0.870 | — | 0.570 | 0.555 | 0.680 |
| pathological/rare-repeated-small-tricky | 🟢 **0.040** | 🟢 **0.040** | — | 0.690 | 0.490 | 0.590 |
| sliceslice/i386 | 15880.000 | 🟢 **14430.000** | — | — | — | — |
| sliceslice/seemingly-random | 119.610 | 🟢 **115.355** | — | — | — | — |
| sliceslice/short | 🟢 **4835.000** | 9510.000 | — | — | — | — |
| subtitles/common/huge-en-one-space | 🟢 **484.765** | 647.365 | — | 1235.000 | 970.000 | 1055.000 |
| subtitles/common/huge-en-that | 🟢 **26.005** | 26.090 | — | 432.230 | 291.985 | 238.080 |
| subtitles/common/huge-en-you | 59.035 | 🟢 **58.025** | — | 454.720 | 334.665 | 285.610 |
| subtitles/common/huge-ru-not | 🟢 **52.115** | 55.305 | — | 458.085 | 323.000 | 594.710 |
| subtitles/common/huge-ru-one-space | 🟢 **255.920** | 339.260 | — | 833.685 | 626.705 | 679.770 |
| subtitles/common/huge-ru-that | 🟢 **23.330** | 23.750 | — | 430.840 | 294.755 | 539.975 |
| subtitles/common/huge-zh-do-not | 45.730 | 🟢 **44.080** | — | 448.965 | 315.340 | 244.535 |
| subtitles/common/huge-zh-one-space | 🟢 **133.205** | 176.840 | — | 566.250 | 429.030 | 535.000 |
| subtitles/common/huge-zh-that | 🟢 **23.185** | 23.645 | — | 448.470 | 296.030 | 157.635 |
| subtitles/never/huge-en-all-common-bytes | 16.050 | 🟢 **14.455** | — | 415.880 | 282.370 | 178.085 |
| subtitles/never/huge-en-john-watson | 10.455 | 🟢 **9.200** | — | 417.140 | 282.315 | 308.300 |
| subtitles/never/huge-en-some-rare-bytes | 10.395 | 🟢 **9.625** | — | 418.960 | 283.610 | 157.120 |
| subtitles/never/huge-en-two-space | 9.405 | 🟢 **9.315** | — | 420.455 | 282.090 | 468.480 |
| subtitles/never/huge-ru-john-watson | 10.450 | 🟢 **9.295** | — | 418.610 | — | 260.445 |
| subtitles/never/huge-zh-john-watson | 11.355 | 🟢 **10.275** | — | 418.040 | 282.795 | 96.530 |
| subtitles/never/teeny-en-all-common-bytes | 🟢 **0.020** | 0.030 | — | 0.030 | 0.030 | 🟢 **0.020** |
| subtitles/never/teeny-en-john-watson | 🟢 **0.020** | 0.030 | — | 0.030 | 0.030 | 🟢 **0.020** |
| subtitles/never/teeny-en-some-rare-bytes | 🟢 **0.020** | 0.030 | — | 0.030 | 0.030 | 🟢 **0.020** |
| subtitles/never/teeny-en-two-space | 🟢 **0.020** | 0.030 | — | 0.030 | 0.030 | 0.030 |
| subtitles/never/teeny-ru-john-watson | 🟢 **0.020** | 0.030 | — | 0.040 | — | 🟢 **0.020** |
| subtitles/never/teeny-zh-john-watson | 🟢 **0.020** | 0.030 | — | 0.030 | 0.030 | 🟢 **0.020** |
| subtitles/rare/huge-en-huge-needle | 9.765 | 🟢 **8.395** | — | 416.390 | — | 66.655 |
| subtitles/rare/huge-en-long-needle | 9.385 | 🟢 **8.705** | — | 415.310 | — | 63.985 |
| subtitles/rare/huge-en-medium-needle | 12.115 | 🟢 **11.275** | — | 417.475 | — | 118.730 |
| subtitles/rare/huge-en-sherlock | 11.215 | 🟢 **10.050** | — | 419.120 | 283.585 | 194.300 |
| subtitles/rare/huge-en-sherlock-holmes | 10.460 | 🟢 **9.335** | — | 418.650 | 283.110 | 178.515 |
| subtitles/rare/huge-ru-sherlock | 10.555 | 🟢 **9.335** | — | 416.780 | 281.835 | 334.290 |
| subtitles/rare/huge-ru-sherlock-holmes | 10.550 | 🟢 **9.320** | — | 416.065 | — | 220.180 |
| subtitles/rare/huge-zh-sherlock | 10.990 | 🟢 **10.140** | — | 418.610 | 281.715 | 162.275 |
| subtitles/rare/huge-zh-sherlock-holmes | 11.615 | 🟢 **10.750** | — | 418.370 | — | 121.115 |
| subtitles/rare/teeny-en-sherlock | 🟢 **0.030** | 🟢 **0.030** | — | 🟢 **0.030** | 🟢 **0.030** | 🟢 **0.030** |
| subtitles/rare/teeny-en-sherlock-holmes | 🟢 **0.030** | 🟢 **0.030** | — | 🟢 **0.030** | 🟢 **0.030** | 0.040 |
| subtitles/rare/teeny-ru-sherlock | 🟢 **0.030** | 🟢 **0.030** | — | 0.040 | 0.040 | 🟢 **0.030** |
| subtitles/rare/teeny-ru-sherlock-holmes | 🟢 **0.030** | 🟢 **0.030** | — | 0.040 | — | 0.050 |
| subtitles/rare/teeny-zh-sherlock | 🟢 **0.030** | 0.040 | — | 🟢 **0.030** | 🟢 **0.030** | 🟢 **0.030** |
| subtitles/rare/teeny-zh-sherlock-holmes | 🟢 **0.030** | 0.040 | — | 🟢 **0.030** | — | 0.040 |

## Methodology

- **Machine:** AMD Ryzen 9 3950X 16-Core Processor; Linux-6.8.0-139-generic-x86_64-with-glibc2.39; pinned to logical CPU 4.
- **Compiler:** Ubuntu clang version 18.1.3 (1ubuntu1); generated C flags `-O3`. Goose `-O2` selects frontend inlining, not C optimization. Rust: `rustc 1.97.1 (8bab26f4f 2026-07-14)`; upstream release (opt-level 3, one codegen unit, fat LTO). No global native-CPU flags; library runtime SIMD selection applies.
- **Goose:** clean `goose v2026.3-265-geadca409 (runtime 3025e5810379)`. Measured goostr: [366b703](https://github.com/sstadick/goostr/commit/366b70366fe3e5e6a574858e897216561d2ac362).
- Fixtures, patterns and expected counts come from memchr 2.8.3. Counts are verified before timing and in timed samples. WebAssembly is excluded. The memchr runner's CSV version label is 2.8.2; its dependency is 2.8.3. `memchrold` is 2.5.0.
- Serial sweeps, up to 50 ms warmup and 100 ms measurement per engine/case, capped at 20,000 measured samples. No outliers are removed.
- Input parsing and output formatting are outside timing. Prepared-finder construction is outside timing except for Rust std, whose searcher is constructed inside each timed sample even in upstream's `prebuilt` mode. One-shot finder construction is inside timing. The Goose adapter adds no extra FFI or black-box barrier.
- Goostr repeatedly calls public searches for byte counts. Memchr does the same for forward one-shot byte search, but uses reusable iterators for reverse byte and two-/three-byte-set searches. Count-only engines do not produce individual match offsets. These are complete-workload comparisons, including those API differences.
- Tiny timings approach clock overhead and are rounded in rebar's CSV output. A few nanoseconds are not a precise throughput claim.
- These fixtures have been used during optimization, not held out. One corpus on one CPU does not establish performance on other inputs or architectures.

[Environment, revisions and hashes](environment.json) · [Build and repeat instructions](../../rebar/README.md)
