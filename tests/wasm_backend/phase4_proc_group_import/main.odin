package main

import "core:fmt"
import "group"

call_twice :: proc(f: proc()) {
	f()
	f()
}

apply :: proc(f: proc(int) -> int, x: int) -> int {
	return f(x)
}

main :: proc() {
	call_twice(group.proc_group)
	fmt.println(group.counter)
	fmt.println(apply(group.int_group, 20))
	f: proc() = group.proc_group
	f()
	g := apply
	fmt.println(g(group.int_group, 1), group.counter)
}
