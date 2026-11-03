package main

import "core:fmt"

three :: proc() -> (f32, f32, f32) { return 1, 2, 3 }
two :: proc() -> (int, int) { return 7, 8 }
pair :: proc() -> (u64, u64) { return 10, 20 }
mixed :: proc() -> (i64, f64, string) { return 4, 5.5, "six" }

S :: struct {
	a, b, c, d, e: u64,
}

M :: struct {
	x: i64,
	y: f64,
	s: string,
	z: u8,
}

Point :: [3]f32

main :: proc() {
	m := matrix[2, 2]f32{three(), 4}
	fmt.println(m)
	n := matrix[2, 2]f32{4, three()}
	fmt.println(n)
	r := #row_major matrix[2, 3]f32{9, three(), 5, 6}
	fmt.println(r)

	a := #simd[4]int{two(), 5, 6}
	fmt.println(transmute([4]int)a)
	b := #simd[4]int{5, two(), 6}
	fmt.println(transmute([4]int)b)
	c := #simd[4]int{two(), 5}
	fmt.println(transmute([4]int)c)

	s0 := S{pair(), 3, 4, 5}
	fmt.println(s0)
	s1 := S{1, pair(), pair()}
	fmt.println(s1)
	s2 := S{pair(), pair(), 1}
	fmt.println(s2)

	mm := M{mixed(), 200}
	fmt.println(mm)

	arr := [6]int{two(), 1, two(), 2}
	fmt.println(arr)
	p := Point{three()}
	fmt.println(p)
	sl := []int{two(), two(), 9}
	fmt.println(sl)
	fc := [dynamic; 8]int{two(), 3}
	fmt.println(len(fc), fc[:])
	fc2 := [dynamic; 8]int{1, two(), two()}
	fmt.println(len(fc2), fc2[:])
	f := [5]int{two(), 1, two()}
	fmt.println(f)
}
