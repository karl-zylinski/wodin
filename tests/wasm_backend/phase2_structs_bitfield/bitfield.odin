package main

import "core:fmt"

BF :: bit_field u32 {
	a: u8   | 3,
	b: u16  | 9,
	c: bool | 1,
	d: u8   | 7,
}

main :: proc() {
	bf: BF
	bf.a = 5
	bf.b = 300
	bf.c = true
	bf.d = 100
	fmt.println(bf.a, bf.b, bf.c, bf.d)
	backing := transmute(u32)bf
	bf2 := transmute(BF)backing
	fmt.println(bf2.a, bf2.b, bf2.c, bf2.d)

	// A literal of constants is a constant of the backing type, packed
	C :: u8(3)
	v := BF{a = C, b = 300, c = true, d = 100}
	fmt.println(v.a, v.b, v.c, v.d, transmute(u32)v)
	fmt.println(G_BF.a, G_BF.b, G_BF.c, G_BF.d, transmute(u32)G_BF)
	arr := [3]BF{{a = 1, d = 2}, {b = 511, c = true}, {}}
	fmt.println(arr[0].a, arr[0].d, arr[1].b, arr[1].c, arr[2].a, transmute([3]u32)arr)
	s := S{s = -3, t = -200, e = .Three, f = false}
	fmt.println(s.s, s.t, s.e, s.f, transmute(u16)s)
	fmt.println(G_S.s, G_S.t, G_S.e, transmute(u16)G_S)
	w := W8{n = 3, s = -2, e = .One, r = 7}
	fmt.println(w.n, w.s, w.e, w.r, transmute(u8)w)
	big := Big{lo = 0xDEADBEEF, hi = 0x1234567, flag = true}
	fmt.println(big.lo, big.hi, big.flag, transmute(u64)big)
}

Number :: enum u8 { Zero, One, Two, Three }

S :: bit_field u16 {
	s: i8     | 4,
	t: i16    | 9,
	e: Number | 2,
	f: bool   | 1,
}

W8 :: bit_field u8 { n: u8 | 2, s: i8 | 2, e: Number | 1, r: u8 | 3 }

Big :: bit_field u64 { lo: u32 | 32, hi: u32 | 31, flag: bool | 1 }

G_BF := BF{a = 7, b = 1, c = false, d = 127}
G_S  := S{s = 5, t = 255, e = .Two, f = true}
