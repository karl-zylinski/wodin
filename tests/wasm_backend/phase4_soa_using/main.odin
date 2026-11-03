#+feature using-stmt
package main

import "core:fmt"

Particle :: struct {
	pos:   [2]f32,
	vel:   [2]f32,
	inner: struct {
		hp: int,
		tag: u8,
	},
}

Handle :: struct {
	id:      int,
	using p: #soa^#soa[4]Particle,
}

DynHandle :: struct {
	using p: #soa^#soa[dynamic]Particle,
	extra:   int,
}

step :: proc(using p: #soa^#soa[4]Particle) {
	pos += vel
	inner.hp -= 1
}

main :: proc() {
	ps: #soa[4]Particle
	for i in 0..<4 {
		ps[i] = {pos = {f32(i), 0}, vel = {1, f32(i)}, inner = {hp = 10*i, tag = u8(i)}}
	}

	h := Handle{id = 7, p = &ps[2]}
	fmt.println(h.id, h.pos, h.vel, h.inner.hp, h.inner.tag)
	h.pos.x = 99
	h.inner.hp += 5
	h.vel = {3, 4}
	fmt.println(ps[2])

	{
		using q := &ps[1]
		pos.y = 42
		inner.tag = 200
		fmt.println(pos, vel, inner)
	}
	fmt.println(ps[1])

	step(&ps[3])
	step(&ps[3])
	fmt.println(ps[3])

	hp := &h
	hp.inner.hp = -1
	fmt.println(hp.pos, ps.inner[2])

	total := 0
	for v in ps {
		using v
		total += inner.hp + int(inner.tag)
	}
	for &v in ps {
		using v
		inner.tag += 1
		pos.x *= 2
	}
	fmt.println(total, ps.inner, ps.pos)

	d := make(#soa[dynamic]Particle, 3)
	defer delete(d)
	d[1].inner.hp = 5
	dh := DynHandle{p = &d[1], extra = 1}
	dh.inner.hp *= 3
	dh.pos = {1, 2}
	fmt.println(d[1], dh.extra)
}
