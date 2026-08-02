package Template

import "core:fmt"
import sdl "vendor:sdl3"

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintfln("%v memmory leaks", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintfln("%v leaked bytes in %v", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintfln("%v invalid frees", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintfln("invalid free in %v", entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	hasMetadata: bool : sdl.SetAppMetadata(WINDOW_NAME, APP_VERSION, APP_DISTRIBUITOR)
	hasSDL: bool : sdl.Init({.VIDEO})
	defer sdl.Quit()

	if !hasMetadata || !hasSDL {
		fmt.eprintln("Failed to Init")
		return
	}

	driver: cstring = pickDriverForOS()
	window, renderer, _ := createWindowAndRenderer(driver)

	defer sdl.DestroyWindow(window)
	defer sdl.DestroyRenderer(renderer)

	hasVSync: bool = sdl.SetRenderVSync(renderer, 1)
	if !hasVSync do fmt.eprintln("Failed to enable V-Sync")

	displayID := sdl.GetDisplayForWindow(window)
	displayMode := sdl.GetCurrentDisplayMode(displayID)
	refreshRate: f32 = displayMode.refresh_rate
	vsyncEnabled: bool = true
	fpsCapEnabled: bool = true
	fpsTarget: u64 = 30
	sDepth: int = 5

	fps: f64
	color: sdl.FColor
	colorPaused: bool

	drivers, _ := getDriverNames()
	defer delete(drivers)

	mainLoop: for {
		frameStart: u64 = sdl.GetTicksNS()

		for event: sdl.Event; sdl.PollEvent(&event); do eventHandler(event)

		if !colorPaused {
			color.r = f32(0.500 + 0.500 * sdl.sin(now))
			color.g = f32(0.500 + 0.500 * sdl.sin(now + math.PI * 2 / 3))
			color.b = f32(0.500 + 0.500 * sdl.sin(now + math.PI * 4 / 3))
			color.a = sdl.ALPHA_OPAQUE_FLOAT

		}; colorChanger(f64(frameStart) / 1_000_000_000.000)

		sdl.SetRenderDrawColorFloat(renderer, color.r, color.g, color.b, color.a)
		sdl.RenderClear(renderer)

		sdl.SetRenderDrawColorFloat(renderer, 1 - color.r, 1 - color.g, 1 - color.b, 255)
		triangle: Triangle = {{366, 20}, {112, 460}, {620, 460}}
		sierpinksi(renderer, triangle, sDepth)

		for evt: sdl.Event; sdl.PollEvent(&evt); {
			#partial switch evt.type {
			case .QUIT:
				break mainLoop
			case .WINDOW_CLOSE_REQUESTED:
				break mainLoop
			case .KEY_UP:
				switch evt.key.key {
				case sdl.K_0 ..= sdl.K_9:
					sDepth = int(evt.key.key - 0x00000030)
				case sdl.K_P:
					colorPaused = !colorPaused
				case sdl.K_ESCAPE:
					break mainLoop
				case sdl.K_Q:
					break mainLoop
				case sdl.K_V:
					vsyncEnabled = !vsyncEnabled
					sdl.SetRenderVSync(renderer, vsyncEnabled ? 1 : sdl.RENDERER_VSYNC_DISABLED)
				case sdl.K_F:
					fpsCapEnabled = !fpsCapEnabled
				}
			case .MOUSE_BUTTON_UP:
				switch evt.button.button {
				case sdl.BUTTON_LEFT:
					colorPaused = !colorPaused
				}
			}
		}
		free_all(context.temp_allocator)

		sdl.RenderPresent(renderer)

		frameEnd: u64 = sdl.GetTicksNS()

		fpnsTarget: u64 = 1_000_000_000 / fpsTarget
		if fpsCapEnabled && (frameEnd - frameStart) < fpnsTarget {
			sdl.DelayPrecise(fpnsTarget - (frameEnd - frameStart))
			frameEnd = sdl.GetTicksNS()
		}
		fps = 1_000_000_000.000 / f64(frameEnd - frameStart)

	}
}
