# goostr / memchr benchmark results

2 rounds, 189 matched engine/case pairs. All expected-count checks passed.

The CSVs contain 1286 engine/case pairs across 48 engines.

Times are microseconds for the complete workload. Each value is the median of round medians. Ratios are goostr / memchr; lower is better. Tiny values near clock overhead are imprecise.

[Methodology and repeat commands](../../rebar/README.md) · [Environment, pins and hashes](environment.json)

Raw results: [round-1.csv](round-1.csv), [round-2.csv](round-2.csv)

## Aggregate ratios

| Operation | Cases | Geometric mean |
|---|---:|---:|
| memchr/oneshot | 15 | 0.887× |
| memrchr | 15 | 0.881× |
| memchr2 | 12 | 0.917× |
| memrchr2 | 12 | 0.883× |
| memchr3 | 12 | 0.883× |
| memrchr3 | 12 | 0.884× |
| memmem/oneshot | 54 | 0.730× |
| memmem/prebuilt | 57 | 0.857× |

Geometric means weight cases equally, not by runtime; they are not application speedups.

## Largest losses above one microsecond

| Benchmark | Operation | goostr µs | memchr µs | Ratio |
|---|---|---:|---:|---:|
| memmem/subtitles/rare/huge-en-huge-needle | memmem/oneshot | 12.320 | 10.430 | 1.181× |
| memmem/subtitles/rare/huge-en-huge-needle | memmem/prebuilt | 9.765 | 8.395 | 1.163× |
| memmem/subtitles/rare/huge-en-sherlock-holmes | memmem/oneshot | 10.830 | 9.435 | 1.148× |
| memmem/subtitles/never/huge-en-john-watson | memmem/prebuilt | 10.455 | 9.200 | 1.136× |
| memmem/code/rust-library-never-fn-strength-paren | memmem/prebuilt | 31.970 | 28.225 | 1.133× |
| memmem/subtitles/rare/huge-ru-sherlock-holmes | memmem/prebuilt | 10.550 | 9.320 | 1.132× |
| memmem/subtitles/rare/huge-ru-sherlock | memmem/prebuilt | 10.555 | 9.335 | 1.131× |
| memmem/code/rust-library-never-fn-quux | memmem/prebuilt | 28.435 | 25.180 | 1.129× |
| memmem/subtitles/never/huge-en-john-watson | memmem/oneshot | 10.485 | 9.295 | 1.128× |
| memmem/code/rust-library-never-fn-quux | memmem/oneshot | 28.420 | 25.235 | 1.126× |
| memmem/subtitles/never/huge-ru-john-watson | memmem/prebuilt | 10.450 | 9.295 | 1.124× |
| memmem/pathological/rare-repeated-huge-tricky | memmem/prebuilt | 8.525 | 7.585 | 1.124× |
| memmem/subtitles/rare/huge-en-sherlock-holmes | memmem/prebuilt | 10.460 | 9.335 | 1.121× |
| memmem/subtitles/rare/huge-en-sherlock | memmem/prebuilt | 11.215 | 10.050 | 1.116× |
| memmem/pathological/rare-repeated-huge-tricky | memmem/oneshot | 8.535 | 7.655 | 1.115× |

## memchr/oneshot

| Benchmark | goostr µs | memchr µs | Ratio |
|---|---:|---:|---:|
| memchr/sherlock/common/huge1 | 227.915 | 236.780 | 0.963× |
| memchr/sherlock/common/small1 | 0.200 | 0.290 | 0.690× |
| memchr/sherlock/common/tiny1 | 0.060 | 0.080 | 0.750× |
| memchr/sherlock/never/empty1 | 0.020 | 0.020 | 1.000× |
| memchr/sherlock/never/huge1 | 5.545 | 5.410 | 1.025× |
| memchr/sherlock/never/small1 | 0.030 | 0.030 | 1.000× |
| memchr/sherlock/never/tiny1 | 0.020 | 0.020 | 1.000× |
| memchr/sherlock/rare/huge1 | 6.935 | 6.860 | 1.011× |
| memchr/sherlock/rare/small1 | 0.030 | 0.030 | 1.000× |
| memchr/sherlock/rare/tiny1 | 0.020 | 0.030 | 0.667× |
| memchr/sherlock/uncommon/huge1 | 83.285 | 92.585 | 0.900× |
| memchr/sherlock/uncommon/small1 | 0.060 | 0.070 | 0.857× |
| memchr/sherlock/uncommon/tiny1 | 0.040 | 0.050 | 0.800× |
| memchr/sherlock/verycommon/huge1 | 470.110 | 481.695 | 0.976× |
| memchr/sherlock/verycommon/small1 | 0.445 | 0.560 | 0.795× |

