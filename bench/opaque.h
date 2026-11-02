#ifndef GOOSTR_BENCH_OPAQUE_H
#define GOOSTR_BENCH_OPAQUE_H

#include <stdint.h>

#ifdef GOOSTR_BENCH_EXTERNAL
extern int64_t goostr_bench_opaque(sl_u8 s);
static inline int64_t goostr_bench_opaque_len(sl_u8 s) {
    return goostr_bench_opaque(s);
}
#else
// Keep the slice in memory across an opaque operation, like Rust's black_box.
// Returning its length preserves the checked-slice wrapper in both runners.
static inline __attribute__((always_inline)) int64_t goostr_bench_opaque_len(sl_u8 s) {
    __asm__ __volatile__("" : "+m"(s) : : "memory");
    return s.len;
}
#endif

#endif
