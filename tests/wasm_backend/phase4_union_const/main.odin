package main

import "core:fmt"

// Constants of union type, including a variant that is itself a union: the
// value's variant is a variant of a variant, and the constant has to be
// written as the outer variant that holds it, inner tag and all.

Inner_Left :: enum { a, b }
Inner_Right :: enum { c, d }
Inner :: union { Inner_Left, Inner_Right }
Outer :: union { Inner, int }
Atom :: struct { token: Outer }

UI :: union { int, bool }

A :: union { B, bool }
B :: union { C, int }
C :: struct {}

NAMED_INNER :: Inner(Inner_Left.a)
ATOMS :: [?]Atom{{token = Inner(Inner_Left.a)}, {token = 7}, {token = Inner(Inner_Right.d)}}
OUTERS :: [2]Outer{0 = Inner(Inner_Left.b), 1 = 9}

G_OUTER := Outer(Inner(Inner_Left.a))
G_UI: Maybe(UI) = 1
G_A: A = B(C{})

describe_outer :: proc(o: Outer) {
	switch v in o {
	case Inner:
		switch w in v {
		case Inner_Left:  fmt.println("Inner_Left", w)
		case Inner_Right: fmt.println("Inner_Right", w)
		case:             fmt.println("Inner nil")
		}
	case int: fmt.println("int", v)
	case:     fmt.println("nil")
	}
}

main :: proc() {
	describe_outer(NAMED_INNER)
	for atom in ATOMS {
		describe_outer(atom.token)
	}
	describe_outer(OUTERS[0])
	describe_outer(OUTERS[1])
	describe_outer(G_OUTER)

	foo: Maybe(UI) : 1
	bar: union{UI} : 2
	baz: UI : 3
	qux: struct{ui: UI} : {4}
	fmt.println(foo, bar, baz, qux.ui, G_UI)
	foo_v := foo
	if ui, ok := foo_v.?; ok {
		if v, ok2 := ui.(int); ok2 { fmt.println("foo int", v) }
	}

	fmt.println(G_A == A(B(C{})), G_A != nil)
	X :: struct{x: A}{B(C{})}
	fmt.println(X.x == A(B(C{})))
	Av: A : Bv
	Bv: B : Cv
	Cv: C : {}
	fmt.println(Av == A(B(C{})))
	C0: [2][2]A : B(C{})
	fmt.println(C0[1][0] == A(B(C{})), C0[0][1] != nil)

	E :: enum { y }
	Y: [E]A : {.y = true}
	fmt.println(Y[.y] == A(true))
}