## memrchr

| Benchmark | goostr µs | memchr µs | Ratio |
|---|---:|---:|---:|
| memchr/sherlock/common/huge1 | 237.225 | 261.495 | 0.907× |
| memchr/sherlock/common/small1 | 0.250 | 0.290 | 0.862× |
| memchr/sherlock/common/tiny1 | 0.070 | 0.080 | 0.875× |
| memchr/sherlock/never/empty1 | 0.020 | 0.020 | 1.000× |
| memchr/sherlock/never/huge1 | 5.490 | 5.390 | 1.019× |
| memchr/sherlock/never/small1 | 0.030 | 0.030 | 1.000× |
| memchr/sherlock/never/tiny1 | 0.020 | 0.020 | 1.000× |
| memchr/sherlock/rare/huge1 | 6.980 | 6.915 | 1.009× |
| memchr/sherlock/rare/small1 | 0.030 | 0.040 | 0.750× |
| memchr/sherlock/rare/tiny1 | 0.020 | 0.040 | 0.500× |
| memchr/sherlock/uncommon/huge1 | 83.775 | 95.640 | 0.876× |
| memchr/sherlock/uncommon/small1 | 0.070 | 0.080 | 0.875× |
| memchr/sherlock/uncommon/tiny1 | 0.040 | 0.050 | 0.800× |
| memchr/sherlock/verycommon/huge1 | 508.230 | 521.740 | 0.974× |
| memchr/sherlock/verycommon/small1 | 0.560 | 0.595 | 0.941× |

## memchr2

| Benchmark | goostr µs | memchr µs | Ratio |
|---|---:|---:|---:|
| memchr/sherlock/common/huge2 | 407.260 | 395.660 | 1.029× |
| memchr/sherlock/common/small2 | 0.355 | 0.430 | 0.826× |
| memchr/sherlock/never/empty2 | 0.020 | 0.020 | 1.000× |
| memchr/sherlock/never/huge2 | 7.235 | 7.175 | 1.008× |
| memchr/sherlock/never/small2 | 0.035 | 0.030 | 1.167× |
| memchr/sherlock/never/tiny2 | 0.020 | 0.020 | 1.000× |
| memchr/sherlock/rare/huge2 | 10.040 | 11.205 | 0.896× |
| memchr/sherlock/rare/small2 | 0.040 | 0.040 | 1.000× |
| memchr/sherlock/rare/tiny2 | 0.030 | 0.040 | 0.750× |
| memchr/sherlock/uncommon/huge2 | 158.400 | 188.950 | 0.838× |
| memchr/sherlock/uncommon/small2 | 0.100 | 0.120 | 0.833× |
| memchr/sherlock/uncommon/tiny2 | 0.060 | 0.080 | 0.750× |

## memrchr2

| Benchmark | goostr µs | memchr µs | Ratio |
|---|---:|---:|---:|
| memchr/sherlock/common/huge2 | 461.320 | 445.085 | 1.036× |
| memchr/sherlock/common/small2 | 0.450 | 0.515 | 0.874× |
| memchr/sherlock/never/empty2 | 0.020 | 0.020 | 1.000× |
| memchr/sherlock/never/huge2 | 7.190 | 7.500 | 0.959× |
| memchr/sherlock/never/small2 | 0.030 | 0.030 | 1.000× |
| memchr/sherlock/never/tiny2 | 0.020 | 0.020 | 1.000× |
| memchr/sherlock/rare/huge2 | 9.675 | 12.105 | 0.799× |
| memchr/sherlock/rare/small2 | 0.040 | 0.050 | 0.800× |
| memchr/sherlock/rare/tiny2 | 0.030 | 0.040 | 0.750× |
| memchr/sherlock/uncommon/huge2 | 163.745 | 200.200 | 0.818× |
| memchr/sherlock/uncommon/small2 | 0.110 | 0.130 | 0.846× |
| memchr/sherlock/uncommon/tiny2 | 0.070 | 0.090 | 0.778× |

## memchr3

