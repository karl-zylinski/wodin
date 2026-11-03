package main

import "base:intrinsics"
import "core:fmt"
import "core:math"

@(optimization_mode="none")
cas32 :: proc(dst: ^f32, expected, new: f32) -> (f32, bool) {
	return intrinsics.atomic_compare_exchange_strong(dst, expected, new)
}

@(optimization_mode="none")
cas64 :: proc(dst: ^f64, expected, new: f64) -> (f64, bool) {
	return intrinsics.atomic_compare_exchange_weak(dst, expected, new)
}

@(optimization_mode="none")
cas16 :: proc(dst: ^f16, expected, new: f16) -> (f16, bool) {
	return intrinsics.atomic_compare_exchange_strong_explicit(dst, expected, new, .Seq_Cst, .Seq_Cst)
}

main :: proc() {
	nan32 := transmute(f32)u32(0x7fc00001)
	other_nan32 := transmute(f32)u32(0x7fc00002)
	a := nan32
	old, ok := cas32(&a, nan32, 1)
	fmt.println(transmute(u32)old, ok, a)
	a = nan32
	old, ok = cas32(&a, other_nan32, 2)
	fmt.println(transmute(u32)old, ok, transmute(u32)a)
	a = 0
	old, ok = cas32(&a, -0.0, 3)
	fmt.println(old, ok, a)
	a = 5
	old, ok = cas32(&a, 5, 6)
	fmt.println(old, ok, a)

	nan64 := math.nan_f64()
	b := nan64
	old64, ok64 := cas64(&b, nan64, 1)
	fmt.println(ok64, b)
	b = -0.0
	old64, ok64 = cas64(&b, 0, 2)
	fmt.println(old64, ok64, b)
	b = 7
	old64, ok64 = cas64(&b, 7, 8)
	fmt.println(old64, ok64, b)

	nan16 := transmute(f16)u16(0x7e01)
	c := nan16
	old16, ok16 := cas16(&c, nan16, 1)
	fmt.println(transmute(u16)old16, ok16, c)
	c = 0
	old16, ok16 = cas16(&c, -0.0, 3)
	fmt.println(old16, ok16, c)
}
