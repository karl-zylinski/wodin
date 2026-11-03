package main

import "core:fmt"

SNAN32   : f32 : 0h7f800001
SNAN32_N : f32 : 0hffa00005
QNAN32   : f32 : 0h7fc12345
SNAN16   : f16 : 0h7c01
QNAN16   : f16 : 0hfe11
SNAN64   : f64 : 0h7ff0000000000001

global32 := [4]f32{SNAN32, SNAN32_N, QNAN32, 1.5}
global16 := [3]f16{SNAN16, QNAN16, 2}
global64 := [2]f64{SNAN64, -3}

Pair :: struct {
	a: f32,
	b: f16,
}

global_pair := Pair{SNAN32, SNAN16}

@(optimization_mode="none")
id32 :: proc(x: f32) -> f32 { return x }
@(optimization_mode="none")
id16 :: proc(x: f16) -> f16 { return x }

main :: proc() {
	for x in global32 {
		fmt.printf("%08x ", transmute(u32)x)
	}
	fmt.println()
	for x in global16 {
		fmt.printf("%04x ", transmute(u16)x)
	}
	fmt.println()
	for x in global64 {
		fmt.printf("%016x ", transmute(u64)x)
	}
	fmt.println()
	fmt.printf("%08x %04x\n", transmute(u32)global_pair.a, transmute(u16)global_pair.b)

	a := SNAN32
	b := SNAN32_N
	c := SNAN16
	d := QNAN16
	fmt.printf("%08x %08x %04x %04x\n", transmute(u32)a, transmute(u32)b, transmute(u16)c, transmute(u16)d)
	fmt.printf("%08x %04x\n", transmute(u32)id32(SNAN32), transmute(u16)id16(SNAN16))

	local := [3]f32{SNAN32, QNAN32, 0}
	fmt.printf("%08x %08x\n", transmute(u32)local[0], transmute(u32)local[1])
	p := Pair{SNAN32_N, QNAN16}
	fmt.printf("%08x %04x\n", transmute(u32)p.a, transmute(u16)p.b)
}
