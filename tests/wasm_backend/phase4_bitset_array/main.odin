package main

import "core:fmt"

E :: enum u8 { A, B, C, D, E, F, G, H }

Gap :: enum u8 { A = 0, C = 2, F = 5 }

Big :: enum { V0 = 0, V3 = 3, V64 = 64, V127 = 127, V128 = 128, V200 = 200, V255 = 255 }

S32  :: bit_set[E; [4]u64]
S16  :: bit_set[E; [2]u64]
S8   :: bit_set[E; [1]u64]
S4   :: bit_set[E; [2]u16]
S3   :: bit_set[E; [3]u8]
S12  :: bit_set[E; [3]u32]
S10  :: bit_set[E; [5]u16]
SI   :: bit_set[E; u16]
G24  :: bit_set[Gap; [3]u64]
B256 :: bit_set[Big; [4]u64]
R40  :: bit_set[0..<300; [5]u64]
RL   :: bit_set[10..<150; [3]u64]

Holder :: struct {
	tag: u8,
	set: B256,
	n:   i32,
}

G_CONST :: S32{.A, .H}
g_var := B256{.V3, .V255}
g_full := ~S32{}

from_mask :: proc($S: typeid, m: u8) -> (s: S) {
	for i in 0..<8 {
		if (m >> uint(i)) & 1 == 1 {
			s += {E(i)}
		}
	}
	return
}

pick :: proc(a, b: $S, first: bool) -> S {
	if first {
		return a
	}
	return b
}

relations :: proc(name: string, a, b: $S) {
	fmt.println(name, a < b, a <= b, a > b, a >= b, a == b, a != b)
	fmt.println(name, card(a), card(b), card(a | b), card(a & b), card(a &~ b), card(~a), card(a + b), card(a - b))
	fmt.println(name, a | b, a & b, a &~ b, ~a, a + b, a - b)
}

exhaustive :: proc($S: typeid, name: string) {
	mismatches := 0
	for a in 0..<256 {
		for b in 0..<256 {
			aa, ab := from_mask(S, u8(a)), from_mask(S, u8(b))
			ia, ib := from_mask(SI, u8(a)), from_mask(SI, u8(b))
			if (aa <  ab) != (ia <  ib) { mismatches += 1 }
			if (aa <= ab) != (ia <= ib) { mismatches += 1 }
			if (aa >  ab) != (ia >  ib) { mismatches += 1 }
			if (aa >= ab) != (ia >= ib) { mismatches += 1 }
			if (aa == ab) != (ia == ib) { mismatches += 1 }
			if (aa != ab) != (ia != ib) { mismatches += 1 }
			if card(aa | ab)  != card(ia | ib)  { mismatches += 1 }
			if card(aa & ab)  != card(ia & ib)  { mismatches += 1 }
			if card(aa &~ ab) != card(ia &~ ib) { mismatches += 1 }
			if card(~aa)      != card(~ia)      { mismatches += 1 }
			for i in 0..<8 {
				if (E(i) in aa) != (E(i) in ia) { mismatches += 1 }
				if (E(i) not_in ab) != (E(i) not_in ib) { mismatches += 1 }
			}
		}
	}
	fmt.println(name, "mismatches:", mismatches)
}

membership :: proc(name: string, s: $S) {
	for i in 0..<8 {
		k := E(i)
		fmt.print(k in s, k not_in s, "")
	}
	fmt.println(name, .A in s, .H not_in s)
}

