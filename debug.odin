package Template

advanceRow :: proc(row: ^f32, height: f32) -> f32 {
	row^ += height
	return row^
}

CONTROLS: [][]cstring : {
	{"Quit", "Q", "ESC"},
	{"Pause Color", "P", "LMB"},
	{"Toggle V-Sync", "V", ""},
	{"Toggle FPS Cap", "F", ""},
	{"Triangle Depth", "0", "to 9"},
}
