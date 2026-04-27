extends Button

var normal_size := Vector2i(1736, 900)
var small_size := Vector2i(1182, 612)
var is_small := false

func _ready():
	text = "Make\nSmaller"

# De naam waar je signaal naar luistert
func _size_button_pressed():
	var win := get_window()
	
	if is_small:
		win.size = normal_size
		# Terug naar 100% schaal
		win.content_scale_factor = 1.0
		is_small = false
		text = "Make\nSmaller"
	else:
		win.size = small_size
		# Bereken de verhouding (bijv. 0.68) om alles binnen de Window node te schalen
		var scale_factor : float = float(small_size.x) / float(normal_size.x)
		win.content_scale_factor = scale_factor
		
		is_small = true
		text = "Make\nBigger"

	# Optioneel: Centreer het venster op het scherm
	var screen_rect = DisplayServer.screen_get_usable_rect(win.current_screen)
	win.position = Vector2i(
		screen_rect.position.x + (screen_rect.size.x - win.size.x) / 2,
		screen_rect.position.y + (screen_rect.size.y - win.size.y) / 2
	)
