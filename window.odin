package Template

import "core:fmt"
import sdl "vendor:sdl3"

@(require_results)
getDriverNames :: proc() -> (drivers: []cstring, count: i32) {
	count = sdl.GetNumRenderDrivers()
	drivers = make([]cstring, count)
	for driver in 0 ..< count do drivers[driver] = sdl.GetRenderDriver(driver)
	return
}

setDriverByPriority :: proc(priorityList: []cstring) -> (driver: cstring) {
	driverList, _ := getDriverNames()
	defer delete(driverList)
	for priority in priorityList {
		for driver in driverList {
			if driver == priority do return priority
		}
	}
	return
}

pickDriverForOS :: proc() -> cstring {
	when ODIN_OS == .Linux {
		return setDriverByPriority({"vulkan", "gpu", "opengl", "software"})
	} else when ODIN_OS == .Windows {
		return setDriverByPriority({"direct3d12", "direct3d11", "direct3d", "gpu", "opengl", "software"})
	} else when ODIN_OS == .Darwin {
		return setDriverByPriority({"metal", "gpu", "opengl", "software"})
	} else {
		return setDriverByPriority({"gpu", "opengl", "software"})
	}
}

createWindowAndRenderer :: proc(driver: cstring) -> (window: ^sdl.Window, renderer: ^sdl.Renderer, ok: bool) {
	window = sdl.CreateWindow(WINDOW_NAME, WINDOW_WIDTH, WINDOW_HEIGHT, {.RESIZABLE})
	if window == nil {
		fmt.eprintln("Failed to create window:", sdl.GetError())
		return nil, nil, false
	}

	renderer = sdl.CreateRenderer(window, driver)
	if renderer == nil {
		fmt.eprintln("Failed to create renderer:", sdl.GetError())
		return window, nil, false
	}

	sdl.SetRenderLogicalPresentation(renderer, WINDOW_WIDTH, WINDOW_HEIGHT, .LETTERBOX)
	return window, renderer, true
}
