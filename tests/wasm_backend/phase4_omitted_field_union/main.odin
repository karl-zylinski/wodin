package main

import "core:fmt"

Apply :: struct {
	position:         [3]f64,
	roll, pitch, yaw: f64,
	flag:             bool,
}

APPLY_DEFAULT : Apply : { yaw = 26.5, pitch = -24 }

Value :: union { bool, f64, [3]f64 }

Info :: struct {
	name:          string,
	default_value: Value,
}

INFOS :: []Info{
	{ name = "yaw",      default_value = APPLY_DEFAULT.yaw },
	{ name = "roll",     default_value = APPLY_DEFAULT.roll },
	{ name = "position", default_value = APPLY_DEFAULT.position },
	{ name = "flag",     default_value = APPLY_DEFAULT.flag },
}

INFO_ROLL :: Info{ name = "roll", default_value = APPLY_DEFAULT.roll }

infos := INFOS
global_roll: Value = APPLY_DEFAULT.roll
global_pos: Value = APPLY_DEFAULT.position
global_info := INFO_ROLL

show :: proc(v: Value) {
	switch x in v {
	case bool:   fmt.println("bool", x)
	case f64:    fmt.println("f64", x)
	case [3]f64: fmt.println("[3]f64", x)
	case:        fmt.println("nil")
	}
}

main :: proc() {
	for info in infos {
		fmt.print(info.name, "")
		show(info.default_value)
	}
	for info in INFOS {
		fmt.print(info.name, "")
		show(info.default_value)
	}
	show(global_roll)
	show(global_pos)
	show(global_info.default_value)
	local_info := INFO_ROLL
	show(local_info.default_value)
	local_roll: Value = APPLY_DEFAULT.roll
	show(local_roll)
	local_flag: Value = APPLY_DEFAULT.flag
	show(local_flag)
	show(APPLY_DEFAULT.position)
	arr := [2]Value{APPLY_DEFAULT.roll, APPLY_DEFAULT.flag}
	show(arr[0])
	show(arr[1])
}