| Benchmark | goostr µs | memchr µs | Ratio |
|---|---:|---:|---:|
| memchr/sherlock/common/huge3 | 511.340 | 650.565 | 0.786× |
| memchr/sherlock/common/small3 | 0.575 | 0.690 | 0.833× |
| memchr/sherlock/never/empty3 | 0.020 | 0.020 | 1.000× |
| memchr/sherlock/never/huge3 | 8.845 | 9.040 | 0.978× |
| memchr/sherlock/never/small3 | 0.040 | 0.030 | 1.333× |
| memchr/sherlock/never/tiny3 | 0.020 | 0.025 | 0.800× |
| memchr/sherlock/rare/huge3 | 13.095 | 14.690 | 0.891× |
| memchr/sherlock/rare/small3 | 0.050 | 0.060 | 0.833× |
| memchr/sherlock/rare/tiny3 | 0.030 | 0.050 | 0.600× |
| memchr/sherlock/uncommon/huge3 | 257.905 | 237.245 | 1.087× |
| memchr/sherlock/uncommon/small3 | 0.150 | 0.180 | 0.833× |
| memchr/sherlock/uncommon/tiny3 | 0.090 | 0.110 | 0.818× |

## memrchr3

| Benchmark | goostr µs | memchr µs | Ratio |
|---|---:|---:|---:|
| memchr/sherlock/common/huge3 | 596.945 | 722.840 | 0.826× |
| memchr/sherlock/common/small3 | 0.780 | 0.770 | 1.013× |
| memchr/sherlock/never/empty3 | 0.020 | 0.020 | 1.000× |
| memchr/sherlock/never/huge3 | 8.875 | 9.295 | 0.955× |
| memchr/sherlock/never/small3 | 0.040 | 0.040 | 1.000× |
| memchr/sherlock/never/tiny3 | 0.020 | 0.030 | 0.667× |
| memchr/sherlock/rare/huge3 | 13.150 | 15.800 | 0.832× |
| memchr/sherlock/rare/small3 | 0.050 | 0.060 | 0.833× |
| memchr/sherlock/rare/tiny3 | 0.035 | 0.050 | 0.700× |
| memchr/sherlock/uncommon/huge3 | 268.315 | 250.085 | 1.073× |
| memchr/sherlock/uncommon/small3 | 0.180 | 0.200 | 0.900× |
| memchr/sherlock/uncommon/tiny3 | 0.110 | 0.120 | 0.917× |

## memmem/oneshot

