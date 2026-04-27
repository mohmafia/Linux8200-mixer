# [cite: 2026-03-02] The Beast: Auto-Blink LED Controller
extends Sprite2D

@export var led_color: Color = Color.RED
@export var intensity_on: float = 2.5   # Iets feller voor de test
@export var intensity_off: float = 0.1
@export var blink_speed: float = 0.5    # Halve seconde aan, halve seconde uit

var is_active: bool = false
var is_blinking: bool = true            # We zetten dit op TRUE voor de test
var blink_timer: float = 0.0

# [cite: 2026-01-28] OS Check
var is_windows = OS.get_name() == "Windows"

func _ready():
	# [cite: 2026-02-27] Descriptions in English
	# We force the blink status to see if the simulation works
	set_status(true, true) 
	
	if is_windows:
		print("[SYS] LED %s: Visual Test Started" % name)

func _process(delta):
	# De 'motor' die de tijd telt
	if is_blinking:
		blink_timer += delta
		if blink_timer >= blink_speed:
			blink_timer = 0.0
			is_active = !is_active 
			_apply_visuals()

func set_status(active: bool, blink: bool = false):
	is_active = active
	is_blinking = blink
	_apply_visuals()

func _apply_visuals():
	# [cite: 2026-02-04] Error check
	if not is_inside_tree(): return 
	
	if is_active:
		self_modulate = led_color * intensity_on
	else:
		self_modulate = led_color * intensity_off

# Error reporting [cite: 2026-02-04]
func _report_error(code: String):
	if is_windows:
		printerr("[%s] LED sync failure on: %s" % [code, name])
