extends Control

# --- CONFIGURATIE (Protocol conform) ---
@export_group("Protocol Ankers")
@export var my_id: String = "Master_C"
@export var is_right_channel: bool = true
@export var my_type: String = "expander_meter"
@export var my_msg: String = "exp_status"
@export var error_prefix: String = "ERR-EXP-NITRO"

# --- VISUEEL (3 LEDs: Groen, Geel, Rood) ---
@export_group("Visueel")
@export var color_green: Color = Color(0.0, 3.0, 0.0, 1.0)  # Extra glow
@export var color_yellow: Color = Color(3.0, 3.0, 0.0, 1.0)
@export var color_red: Color = Color(4.0, 0.0, 0.0, 1.0)    # Bijna laser-rood
@export var inactive_color: Color = Color(0.01, 0.01, 0.01, 1.0)

# --- SYSTEEM ---
var leds = []
var is_windows = OS.get_name() == "Windows"
var my_side_suffix = "R"
var rng = RandomNumberGenerator.new()

func _ready():
	my_side_suffix = "R" if is_right_channel else "L"
	error_prefix = "ERR-EXP-" + my_id + "-" + my_side_suffix
	rng.randomize()
	_initialize_leds()
	
	if Engine.has_meta("MixManager"):
		var manager = Engine.get_meta("MixManager")
		manager.vu_update.connect(_on_vu_data_received)

func _initialize_leds():
	leds.clear()
	for child in get_children():
		if child is CanvasItem: leds.append(child)
	# Sorteren op X: 0=Groen, 1=Geel, 2=Rood
	leds.sort_custom(func(a, b): return a.position.x < b.position.x)

func _on_vu_data_received(incoming_id: String, incoming_type: String, incoming_msg: String, value: float):
	# Directe check zonder extra variabelen voor maximale snelheid
	if incoming_id == my_id and incoming_type == my_type and incoming_msg == my_msg + "_" + my_side_suffix:
		_update_expander_display(value)

func _update_expander_display(val: float):
	if leds.size() < 3: return
	
	# We zetten alles eerst uit (super snel)
	leds[0].modulate = inactive_color
	leds[1].modulate = inactive_color
	leds[2].modulate = inactive_color

	# Overlapping logica met harde drempels
	if val < 0.25:
		leds[0].modulate = color_green
	elif val < 0.5:
		leds[0].modulate = color_green
		leds[1].modulate = color_yellow
	elif val < 0.75:
		leds[1].modulate = color_yellow
		leds[2].modulate = color_red
	else:
		leds[2].modulate = color_red

# --- ULTRA-FAST RANDOM SPRAAK SIMULATIE ---
func _process(_delta):
	if is_windows and not Engine.has_meta("MixManager"):
		# We simuleren nu op ELK frame (60fps of hoger)
		# De 'noise' is nu dominant voor dat nerveuze effect
		var fast_t = Time.get_ticks_usec() * 0.0001 # Microseconden voor extra resolutie
		var jitter = rng.randf_range(0.0, 1.0)
		
		# Mix van een snelle oscillerende waarde en pure chaos (noise)
		var mock_speech = lerp(jitter, (sin(fast_t) + 1.0) * 0.5, 0.3)
		
		_update_expander_display(mock_speech)