| Benchmark | goostr µs | memchr µs | Ratio |
|---|---:|---:|---:|
| memmem/byterank/binary | 3335.000 | 8615.000 | 0.387× |
| memmem/code/rust-library-common-fn | 109.620 | 129.530 | 0.846× |
| memmem/code/rust-library-common-fn-is-empty | 32.595 | 29.525 | 1.104× |
| memmem/code/rust-library-common-let | 180.800 | 211.485 | 0.855× |
| memmem/code/rust-library-common-paren | 338.130 | 673.675 | 0.502× |
| memmem/code/rust-library-never-fn-quux | 28.420 | 25.235 | 1.126× |
| memmem/code/rust-library-never-fn-strength | 30.760 | 27.700 | 1.110× |
| memmem/code/rust-library-never-fn-strength-paren | 30.930 | 28.390 | 1.089× |
| memmem/code/rust-library-rare-fn-from-str | 31.185 | 28.490 | 1.095× |
| memmem/pathological/defeat-simple-vector-alphabet | 28.005 | 157.165 | 0.178× |
| memmem/pathological/defeat-simple-vector-freq-alphabet | 44.785 | 50.905 | 0.880× |
| memmem/pathological/defeat-simple-vector-repeated-alphabet | 60.290 | 985.000 | 0.061× |
| memmem/pathological/md5-huge-last-hash | 3.600 | 3.530 | 1.020× |
| memmem/pathological/md5-huge-no-hash | 3.560 | 3.345 | 1.064× |
| memmem/pathological/rare-repeated-huge-match | 903.690 | 1820.000 | 0.497× |
| memmem/pathological/rare-repeated-huge-tricky | 8.535 | 7.655 | 1.115× |
| memmem/pathological/rare-repeated-small-match | 1.700 | 3.400 | 0.500× |
| memmem/pathological/rare-repeated-small-tricky | 0.050 | 0.080 | 0.625× |
| memmem/subtitles/common/huge-en-one-space | 460.205 | 1210.000 | 0.380× |
| memmem/subtitles/common/huge-en-that | 37.045 | 46.055 | 0.804× |
| memmem/subtitles/common/huge-en-you | 144.075 | 185.910 | 0.775× |
| memmem/subtitles/common/huge-ru-not | 97.985 | 131.660 | 0.744× |
| memmem/subtitles/common/huge-ru-one-space | 248.770 | 623.215 | 0.399× |
| memmem/subtitles/common/huge-ru-that | 39.130 | 50.895 | 0.769× |
| memmem/subtitles/common/huge-zh-do-not | 85.605 | 112.675 | 0.760× |
| memmem/subtitles/common/huge-zh-one-space | 134.550 | 299.095 | 0.450× |
| memmem/subtitles/common/huge-zh-that | 37.240 | 48.425 | 0.769× |
| memmem/subtitles/never/huge-en-all-common-bytes | 16.515 | 15.855 | 1.042× |
| memmem/subtitles/never/huge-en-john-watson | 10.485 | 9.295 | 1.128× |
| memmem/subtitles/never/huge-en-some-rare-bytes | 10.400 | 9.460 | 1.099× |
| memmem/subtitles/never/huge-en-two-space | 9.395 | 9.345 | 1.005× |
| memmem/subtitles/never/huge-ru-john-watson | 10.445 | 9.460 | 1.104× |
| memmem/subtitles/never/huge-zh-john-watson | 11.365 | 10.200 | 1.114× |
| memmem/subtitles/never/teeny-en-all-common-bytes | 0.020 | 0.040 | 0.500× |
| memmem/subtitles/never/teeny-en-john-watson | 0.020 | 0.040 | 0.500× |
| memmem/subtitles/never/teeny-en-some-rare-bytes | 0.020 | 0.040 | 0.500× |
| memmem/subtitles/never/teeny-en-two-space | 0.020 | 0.040 | 0.500× |
| memmem/subtitles/never/teeny-ru-john-watson | 0.020 | 0.050 | 0.400× |
| memmem/subtitles/never/teeny-zh-john-watson | 0.020 | 0.040 | 0.500× |
| memmem/subtitles/rare/huge-en-huge-needle | 12.320 | 10.430 | 1.181× |
| memmem/subtitles/rare/huge-en-long-needle | 10.100 | 9.125 | 1.107× |
| memmem/subtitles/rare/huge-en-medium-needle | 12.010 | 11.165 | 1.076× |
| memmem/subtitles/rare/huge-en-sherlock | 10.730 | 9.670 | 1.110× |
| memmem/subtitles/rare/huge-en-sherlock-holmes | 10.830 | 9.435 | 1.148× |
| memmem/subtitles/rare/huge-ru-sherlock | 10.600 | 9.780 | 1.084× |
| memmem/subtitles/rare/huge-ru-sherlock-holmes | 10.485 | 9.455 | 1.109× |
| memmem/subtitles/rare/huge-zh-sherlock | 11.175 | 10.085 | 1.108× |
| memmem/subtitles/rare/huge-zh-sherlock-holmes | 11.725 | 10.665 | 1.099× |
| memmem/subtitles/rare/teeny-en-sherlock | 0.030 | 0.040 | 0.750× |
| memmem/subtitles/rare/teeny-en-sherlock-holmes | 0.040 | 0.040 | 1.000× |
| memmem/subtitles/rare/teeny-ru-sherlock | 0.030 | 0.050 | 0.600× |
| memmem/subtitles/rare/teeny-ru-sherlock-holmes | 0.025 | 0.050 | 0.500× |
| memmem/subtitles/rare/teeny-zh-sherlock | 0.030 | 0.040 | 0.750× |
| memmem/subtitles/rare/teeny-zh-sherlock-holmes | 0.040 | 0.050 | 0.800× |

## memmem/prebuilt

