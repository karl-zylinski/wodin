package main

import "core:fmt"

// `%%` is floored modulo: the result takes the sign of the divisor. The
// obvious `((a % b) + b) % b` overflows for the extreme values here.

floor_mod :: proc(x, y: $T) -> T {
	r := x % y
	if r != 0 && (r < 0) != (y < 0) {
		r += y
	}
	return r
}

main :: proc() {
	// every i8 pair against the reference
	bad := 0
	for x := -128; x <= 127; x += 1 {
		for y := -128; y <= 127; y += 1 {
			if y == 0 || (x == -128 && y == -1) {
				continue
			}
			a := i8(x) %% i8(y)
			if a != floor_mod(i8(x), i8(y)) {
				bad += 1
			}
		}
	}
	fmt.println("i8 mismatches:", bad)

	// the sums that wrap
	fmt.println(1 %% i32(2147483647), i32(2147483646) %% 2147483647, i32(-2147483647) %% 2147483646, i32(-2147483648) %% 2147483647)
	fmt.println(1 %% i64(max(i64)), i64(max(i64)-1) %% max(i64), min(i64) %% max(i64), i64(-7) %% 3, i64(7) %% -3, i64(-7) %% -3)
	fmt.println(i16(-32768) %% 32767, i16(32766) %% 32767, i16(-3) %% 5, i16(3) %% -5)
	fmt.println(i128(1) %% max(i128), (max(i128)-1) %% max(i128), min(i128) %% max(i128), i128(-7) %% 3, i128(7) %% -3, i128(-7) %% -3, i128(0) %% -5)

	// constant divisors, the sign of each
	for x in ([]i32{-3000, -2999, -1, 0, 1, 2999, 3000, 3001, min(i32), max(i32)}) {
		fmt.println(x, x %% 3000, x %% -3000, x %% 7, x %% -7, x %% 1)
	}

	// unsigned: plain remainder
	fmt.println(u8(255) %% 7, u32(4000000000) %% 3, u64(max(u64)) %% 10, u128(max(u128)) %% 7)

	// vectors, lane by lane
	v := [4]i32{2147483646, -3, 7, -7} %% [4]i32{2147483647, 5, -5, -5}
	fmt.println(v)
	w := [3]i64{max(i64) - 1, -1, 5} %% [3]i64{max(i64), max(i64), -3}
	fmt.println(w)

	// compound assignment and endian-specific operands
	a: i32 = 1
	a %%= 2147483647
	b: i64 = -7
	b %%= 3
	fmt.println(a, b)
	e: i32be = -7
	fmt.println(e %% 3, e %% -3, i32be(1) %% i32be(2147483647), i64le(-7) %% 3)
}
