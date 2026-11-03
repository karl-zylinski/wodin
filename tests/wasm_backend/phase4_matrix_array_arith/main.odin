package main

import "core:fmt"

M :: matrix[2, 2]f32

main :: proc() {
	a := [2]M{{0, 1, 2, 3}, {4, 5, 6, 7}}
	b := M{10, 10, 10, 10}
	c := M{1, 2, 3, 4}

	fmt.println("a+b", a + b)
	fmt.println("b-a", b - a)
	fmt.println("a*b", a * b)
	fmt.println("b*a", b * a)
	fmt.println("a*a", a * a)
	fmt.println("a/b", a / b)

	n := [2][2]M{{a[0], a[1]}, {a[1], a[0]}}
	fmt.println("n*b", n * b)
	fmt.println("c*n", c * n)
	fmt.println("n+n", n + n)

	big: [10]M
	for i in 0..<10 {
		big[i] = M{f32(i), 1, 2, f32(-i)}
	}
	fmt.println("big*c", big * c)
	fmt.println("c*big", c * big)

	a *= b
	fmt.println("a*=b", a)
	a += c
	fmt.println("a+=c", a)

	v := [2]f32{1, 2}
	fmt.println("c*v", c * v, "v*c", v * c)

	r := [3]matrix[2, 2]i32{}
	for i in 0..<3 {
		r[i] = matrix[2, 2]i32{i32(i), 1, 2, 3}
	}
	q := matrix[2, 2]i32{1, 0, -1, 1}
	fmt.println("r*q", r * q, "q*r", q * r, "r-q", r - q)

	d := [2]matrix[2, 2]f64{{1, 2, 3, 4}, {5, 6, 7, 8}}
	e := matrix[2, 2]f64{0.5, 0, 0, 2}
	fmt.println("d*e", d * e, "e*d", e * d)
}