main :: proc() {
	a := S32{.A, .C, .E}
	b := S32{.C, .E, .G}
	relations("s32", a, b)
	relations("s32 sub", S32{.B, .C}, S32{.A, .B, .C, .D})
	relations("s32 same", a, a)
	membership("s32", a)

	relations("s16", from_mask(S16, 0b0101_0011), from_mask(S16, 0b1101_0011))
	relations("s8", from_mask(S8, 0b0001_0011), from_mask(S8, 0b1101_0010))
	relations("s4", from_mask(S4, 0b1001_0011), from_mask(S4, 0b0001_0010))
	relations("s3", from_mask(S3, 0b1001_0011), from_mask(S3, 0b0001_0010))
	relations("s12", from_mask(S12, 0b0011_1100), from_mask(S12, 0b0011_1100))
	relations("s10", from_mask(S10, 0b0000_0100), from_mask(S10, 0b1111_0110))
	membership("s3", from_mask(S3, 0b1010_0101))
	membership("s12", from_mask(S12, 0b0101_1010))
	membership("s16", from_mask(S16, 0b1100_0011))

	exhaustive(S32, "s32")
	exhaustive(S16, "s16")
	exhaustive(S8, "s8")
	exhaustive(S3, "s3")
	exhaustive(S12, "s12")
	exhaustive(S10, "s10")

	x, y := E.B, E.G
	r := S32{x, y, .D}
	fmt.println("runtime literal", r, card(r), transmute([4]u64)r)
	r16 := S16{x, y}
	r3 := S3{x, y}
	r12 := S12{y}
	fmt.println("runtime literals", r16, r3, r12, transmute([3]u8)r3, transmute([3]u32)r12)

	s := S32{.A}
	s += {.C}
	s |= {.E}
	s += {x}
	fmt.println("assign", s)
	s -= {.A}
	s &~= {.C}
	s -= {x}
	fmt.println("assign", s)
	s = S32{.A, .B, .C}
	s &= {.B, .C, .D}
	fmt.println("assign", s, s == {.B, .C}, s != {.B, .C})

	fmt.println("const", G_CONST, card(G_CONST), ~G_CONST, g_full, card(g_full), transmute([4]u64)g_full)

	stray := transmute(S32)[4]u64{0b1_0000_0100, 1 << 63, 7, 1 << 40}
	fmt.println("stray", ~stray, transmute([4]u64)(~stray), stray == {.C}, card(stray))
	gs := transmute(G24)[3]u64{0b1110, 1, 2}
	fmt.println("gap", ~gs, transmute([3]u64)(~gs), card(~gs), ~G24{}, transmute([3]u64)(~G24{}))
	g16 := transmute(S16)[2]u64{0b1_0000_0100, 1 << 63}
	fmt.println("stray16", ~g16, transmute([2]u64)(~g16))
	g8 := transmute(S8)[1]u64{0b1_0000_0100}
	fmt.println("stray8", ~g8, transmute([1]u64)(~g8))

	big := B256{.V0, .V128, .V200}
	v := Big.V255
	big2 := B256{v, .V64, .V128}
	fmt.println("big", big, card(big), .V200 in big, .V64 not_in big, v in big, v in big2)
	fmt.println("big", big | big2, big & big2, big &~ big2, ~big, card(~big))
	fmt.println("big", big < big2, B256{.V200} <= big, B256{.V64} <= big, big >= B256{.V128, .V0}, big > big, big == big2, big != big2)
	fmt.println("big", transmute([4]u64)big2, g_var, card(g_var), .V255 in g_var)

	h := Holder{1, big, 2}
	h2 := h
	fmt.println("holder", h == h2, h.set == big)
	h2.set += {.V3}
	fmt.println("holder", h == h2, h2.set, pick(big, big2, false))

	rr := R40{0, 63, 64, 199, 299}
	n := 150
	rr2 := R40{n, 64, 298}
	fmt.println("range", card(rr), 299 in rr, n in rr, n in rr2, 298 not_in rr, rr & rr2, rr | rr2, card(~rr))
	m := 140
	rl := RL{10, 73, m}
	rl2 := RL{m, 149}
	fmt.println("lower", rl, card(rl), m in rl, 149 in rl, 10 not_in rl2, rl & rl2, rl | rl2, ~rl2 & rl, card(~rl), rl2 < rl, rl2 <= rl | rl2, transmute([3]u64)rl)
	fmt.println("range", rr <= rr | rr2, rr2 < rr | rr2, rr > rr2, transmute([5]u64)(rr2 | rr))
}
