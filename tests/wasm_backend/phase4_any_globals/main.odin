package main

import "core:fmt"

// An `any` given a constant at global scope is a pointer to a copy of the
// constant and its typeid, made at startup; it is not the constant's bytes.
G: any = 1
GF: any = f32(1.25)
GS: any = "text"
GP: any = from_proc()

from_proc :: proc "contextless" () -> f64 {
	return 2.5
}

main :: proc() {
	v, ok := G.(int)
	fmt.println(v, ok, G.id == typeid_of(int))
	f, okf := GF.(f32)
	fmt.println(f, okf, GF.id == typeid_of(f32))
	s, oks := GS.(string)
	fmt.println(s, oks, GS.id == typeid_of(string))
	d, okd := GP.(f64)
	fmt.println(d, okd)

	@(static) st: any = 3
	x, okx := st.(int)
	fmt.println(x, okx, st.id == typeid_of(int))
	st = f32(1.5)
	y, oky := st.(f32)
	fmt.println(y, oky)

	l: any = 5
	z, okz := l.(int)
	fmt.println(z, okz)

	G = "changed"
	c, okc := G.(string)
	fmt.println(c, okc)
	fmt.println(G, GF, GS, GP)
}
