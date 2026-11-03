package group

counter: int

empty_proc :: proc() { counter += 1 }
int_proc :: proc(x: int) -> int { return x*2 + counter }

proc_group :: proc{empty_proc}
int_group :: proc{int_proc}
