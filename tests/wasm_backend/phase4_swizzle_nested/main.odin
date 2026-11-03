package main

import "core:fmt"

V :: struct {
	p: [4]f32,
}

main :: proc() {
	c := [3]int{0, 1, 2}
	fmt.println(c.zyx.x, c.zyx.yx, c.zyx.zzy.yx, c.zyx[0], c.zyx.yx[1])
	c.zyx.x = 7
	fmt.println(c)
	c.zyx.xy = {8, 9}
	fmt.println(c)
	c.zyx.zx.x = 11
	fmt.println(c)
	c.zyx.y += 5
	fmt.println(c)

	pc := &c
	fmt.println(pc.zy.y, pc.zyx.yz)
	pc.yx.y = 20
	fmt.println(c)

	b := [6]int{0, 1, 2, 3, 4, 5}
	fmt.println(swizzle(b, 5, 4, 3).y, swizzle(b, 5, 4, 3).zx, swizzle(b, 5, 4, 3, 2, 1)[1])
	swizzle(b, 5, 4, 3).x = 50
	swizzle(b, 2, 1, 0).yx = {60, 70}
	fmt.println(b)
	fmt.println(swizzle(c, 2, 0).y, swizzle(b, 5, 4, 3).zy.x)

	v := V{{1, 2, 3, 4}}
	v.p.wzyx.x = 40
	v.p.xyz.zyx.z += 0.5
	fmt.println(v, v.p.wzyx.yx.x)

	s := #soa[2][3]int{}
	s[1] = {0, 1, 2}
	fmt.println(s[1].zyx[0], s[1].zyx.x, s[1].zyx.yx)
	s[1].zyx.x = 7
	fmt.println(s[1])
	s[1].zyx.xy = {8, 9}
	fmt.println(s[1])
	i := 0
	s[i].yx.y = 33
	s[i].zyx.zy.x += 4
	fmt.println(s[0], s[1], s[i].xz, swizzle(s[1], 2, 0))
	swizzle(s[1], 2, 0).y = 99
	fmt.println(s[1])

	d := make(#soa[dynamic][4]f32)
	defer delete(d)
	append(&d, [4]f32{1, 2, 3, 4})
	d[0].wzyx.zy.x = 100
	fmt.println(d[0], d[0].wzyx.x)
}
