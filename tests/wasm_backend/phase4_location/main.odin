package main

import "core:fmt"

// `#location` as a global initializer: there is no procedure to name
G := #location(main)
H := #location()

main :: proc() {
	x := #location()
	fmt.println(x.procedure, x.line, x.column, x.file_path != "")
	fmt.println(G.procedure == "", G.line, G.column)
	fmt.println(H.procedure == "", H.line, H.column)
	// #location(x): where x was declared, in the procedure that declared it
	y := #location(x)
	fmt.println(y.procedure, y.line, y.column)
	helper(3)
	fmt.println(#location(G).line, #location(G).procedure == "")
	branch_locations()
}

helper :: proc(n: int) {
	z := #location(n)
	fmt.println(z.procedure, z.line, z.column, #location().line)
	nested :: proc() {
		fmt.println(#location().procedure, #location().line)
	}
	nested()
}

// `#branch_location` in a defer: the return that ran the deferred statement
returns_at :: proc(early: bool, got: ^i32) -> (expected: i32) {
	defer got^ = #branch_location.line
	if early {
		return #line
	}
	return #line
}

branch_locations :: proc() {
	got: i32
	expected := returns_at(true, &got)
	fmt.println(got == expected, got)
	expected = returns_at(false, &got)
	fmt.println(got == expected, got)
	for i in 0..<3 {
		defer fmt.println("loop exit at line", #branch_location.line, #branch_location.procedure)
		if i == 1 {
			break
		}
	}
}

