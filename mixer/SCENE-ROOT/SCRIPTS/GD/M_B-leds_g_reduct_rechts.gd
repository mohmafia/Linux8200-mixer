extends Control

# --- CONFIGURATIE (Inspector) ---
@export_group("Protocol Ankers")
@export var my_id: String = "Master_B"      # Master_A, Master_B of Master_C
@export var is_right_channel: bool = true # Vink aan voor de rechter kolom
@export var my_type: String = "gr_meter"
@export var my_msg: String = "gr_status"

@export_group("Visueel")
@export var active_color: Color = Color(2.5, 0.0, 0.0, 1.0) # Extra fel rood (HDR glow)
@export var inactive_color: Color = Color(0.5, 0.0, 0.0, 1.0) # Bijna zwart rood

@export_group("Foutopsporing")
@export var error_prefix: String = "ERR-GR-AUTO"

# --- SYSTEEM ---
var leds = []
var is_windows = OS.get_name() == "Windows"
var my_side_suffix = "R"
# Update interval naar 0.02 (50 frames per seconde) voor super snelle respons
var update_interval: float = 0.02 
var time_accumulator: float = 0.0

func _ready():
	my_side_suffix = "R" if is_right_channel else "L"
	error_prefix = "ERR-GR-" + my_id + "-" + my_side_suffix
	
	_initialize_leds()
	
	if Engine.has_meta("MixManager"):
		var manager = Engine.get_meta("MixManager")
		if manager.has_signal("vu_update"):
			manager.vu_update.connect(_on_vu_data_received)
	
	if is_windows:
		print("[%s] High-Speed GR Meter geladen." % error_prefix)

func _initialize_leds():
	leds.clear()
	for child in get_children():
		if child is CanvasItem:
			leds.append(child)
	
	# Sorteren van RECHTS naar LINKS (0dB naar -30dB)
	leds.sort_custom(func(a, b): return a.position.x > b.position.x)

func _on_vu_data_received(incoming_id: String, incoming_type: String, incoming_msg: String, value: float):
	if incoming_id == my_id and incoming_type == "gr_meter" and incoming_msg == "gr_" + my_side_suffix:
		_update_display(value)

func _update_display(gr_val: float):
	# AUTOCOM LOGICA: 0.0 = Alles AAN, 1.0 = Alles UIT
	var total = leds.size()
	var turn_off_count = int(gr_val * total)
	var turn_on_count = total - turn_off_count
	
	for i in range(total):
		if i < turn_on_count:
			leds[i].modulate = active_color
		else:
			leds[i].modulate = inactive_color

# --- HIGH-SPEED WINDOWS SIMULATIE ---
func _process(delta):
	if is_windows and not Engine.has_meta("MixManager"):
		time_accumulator += delta
		if time_accumulator >= update_interval:
			# De vermenigvuldiger (bijv. 500.0 ipv 250.0) maakt de beweging 2x sneller
			var t = Time.get_ticks_msec() / 125.0 
			var offset = 1.5 if is_right_channel else 0.0
			
			# Simulatie van een agressieve compressor (snelle attack/release)
			var mock_gr = clamp(sin(t + offset) * 2.0 - 0.5, 0.0, 1.0)
			
			_update_display(mock_gr)
			time_accumulator = 0.0
