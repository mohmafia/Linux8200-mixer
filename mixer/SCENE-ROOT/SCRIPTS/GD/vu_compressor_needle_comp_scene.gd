extends Sprite2D

# --- CONFIGURATIE (Protocol conform) ---
@export_group("Protocol Ankers")
@export var my_id: String = "MIX-GR"
@export var my_type: String = "gr_meter"
@export var my_msg: String = "gr_level"
@export var error_prefix: String = "ERR-VU-GR"

# --- NAALD INSTELLINGEN ---
@export_group("Naald Bereik")
@export var zero_reduction_angle: float = 45.0  # Naald staat RECHTS (0 dB)
@export var max_reduction_angle: float = -45.0 # Naald slaat naar LINKS uit

# --- SYSTEEM ---
var is_windows = OS.get_name() == "Windows"
var update_interval: float = 0.04
var time_accumulator: float = 0.0

func _ready():
	error_prefix = "ERR-VU-" + my_id
	
	# Verbinden met de MixManager via het nieuwe systeem
	if Engine.has_meta("MixManager"):
		var manager = Engine.get_meta("MixManager")
		if manager.has_signal("vu_update"):
			manager.vu_update.connect(_on_vu_update)
	
	if is_windows:
		print("[%s] Analoge GR-naald simulatie actief op Windows." % error_prefix)

# Ontvanger volgens het 4-punts protocol
func _on_vu_update(incoming_id: String, incoming_type: String, incoming_msg: String, value: float):
	if incoming_id == my_id and incoming_type == my_type and incoming_msg == my_msg:
		_update_gr_needle(value)

func _update_gr_needle(gr_value: float):
	# gr_value 0.0 = 0dB reductie (Rechts)
	# gr_value 1.0 = Volle reductie (Links)
	var target_rot = zero_reduction_angle + (gr_value * (max_reduction_angle - zero_reduction_angle))
	
	# Compressoren reageren supersnel (QUAD ease)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", target_rot, 0.05)

# --- WINDOWS SIMULATIE ---
func _process(delta):
	if is_windows and not Engine.has_meta("MixManager"):
		time_accumulator += delta
		if time_accumulator >= update_interval:
			# Simulatie: De naald staat meestal op 0 (rechts) 
			# en slaat af en toe snel naar links (compressie)
			var t = Time.get_ticks_msec() / 200.0
			# De sinus wordt 'geclipt' zodat hij vaker op 0 blijft staan (ruststand)
			var mock_gr = clamp(sin(t) * 1.5 - 0.5, 0.0, 1.0)
			
			_update_gr_needle(mock_gr)
			time_accumulator = 0.0
