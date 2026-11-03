package main

import "core:fmt"

end_scope :: proc(name: string, $T: typeid, values: ..T) {
	fmt.println("end", name, typeid_of(T), len(values))
}

@(deferred_in=end_scope)
begin_scope :: proc(name: string, $T: typeid, values: ..T) {
	fmt.println("begin", name, typeid_of(T), len(values), values)
}

end_sum :: proc($N: int, label: string, xs: ..f64) {
	fmt.println("end_sum", N, label, len(xs))
}

@(deferred_in=end_sum)
begin_sum :: proc($N: int, label: string, xs: ..f64) -> int {
	fmt.println("begin_sum", N, label, len(xs))
	return N
}

track_end :: proc(name: ^string, x: ^int, rest: ^[]int) {
	fmt.println("track_end", name^, x^)
}

@(deferred_in_by_ptr=track_end)
track :: proc($N: int, name: string, x: int, rest: ..int) {
	fmt.println("track", N, name, x, len(rest))
}

track_t_end :: proc(a: ^int, b: ^f32, rest: ^[]f32) {
	fmt.println("track_t_end", a^, b^)
}

@(deferred_in_by_ptr=track_t_end)
track_t :: proc(a: int, $T: typeid, b: T, rest: ..T) {
	fmt.println("track_t", a, b, len(rest))
}

out_close :: proc(a: int, b: f32) {
	fmt.println("out_close", a, b)
}

@(deferred_out=out_close)
open_values :: proc(x: $T, rest: ..T) -> (int, f32) {
	return len(rest), f32(x)
}

main :: proc() {
	{
		begin_scope("ints", int, 1, 2, 3)
		fmt.println("body ints")
	}
	{
		begin_scope("none", f64)
		fmt.println("body none")
	}
	{
		begin_sum(10, "f", 1.5, 2.5, 3.0)
		begin_sum(20, "i", 4, 5)
		begin_sum(30, "e")
		fmt.println("body sums")
	}
	{
		x := 5
		name := "tracked"
		track(3, name, x, 1, 2)
		x = 9
		name = "renamed"
		fmt.println("body track", x)
	}
	{
		a := 1
		b: f32 = 2.5
		track_t(a, f32, b, 1, 2, 3)
		a = 11
		b = 12.5
		fmt.println("body track_t")
	}
	{
		open_values(7, 8, 9)
		fmt.println("body out")
	}
}
