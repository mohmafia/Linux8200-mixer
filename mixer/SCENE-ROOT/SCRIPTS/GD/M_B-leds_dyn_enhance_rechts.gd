extends Control

# --- CONFIGURATIE (Protocol conform) ---
@export_group("Protocol Ankers")
@export var my_id: String = "Master_B"
@export var is_right_channel: bool = true
@export var my_type: String = "enhancer_meter"
@export var my_msg: String = "enh_level"
@export var error_prefix: String = "ERR-ENH-AUTO"

# --- VISUEEL (2x Groen, 1x Geel, 1x Rood) ---
@export_group("Visueel")
@export var color_green: Color = Color(0.0, 2.5, 0.0, 1.0)
@export var color_yellow: Color = Color(2.5, 2.5, 0.0, 1.0)
@export var color_red: Color = Color(3.0, 0.0, 0.0, 1.0)
@export var inactive_color: Color = Color(0.49, 0.02, 0.02, 1.0)

# --- SYSTEEM ---
var leds = []
var is_windows = OS.get_name() == "Windows"
var my_side_suffix = "R"
var update_interval: float = 0.015 # Zeer snel voor transiënten
var time_accumulator: float = 0.0

func _ready():
	my_side_suffix = "R" if is_right_channel else "L"
	error_prefix = "ERR-ENH-" + my_id + "-" + my_side_suffix
	
	_initialize_leds()
	
	if Engine.has_meta("MixManager"):
		var manager = Engine.get_meta("MixManager")
		if manager.has_signal("vu_update"):
			manager.vu_update.connect(_on_vu_data_received)

func _initialize_leds():
	leds.clear()
	for child in get_children():
		if child is CanvasItem:
			leds.append(child)
	
	# Sorteren op X (Links naar Rechts)
	# Index 0: -30 (G), 1: -20 (G), 2: -10 (Y), 3: 0 (R)
	leds.sort_custom(func(a, b): return a.position.x < b.position.x)

func _on_vu_data_received(incoming_id: String, incoming_type: String, incoming_msg: String, value: float):
	if incoming_id == my_id and incoming_type == my_type and incoming_msg == my_msg + "_" + my_side_suffix:
		_update_display(value)

func _update_display(val: float):
	var total = leds.size() # Moet 4 zijn
	var lit_count = int(val * total + 0.1)
	lit_count = clamp(lit_count, 0, total)
	
	for i in range(total):
		if i < lit_count:
			# Specifieke kleurverdeling per LED index
			match i:
				0, 1: leds[i].modulate = color_green
				2:    leds[i].modulate = color_yellow
				3:    leds[i].modulate = color_red
		else:
			leds[i].modulate = inactive_color

# --- HIGH-SPEED SIMULATIE ---
func _process(delta):
	if is_windows and not Engine.has_meta("MixManager"):
		time_accumulator += delta
		if time_accumulator >= update_interval:
			# Enhancer reageert vaak op pieken, dus we maken de simulatie "spiky"
			var t = Time.get_ticks_msec() / 80.0
			var noise = randf_range(0.0, 0.4)
			var mock_val = clamp((sin(t) + 1.0) * 0.5 + noise - 0.2, 0.0, 1.0)
			
			_update_display(mock_val)
			time_accumulator = 0.0
