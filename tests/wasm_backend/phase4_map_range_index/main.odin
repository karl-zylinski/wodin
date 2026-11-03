package main

import "core:fmt"

Vec :: struct {
	x, y: int,
}

main :: proc() {
	arrays: map[string][4]int
	defer delete(arrays)
	arrays["a"] = {1, 2, 3, 4}

	for x, i in arrays["a"] {
		fmt.println("a", i, x)
	}
	for x, i in arrays["missing"] {
		fmt.println("missing", i, x)
	}
	fmt.println(len(arrays), "missing" in arrays)
	sum := 0
	for x in arrays["a"] {
		sum += x
	}
	for x in arrays["missing"] {
		sum += x + 1
	}
	fmt.println(sum)

	dyns: map[int][dynamic]Vec
	defer {
		for _, v in dyns {
			delete(v)
		}
		delete(dyns)
	}
	dyns[1] = make([dynamic]Vec)
	append(&dyns[1], Vec{1, 2}, Vec{3, 4})
	for &v in dyns[1] {
		v.x += 100
	}
	for &v in dyns[2] {
		v.x = 7
		fmt.println("never")
	}
	fmt.println(dyns[1][:])

	nested: map[int]map[string]int
	defer {
		for _, v in nested {
			delete(v)
		}
		delete(nested)
	}
	inner: map[string]int
	inner["k"] = 5
	nested[1] = inner
	for k, &v in nested[1] {
		v += 1
		fmt.println(k, v)
	}
	for k, v in nested[2] {
		fmt.println("never", k, v)
	}
	fmt.println(nested[1]["k"])

	enums: map[int][enum{A, B, C}]f32
	defer delete(enums)
	enums[3] = {.A = 1, .B = 2, .C = 3}
	for x, e in enums[3] {
		fmt.println(e, x)
	}
	for x, e in enums[4] {
		fmt.println("zero", e, x)
	}
	fmt.println(enums[3], len(enums))
}
