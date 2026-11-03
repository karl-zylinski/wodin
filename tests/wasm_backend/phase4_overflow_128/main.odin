package main

import "base:intrinsics"
import "core:fmt"

check_u :: proc(a, b: u128) {
	s, so := intrinsics.overflow_add(a, b)
	d, do_ := intrinsics.overflow_sub(a, b)
	m, mo := intrinsics.overflow_mul(a, b)
	fmt.printf("%x %x: add %x %v sub %x %v mul %x %v\n", a, b, s, so, d, do_, m, mo)
}

check_s :: proc(a, b: i128) {
	s, so := intrinsics.overflow_add(a, b)
	d, do_ := intrinsics.overflow_sub(a, b)
	fmt.println(a, b, "add", s, so, "sub", d, do_)
}

next_u128 :: proc(s: ^u64) -> u128 {
	s^ = s^*6364136223846793005 + 1442695040888963407
	hi := s^
	s^ = s^*6364136223846793005 + 1442695040888963407
	return u128(hi) << 64 | u128(s^)
}

main :: proc() {
	us := []u128{0, 1, 2, 3, 0xffffffffffffffff, 0x10000000000000000, 0x10000000000000001, 1 << 127, max(u128), max(u128) - 1, max(u128) / 3}
	for a in us {
		for b in us {
			check_u(a, b)
		}
	}
	ss := []i128{0, 1, -1, 2, -2, 3, max(i128), min(i128), max(i128) - 1, min(i128) + 1, 0x7fffffffffffffff, -0x8000000000000000, 1 << 64, -(1 << 64), 1 << 63}
	for a in ss {
		for b in ss {
			check_s(a, b)
		}
	}

	s := u64(0x9e37_79b9_7f4a_7c15)
	counts: [5]int
	sum: u128
	for _ in 0..<2000 {
		a := next_u128(&s) >> (s & 127)
		b := next_u128(&s) >> ((s >> 8) & 127)
		r, o := intrinsics.overflow_mul(a, b)
		if o { counts[0] += 1 }
		sum ~= r
		r, o = intrinsics.overflow_add(a, b)
		if o { counts[1] += 1 }
		sum ~= r
		r, o = intrinsics.overflow_sub(a, b)
		if o { counts[2] += 1 }
		sum ~= r
		x, y := i128(a), i128(b)
		q, qo := intrinsics.overflow_add(x, y)
		if qo { counts[3] += 1 }
		sum ~= u128(q)
		q, qo = intrinsics.overflow_sub(x, y)
		if qo { counts[4] += 1 }
		sum ~= u128(q)
	}
	fmt.printf("%v %x\n", counts, sum)

	le_a, le_b := u128le(max(u64)), u128le(1 << 64)
	le_r, le_o := intrinsics.overflow_mul(le_a, le_b)
	fmt.println(le_r, le_o)
	le_r, le_o = intrinsics.overflow_mul(le_a, le_b + 1)
	fmt.println(le_r, le_o)
	le_r, le_o = intrinsics.overflow_mul(le_a + 2, le_b)
	fmt.println(le_r, le_o)
}
