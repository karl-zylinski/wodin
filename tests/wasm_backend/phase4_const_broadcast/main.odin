package main

import "core:fmt"

Item :: struct {
	stage: int,
	size:  int,
}

U :: union {
	Item,
}

Desc :: struct {
	items: [4][8]Item,
}

Target :: union {
	[]Item,
	[2]u32,
}

TARGET_SIZE :: 8192

nested_global: [4][8]Item = Item{stage = 1, size = 64}
union_global: [8]U = U(Item{stage = 2, size = 65})
deep_global: [2][3][4]int = 7

take_target :: proc(target: Target, count: u32) -> Target {
	return target
}

show_target :: proc(t: Target) {
	switch v in t {
	case []Item: fmt.println("slice", len(v))
	case [2]u32: fmt.println("array", v)
	case:        fmt.println("nil")
	}
}

main :: proc() {
	fmt.println(nested_global[0][0], nested_global[3][7])
	same := true
	for row in nested_global {
		for item in row {
			if item != (Item{1, 64}) {
				same = false
			}
		}
	}
	fmt.println(same)

	nested_local: [4][8]Item = Item{stage = 1, size = 64}
	fmt.println(nested_local == nested_global)

	d := Desc{items = Item{stage = 1, size = 64}}
	fmt.println(d.items == nested_global)

	positional: [4][8]Item = Item{1, 64}
	fmt.println(positional == nested_global)

	deep: [2][3][4]int = 7
	fmt.println(deep)
	fmt.println(deep_global)
	deep_f: [2][2]f32 = 1.5
	fmt.println(deep_f)

	for u in union_global {
		item, ok := u.(Item)
		fmt.println(ok, item)
	}
	union_local: [8]U = U(Item{stage = 2, size = 65})
	fmt.println(union_local == union_global)

	assigned: Target = TARGET_SIZE
	show_target(assigned)
	show_target(take_target(target = TARGET_SIZE, count = 3))
	show_target(take_target(TARGET_SIZE*2, 3))
	elems := [2]Target{TARGET_SIZE, {}}
	show_target(elems[0])
	show_target(elems[1])

	indexed: [4]Item = {0..<2 = Item{stage = 3, size = 66}, 3 = Item{stage = 4, size = 67}}
	fmt.println(indexed)
	plain: [3]Item = {Item{stage = 5, size = 68}, {}, {}}
	fmt.println(plain)
}
