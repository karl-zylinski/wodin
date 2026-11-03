package main

import "core:fmt"
import "core:simd"

@(optimization_mode="none")
shl_u32_u128 :: proc(x: u32, n: u128) -> u32 { return x << n }
@(optimization_mode="none")
shr_i32_u128 :: proc(x: i32, n: u128) -> i32 { return x >> n }
@(optimization_mode="none")
shl_u8_u64 :: proc(x: u8, n: u64) -> u8 { return x << n }
@(optimization_mode="none")
shl_u128_u128 :: proc(x: u128, n: u128) -> u128 { return x << n }
@(optimization_mode="none")
shr_u128_u128 :: proc(x: u128, n: u128) -> u128 { return x >> n }
@(optimization_mode="none")
shr_u128_u64 :: proc(x: u128, n: u64) -> u128 { return x >> n }
@(optimization_mode="none")
shl_u64_u128 :: proc(x: u64, n: u128) -> u64 { return x << n }

main :: proc() {
	amounts := [?]u128{0, 1, 7, 8, 31, 32, 63, 64, 65, 127, 128, 129, 256, 1 << 64, (1 << 64) + 1, (1 << 64) + 3, max(u128)}
	for n in amounts {
		fmt.println(n, shl_u32_u128(0xdeadbeef, n), shr_i32_u128(-12345, n), shl_u64_u128(0x1234567890abcdef, n))
		fmt.println(n, shl_u128_u128(0x1234567890abcdef_fedcba0987654321, n), shr_u128_u128(0x1234567890abcdef_fedcba0987654321, n))
	}
	amounts64 := [?]u64{0, 1, 7, 8, 9, 63, 64, 127, 128, 256, 257, max(u64)}
	for n in amounts64 {
		fmt.println(n, shl_u8_u64(0xab, n), shr_u128_u64(0x1234567890abcdef_fedcba0987654321, n))
	}

	a := #simd[4]u8{1, 2, 3, 0xff}
	b := #simd[4]u16{256, 1, 257, 7}
	fmt.println(simd.shl(a, b), simd.shr(a, b))
	c := #simd[4]i8{-1, -128, 64, 3}
	d := #simd[4]u32{8, 1 << 16, 7, 0x10002}
	fmt.println(simd.shl(c, d), simd.shr(c, d))
	e := #simd[2]u16{0xffff, 0x1234}
	f := #simd[2]u64{1 << 32, 4}
	fmt.println(simd.shl(e, f), simd.shr(e, f))
	fmt.println(simd.shl_masked(a, b), simd.shr_masked(a, b), simd.shl_masked(c, d), simd.shr_masked(c, d))
}