| Benchmark | goostr µs | memchr µs | Ratio |
|---|---:|---:|---:|
| memmem/byterank/binary | 3335.000 | 8590.000 | 0.388× |
| memmem/code/rust-library-common-fn | 71.260 | 67.635 | 1.054× |
| memmem/code/rust-library-common-fn-is-empty | 31.580 | 28.880 | 1.093× |
| memmem/code/rust-library-common-let | 116.015 | 111.795 | 1.038× |
| memmem/code/rust-library-common-paren | 339.610 | 417.780 | 0.813× |
| memmem/code/rust-library-never-fn-quux | 28.435 | 25.180 | 1.129× |
| memmem/code/rust-library-never-fn-strength | 30.620 | 27.705 | 1.105× |
| memmem/code/rust-library-never-fn-strength-paren | 31.970 | 28.225 | 1.133× |
| memmem/code/rust-library-rare-fn-from-str | 31.090 | 28.490 | 1.091× |
| memmem/pathological/defeat-simple-vector-alphabet | 27.915 | 157.920 | 0.177× |
| memmem/pathological/defeat-simple-vector-freq-alphabet | 44.480 | 50.665 | 0.878× |
| memmem/pathological/defeat-simple-vector-repeated-alphabet | 59.890 | 980.000 | 0.061× |
| memmem/pathological/md5-huge-last-hash | 3.430 | 3.280 | 1.046× |
| memmem/pathological/md5-huge-no-hash | 3.490 | 3.350 | 1.042× |
| memmem/pathological/rare-repeated-huge-match | 332.470 | 424.545 | 0.783× |
| memmem/pathological/rare-repeated-huge-tricky | 8.525 | 7.585 | 1.124× |
| memmem/pathological/rare-repeated-small-match | 0.505 | 0.870 | 0.580× |
| memmem/pathological/rare-repeated-small-tricky | 0.040 | 0.040 | 1.000× |
| memmem/sliceslice/i386 | 15880.000 | 14430.000 | 1.100× |
| memmem/sliceslice/seemingly-random | 119.610 | 115.355 | 1.037× |
| memmem/sliceslice/short | 4835.000 | 9510.000 | 0.508× |
| memmem/subtitles/common/huge-en-one-space | 484.765 | 647.365 | 0.749× |
| memmem/subtitles/common/huge-en-that | 26.005 | 26.090 | 0.997× |
| memmem/subtitles/common/huge-en-you | 59.035 | 58.025 | 1.017× |
| memmem/subtitles/common/huge-ru-not | 52.115 | 55.305 | 0.942× |
| memmem/subtitles/common/huge-ru-one-space | 255.920 | 339.260 | 0.754× |
| memmem/subtitles/common/huge-ru-that | 23.330 | 23.750 | 0.982× |
| memmem/subtitles/common/huge-zh-do-not | 45.730 | 44.080 | 1.037× |
| memmem/subtitles/common/huge-zh-one-space | 133.205 | 176.840 | 0.753× |
| memmem/subtitles/common/huge-zh-that | 23.185 | 23.645 | 0.981× |
| memmem/subtitles/never/huge-en-all-common-bytes | 16.050 | 14.455 | 1.110× |
| memmem/subtitles/never/huge-en-john-watson | 10.455 | 9.200 | 1.136× |
| memmem/subtitles/never/huge-en-some-rare-bytes | 10.395 | 9.625 | 1.080× |
| memmem/subtitles/never/huge-en-two-space | 9.405 | 9.315 | 1.010× |
| memmem/subtitles/never/huge-ru-john-watson | 10.450 | 9.295 | 1.124× |
| memmem/subtitles/never/huge-zh-john-watson | 11.355 | 10.275 | 1.105× |
| memmem/subtitles/never/teeny-en-all-common-bytes | 0.020 | 0.030 | 0.667× |
| memmem/subtitles/never/teeny-en-john-watson | 0.020 | 0.030 | 0.667× |
| memmem/subtitles/never/teeny-en-some-rare-bytes | 0.020 | 0.030 | 0.667× |
| memmem/subtitles/never/teeny-en-two-space | 0.020 | 0.030 | 0.667× |
| memmem/subtitles/never/teeny-ru-john-watson | 0.020 | 0.030 | 0.667× |
| memmem/subtitles/never/teeny-zh-john-watson | 0.020 | 0.030 | 0.667× |
| memmem/subtitles/rare/huge-en-huge-needle | 9.765 | 8.395 | 1.163× |
| memmem/subtitles/rare/huge-en-long-needle | 9.385 | 8.705 | 1.078× |
| memmem/subtitles/rare/huge-en-medium-needle | 12.115 | 11.275 | 1.075× |
| memmem/subtitles/rare/huge-en-sherlock | 11.215 | 10.050 | 1.116× |
| memmem/subtitles/rare/huge-en-sherlock-holmes | 10.460 | 9.335 | 1.121× |
| memmem/subtitles/rare/huge-ru-sherlock | 10.555 | 9.335 | 1.131× |
| memmem/subtitles/rare/huge-ru-sherlock-holmes | 10.550 | 9.320 | 1.132× |
| memmem/subtitles/rare/huge-zh-sherlock | 10.990 | 10.140 | 1.084× |
| memmem/subtitles/rare/huge-zh-sherlock-holmes | 11.615 | 10.750 | 1.080× |
| memmem/subtitles/rare/teeny-en-sherlock | 0.030 | 0.030 | 1.000× |
| memmem/subtitles/rare/teeny-en-sherlock-holmes | 0.030 | 0.030 | 1.000× |
| memmem/subtitles/rare/teeny-ru-sherlock | 0.030 | 0.030 | 1.000× |
| memmem/subtitles/rare/teeny-ru-sherlock-holmes | 0.030 | 0.030 | 1.000× |
| memmem/subtitles/rare/teeny-zh-sherlock | 0.030 | 0.040 | 0.750× |
| memmem/subtitles/rare/teeny-zh-sherlock-holmes | 0.030 | 0.040 | 0.750× |
