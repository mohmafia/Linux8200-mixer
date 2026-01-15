extends Button


var normal_size := Vector2i(1736, 900)
var small_size := Vector2i(1182, 612)
var is_small := false

func _ready():
	
	text = "Make\nSmaller"

func _size_button_pressed():
	var win := get_window()
	

	if is_small:
		win.size = normal_size
		DisplayServer.window_set_size(Vector2i(normal_size))
		is_small = false
		text = "Make\nSmaller"
	else:
		win.size = small_size
		DisplayServer.window_set_size(Vector2i(small_size))
		is_small = true
		text = "Make\nBigger"
