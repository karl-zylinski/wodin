package main

import "base:intrinsics"
import "core:fmt"

run :: proc($R, $C: u32, $T: typeid) {
	returns_matrix :: proc() -> (m: matrix[R, C]T) {
		for i in 0..<R {
			for j in 0..<C {
				m[i, j] = T(i*C + j + 1)
			}
		}
		return
	}
	v: [C]T
	for j in 0..<C {
		v[j] = T(j*3) - 2
	}
	w: [R]T
	for i in 0..<R {
		w[i] = T(i*5 + 1)
	}
	fmt.println(returns_matrix() * v)
	fmt.println(w * returns_matrix())
	fmt.println(returns_matrix() * intrinsics.transpose(returns_matrix()))
	fmt.println(returns_matrix() + returns_matrix())
}

main :: proc() {
	run(1, 1, i128)
	run(2, 3, i128)
	run(4, 4, i128)
	run(3, 2, u128)
	run(2, 2, f16)
	run(3, 4, i8)

	m := matrix[2, 2]i128{
		0x7fffffffffffffff, 1 << 70,
		-3, -0x8000000000000000,
	}
	fmt.println(m * [2]i128{1 << 60, -7})
	fmt.println([2]i128{1 << 60, -7} * m)
	fmt.println(m * m)
}
