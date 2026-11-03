package main

import "base:intrinsics"
import "base:runtime"
import "core:c"
import "core:fmt"

Point :: struct {
	x, y: i32,
	name: string,
}

Flags :: bit_set[0..<8; u8]

Kind :: enum u8 {
	End,
	I8,
	U16,
	I32,
	I64,
	F32,
	F64,
	Bool,
	Flags,
	Point_Ptr,
	Cstring,
}

read_one :: proc "c" (list: ^c.va_list, kind: Kind) -> (s: string, ok: bool) {
	context = runtime.default_context()
	switch kind {
	case .End:
		return "", false
	case .I8:
		s = fmt.tprint("i8", intrinsics.c_va_arg(list, i8))
	case .U16:
		s = fmt.tprint("u16", intrinsics.c_va_arg(list, u16))
	case .I32:
		s = fmt.tprint("i32", intrinsics.c_va_arg(list, i32))
	case .I64:
		s = fmt.tprint("i64", intrinsics.c_va_arg(list, i64))
	case .F32:
		s = fmt.tprint("f32", intrinsics.c_va_arg(list, f32))
	case .F64:
		s = fmt.tprint("f64", intrinsics.c_va_arg(list, f64))
	case .Bool:
		s = fmt.tprint("bool", intrinsics.c_va_arg(list, bool))
	case .Flags:
		s = fmt.tprint("flags", intrinsics.c_va_arg(list, Flags))
	case .Point_Ptr:
		pp := intrinsics.c_va_arg(list, ^Point)
		s = fmt.tprint("point", pp.x, pp.y, pp.name)
		pp.x += 100
	case .Cstring:
		s = fmt.tprint("cstring", intrinsics.c_va_arg(list, cstring))
	}
	return s, true
}

describe :: proc "c" (out: ^[dynamic]string, kinds: [^]Kind, #c_vararg args: ..any) {
	context = runtime.default_context()
	list: c.va_list
	intrinsics.c_va_start(&list, args)
	defer intrinsics.c_va_end(&list)
	for i := 0; ; i += 1 {
		s, ok := read_one(&list, kinds[i])
		if !ok {
			break
		}
		append(out, s)
	}
}

sum_twice :: proc "c" (n: c.int, #c_vararg args: ..c.int) -> (first: c.int, second: c.int) {
	a, b: c.va_list
	intrinsics.c_va_start(&a, args)
	intrinsics.c_va_copy(&b, &a)
	for _ in 0..<n {
		first += intrinsics.c_va_arg(&a, c.int)
	}
	for _ in 0..<n {
		second += 2 * intrinsics.c_va_arg(&b, c.int)
	}
	intrinsics.c_va_end(&a)
	intrinsics.c_va_end(&b)
	return
}

count_args :: proc "c" (#c_vararg args: ..any) -> c.int {
	list: c.va_list
	intrinsics.c_va_start(&list, args)
	defer intrinsics.c_va_end(&list)
	n: c.int
	for intrinsics.c_va_arg(&list, c.int) != 0 {
		n += 1
	}
	return n
}

dump_layout :: proc "c" (words: ^[12]u32, #c_vararg args: ..any) {
	list: c.va_list
	intrinsics.c_va_start(&list, args)
	base := ([^]u32)((^rawptr)(&list)^)
	for i in 0..<12 {
		words[i] = base[i]
	}
	intrinsics.c_va_end(&list)
}

next_value :: proc(x: ^i64) -> i64 {
	x^ += 7
	return x^
}

print_all :: proc(out: ^[dynamic]string) {
	for s in out {
		fmt.println(s)
	}
	clear(out)
}

main :: proc() {
	out: [dynamic]string
	p := Point{3, -4, "first"}
	q := Point{10, 20, "second"}
	counter: i64 = 1

	kinds1 := []Kind{.I8, .U16, .I32, .I64, .F32, .F64, .Bool, .Flags, .Point_Ptr, .I8, .F32, .I64, .Point_Ptr, .Cstring, .End}
	describe(&out, raw_data(kinds1),
		i8(-7), u16(65000), i32(-123456), i64(-1) << 50, f32(1.25), 6.5, true, Flags{0, 3, 7},
		&p, i8(127), f32(-0.75), next_value(&counter), &q, cstring("hello"))
	print_all(&out)
	fmt.println("after", p.x, q.x, counter)

	kinds2 := []Kind{.F64, .I32, .F64, .I32, .F64, .I32, .F64, .I32, .F64, .I32, .F64, .I32, .Point_Ptr, .End}
	f := describe
	f(&out, raw_data(kinds2), 0.5, i32(1), 1.5, i32(2), 2.5, i32(3), 3.5, i32(4), 4.5, i32(5), 5.5, i32(6), &p)
	print_all(&out)
	fmt.println("after", p.x)

	kinds3 := []Kind{.End}
	describe(&out, raw_data(kinds3))
	fmt.println("empty", len(out))

	x, y := sum_twice(10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	fmt.println("sum", x, y)
	words: [12]u32
	dump_layout(&words, i8(-2), f32(0.5), i64(0x1122334455667788), u16(0xabcd), f64(-3), true, i32(-9))
	fmt.println("layout", words[0], words[2:7], words[8:])
	fmt.println("count", count_args(c.int(5), c.int(6), c.int(7), c.int(0)), count_args(c.int(0)))
}
