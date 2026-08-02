package Template

import sdl "vendor:sdl3"

Triangle :: struct {
	v0, v1, v2: sdl.FPoint,
}

sierpinksi :: proc(renderer: ^sdl.Renderer, triangle: Triangle, depth: int) {
	if depth == 0 {
		triangleRaw: [4]sdl.FPoint = {triangle.v0, triangle.v1, triangle.v2, triangle.v0}
		sdl.RenderLines(renderer, raw_data(triangleRaw[:]), 4)
		return
	}
	sierpinksi(
		renderer,
		{triangle.v0, (triangle.v0 + triangle.v1) / 2, (triangle.v0 + triangle.v2) / 2},
		depth - 1,
	)
	sierpinksi(
		renderer,
		{triangle.v1, (triangle.v1 + triangle.v2) / 2, (triangle.v0 + triangle.v1) / 2},
		depth - 1,
	)
	sierpinksi(
		renderer,
		{triangle.v2, (triangle.v0 + triangle.v2) / 2, (triangle.v1 + triangle.v2) / 2},
		depth - 1,
	)
}

colorChanger :: proc(now: f64) {
	color.r = f32(0.500 + 0.500 * sdl.sin(now))
	color.g = f32(0.500 + 0.500 * sdl.sin(now + math.PI * 2 / 3))
	color.b = f32(0.500 + 0.500 * sdl.sin(now + math.PI * 4 / 3))
	color.a = sdl.ALPHA_OPAQUE_FLOAT
}
