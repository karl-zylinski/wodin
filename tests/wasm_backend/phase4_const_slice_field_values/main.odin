package main

import "core:fmt"

take :: proc(a: []u8) -> []u8 { return a }
take_f :: proc(a: []f32) -> []f32 { return a }
take_s :: proc(a: []string) -> []string { return a }

Pair :: struct { a: i32, b: i16 }
take_p :: proc(a: []Pair) -> []Pair { return a }

E :: enum { A, B, C }

main :: proc() {
	fmt.println(take({0 = 1, 1 = 2, 2 = 3}))
	fmt.println(take({2 = 7, 0 = 5}))
	fmt.println(take({1..=3 = 9}))
	fmt.println(take({0..<2 = 4, 5 = 6}))
	fmt.println(take_f({3 = 1.5, 1 = -2}))
	fmt.println(take_s({1 = "b", 3 = "d"}))
	fmt.println(take_p({1 = {3, 4}, 0 = {a = 1}}))
	@(static) s := []u8{4 = 1, 1 = 2}
	fmt.println(s, len(s))
	x := []i64{2 = max(i64), 0 = -1}
	fmt.println(x, len(x))
	fmt.println(len(take({7 = 0})))
}
