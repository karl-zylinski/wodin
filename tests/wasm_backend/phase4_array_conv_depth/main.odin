package main

import "core:fmt"

Vec2 :: [2]f32

Item :: struct {
	a: int,
	b: f32,
}

main :: proc() {
	a := [2][2]i32{{1, 2}, {3, 4}}
	fmt.println(cast([2][2]int)a)
	b := [2][2]u64{{1, 2}, {3, 4}}
	fmt.println(cast([2][2]f64)b)

	c := [2]f32{1, 2}
	d: [2][2]f32 = c
	fmt.println(d)

	e := [3]i32{5, 6, 7}
	f: [3][3]i32 = e
	fmt.println(f)

	g: [2][3][3]i32 = e
	fmt.println(g)

	v := Vec2{9, 8}
	h: [2]Vec2 = v
	fmt.println(h)

	it := Item{3, 4.5}
	items: [3]Item = it
	fmt.println(items)
	nested: [2][2]Item = it
	fmt.println(nested)

	s := "str"
	strs: [2][2]string = s
	fmt.println(strs)

	x := 11
	sc: [2][2]int = x
	fmt.println(sc)
}
