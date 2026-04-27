extends Control

# --- CONFIGURATIE (Protocol conform) ---
@export_group("Protocol Ankers")
@export var my_id: String = "Master_A"      # Master_A, Master_B of Master_C
@export var is_right_channel: bool = true # Vink aan voor de rechter kolom
@export var my_type: String = "limiter_meter"
@export var my_msg: String = "limit_status"
@export var error_prefix: String = "ERR-LIM-AUTO"

# --- VISUEEL (Fading Rood) ---
@export_group("Visueel")
@export var active_red: Color = Color(3.5, 0.0, 0.0, 1.0)   # Volle gloed (HDR)
@export var inactive_color: Color = Color(0.05, 0.0, 0.0, 1.0) # Dim stand
@export var glow_speed: float = 10.0 # Hoe snel de LED reageert op veranderingen

# --- SYSTEEM ---
var led_sprite: CanvasItem
var is_windows = OS.get_name() == "Windows"
var my_side_suffix = "R"
var current_intensity: float = 0.0
var target_intensity: float = 0.0

func _ready():
	my_side_suffix = "R" if is_right_channel else "L"
	error_prefix = "ERR-LIM-" + my_id + "-" + my_side_suffix
	
	# We pakken de eerste Sprite/CanvasItem die we vinden
	for child in get_children():
		if child is CanvasItem:
			led_sprite = child
			break
	
	if is_windows:
		print("[%s] Limiter LED geladen met Medium-Speed Glow." % error_prefix)
	
	if Engine.has_meta("MixManager"):
		var manager = Engine.get_meta("MixManager")
		manager.vu_update.connect(_on_vu_data_received)

func _on_vu_data_received(incoming_id: String, incoming_type: String, incoming_msg: String, value: float):
	if incoming_id == my_id and incoming_type == my_type and incoming_msg == my_msg + "_" + my_side_suffix:
		# De inkomende waarde bepaalt hoe fel de LED moet gaan branden
		target_intensity = clamp(value, 0.0, 1.0)

func _process(delta):
	# SMOOTH FADING LOGICA:
	# Dit zorgt ervoor dat de LED vloeiend van dim naar vol gaat
	current_intensity = lerp(current_intensity, target_intensity, delta * glow_speed)
	
	if led_sprite:
		led_sprite.modulate = inactive_color.lerp(active_red, current_intensity)

	# WINDOWS SIMULATIE (Medium Speed oplichten)
	if is_windows and not Engine.has_meta("MixManager"):
		var t = Time.get_ticks_msec() / 1000.0
		# Een tragere sinus die af en toe boven de 0.7 "clipt"
		var mock_limit = clamp(sin(t * 3.0) * 2.0 - 1.2, 0.0, 1.0)
		target_intensity = mock_limit
