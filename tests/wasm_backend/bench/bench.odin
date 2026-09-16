package bench

import "core:fmt"
import "core:time"
import "core:math"
import "core:math/linalg"
import "core:slice"
import "core:strings"

Vec2 :: [2]f32

Bunny :: struct {
	pos:   Vec2,
	vel:   Vec2,
	color: [4]u8,
	rot:   f32,
}

Entity :: struct {
	pos:    linalg.Vector3f32,
	vel:    linalg.Vector3f32,
	scale:  f32,
	health: int,
	alive:  bool,
	name:   string,
}

sink: int

bench_bunnies :: proc(n: int, iters: int) {
	bunnies := make([]Bunny, n)
	defer delete(bunnies)
	for &b, i in bunnies {
		b.pos = {f32(i % 640), f32(i % 480)}
		b.vel = {f32(i%7) - 3, f32(i%5) - 2}
		b.color = {u8(i), u8(i*3), u8(i*7), 255}
	}
	for _ in 0..<iters {
		for &b in bunnies {
			b.pos += b.vel
			if b.pos.x < 0 || b.pos.x > 640 { b.vel.x = -b.vel.x }
			if b.pos.y < 0 || b.pos.y > 480 { b.vel.y = -b.vel.y }
			b.rot += 0.01
		}
	}
	sink += int(bunnies[n/2].pos.x)
}

bench_entities :: proc(n: int, iters: int) {
	ents := make([]Entity, n)
	defer delete(ents)
	for &e, i in ents {
		e.pos = {f32(i), f32(i*2), f32(i*3)}
		e.vel = {1, 0.5, 0.25}
		e.scale = 1
		e.health = 100
		e.alive = true
		e.name = "entity"
	}
	dt: f32 = 1.0/60
	for _ in 0..<iters {
		for &e in ents {
			if !e.alive { continue }
			e.pos += e.vel * dt
			e.scale = math.sqrt(abs(e.pos.x)) * 0.5 + 1
			if linalg.length(e.pos) > 10000 { e.health -= 1 }
			if e.health <= 0 { e.alive = false }
		}
	}
	sink += int(ents[n/2].pos.y)
}

bench_matrix :: proc(iters: int) {
	m := linalg.MATRIX4F32_IDENTITY
	c: f32 = 0.99995; sn: f32 = 0.0099998
	r := linalg.Matrix4f32{c, -sn, 0, 0, sn, c, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
	t := linalg.matrix4_translate_f32({1, 2, 3})
	for _ in 0..<iters {
		m = r * m * t
		m[3, 3] = 1
	}
	sink += int(m[0, 0])
}

bench_map :: proc(n: int) {
	m := make(map[int]int)
	defer delete(m)
	for i in 0..<n {
		m[i*7919 % (n*2)] = i
	}
	s := 0
	for i in 0..<n*2 {
		if v, ok := m[i]; ok { s += v }
	}
	sink += s
}

bench_string_map :: proc(n: int) {
	m := make(map[string]int)
	defer delete(m)
	keys := make([]string, 1000)
	defer delete(keys)
	for &k, i in keys {
		k = fmt.aprintf("key_%d", i)
	}
	defer for k in keys { delete(k) }
	for i in 0..<n {
		m[keys[i % 1000]] += 1
	}
	sink += m["key_5"]
}

bench_sort :: proc(n: int) {
	arr := make([]i32, n)
	defer delete(arr)
	x: u32 = 12345
	for &v in arr {
		x = x * 1664525 + 1013904223
		v = i32(x >> 8)
	}
	slice.sort(arr)
	sink += int(arr[n/2])
}

bench_sort_struct :: proc(n: int) {
	arr := make([]Bunny, n)
	defer delete(arr)
	x: u32 = 12345
	for &v in arr {
		x = x * 1664525 + 1013904223
		v.pos.x = f32(x >> 8)
	}
	slice.sort_by(arr, proc(a, b: Bunny) -> bool { return a.pos.x < b.pos.x })
	sink += int(arr[n/2].pos.x)
}

fib :: proc(n: int) -> int {
	if n < 2 { return n }
	return fib(n-1) + fib(n-2)
}

bench_fib :: proc(n: int) {
	sink += fib(n)
}

bench_fmt :: proc(n: int) {
	b := strings.builder_make()
	defer strings.builder_destroy(&b)
	for i in 0..<n {
		strings.builder_reset(&b)
		fmt.sbprintf(&b, "frame %d: pos=%v hp=%d", i, Vec2{f32(i), 2}, i*3)
	}
	sink += strings.builder_len(b)
}

bench_dyn_array :: proc(n: int, iters: int) {
	arr: [dynamic]Entity
	defer delete(arr)
	for _ in 0..<iters {
		clear(&arr)
		for i in 0..<n {
			append(&arr, Entity{pos = {f32(i), 0, 0}, health = i})
		}
		s := 0
		for e in arr { s += e.health }
		sink += s
	}
}

bench_pixels :: proc(w, h: int, iters: int) {
	pix := make([][4]u8, w*h)
	defer delete(pix)
	for _ in 0..<iters {
		for y in 0..<h {
			for x in 0..<w {
				p := &pix[y*w + x]
				p^ = {u8(x), u8(y), u8(x ~ y), 255}
			}
		}
	}
	sink += int(pix[w*h/2][0])
}

bench_particles_soa :: proc(n: int, iters: int) {
	Particles :: struct {
		x, y, vx, vy: []f32,
		life: []f32,
	}
	p := Particles{
		x = make([]f32, n), y = make([]f32, n), vx = make([]f32, n), vy = make([]f32, n), life = make([]f32, n),
	}
	defer { delete(p.x); delete(p.y); delete(p.vx); delete(p.vy); delete(p.life) }
	for i in 0..<n {
		p.vx[i] = f32(i % 13) - 6
		p.vy[i] = f32(i % 11) - 5
		p.life[i] = 100
	}
	for _ in 0..<iters {
		for i in 0..<n {
			p.x[i] += p.vx[i]
			p.y[i] += p.vy[i]
			p.vy[i] += 0.1
			p.life[i] -= 1
			if p.life[i] <= 0 {
				p.x[i] = 0
				p.y[i] = 0
				p.life[i] = 100
			}
		}
	}
	sink += int(p.x[n/2])
}

run :: proc(name: string, f: proc()) {
	start := time.tick_now()
	f()
	d := time.tick_since(start)
	fmt.printf("%-16s %8.2f ms\n", name, time.duration_milliseconds(d))
}

main :: proc() {
	run("bunnies",      proc() { bench_bunnies(100_000, 100) })
	run("entities",     proc() { bench_entities(50_000, 100) })
	run("matrix",       proc() { bench_matrix(2_000_000) })
	run("map",          proc() { bench_map(500_000) })
	run("string_map",   proc() { bench_string_map(2_000_000) })
	run("sort",         proc() { bench_sort(2_000_000) })
	run("sort_struct",  proc() { bench_sort_struct(300_000) })
	run("fib",          proc() { bench_fib(32) })
	run("fmt",          proc() { bench_fmt(100_000) })
	run("dyn_array",    proc() { bench_dyn_array(100_000, 30) })
	run("pixels",       proc() { bench_pixels(1024, 1024, 20) })
	run("particles_soa",proc() { bench_particles_soa(200_000, 100) })
	fmt.println("sink", sink)
}
