package main

import "core:fmt"

advance :: proc(dst, src: ^[^]u8, n: int) {
	for i in 0..<n {
		dst[i] = src[i]
	}
	dst^ = dst[n:]
	src^ = src[n:]
}

sum_through :: proc(p: ^[^]i32, count: int) -> i32 {
	s := p[:count]
	total: i32
	for v in s {
		total += v
	}
	return total
}

main :: proc() {
	src_buf := [16]u8{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
	dst_buf: [16]u8
	src := raw_data(src_buf[:])
	dst := raw_data(dst_buf[:])
	advance(&dst, &src, 8)
	advance(&dst, &src, 4)
	fmt.println(dst_buf)
	fmt.println(src[0], src[3], dst[0])
	fmt.println(len(src[:4]), src[1:4])

	ints := [6]i32{10, 20, 30, 40, 50, 60}
	ip := raw_data(ints[:])
	fmt.println(sum_through(&ip, 6))
	ip = ip[2:]
	fmt.println(sum_through(&ip, 4))
	fmt.println((&ip)[1:3])
}
