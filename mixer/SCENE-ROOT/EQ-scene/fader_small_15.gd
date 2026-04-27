extends Sprite2D

# --- [cite: 2026-02-10] Universal Settings via Inspector ---
@export_group("Fader Config")
@export var target_id: String = " " # mix-in-1 t/m 8 of EQ_BASS
@export var fader_type: String = "EQ"   # INPUT, MASTER, of EQ
@export var fader_msg: String = "VOL"      # VOL, GAIN, BASS, MID, TREBLE

@export_group("Movement Limits")
@export var min_y: float = 250.0   # Bottom (0.0)
@export var max_y: float = -90.0  # Top (1.0)

var dragging = false

func _ready():
	# [cite: 2026-02-27] Connect to universal MixManager signal
	MixManager.remote_fader_move.connect(_on_remote_move)
	
	_load_initial_position()

func _load_initial_position():
	# Crash-safe check voor de nieuwe MixManager lades
	var section = "inputs" if fader_type == "INPUT" else "masters"
	var saved_val = 0.25 # Default middle position
	
	if MixManager.mixer_data.has(section) and MixManager.mixer_data[section].has(target_id):
		saved_val = MixManager.mixer_data[section][target_id].get(fader_msg.to_lower(), 0.5)
	
	# Zet fader op de juiste positie
	position.y = min_y + (saved_val * (max_y - min_y))

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and get_rect().has_point(to_local(event.position)):
			dragging = true
			get_viewport().set_input_as_handled()
		else:
			dragging = false
	
	elif event is InputEventMouseMotion and dragging:
		position.y = clamp(position.y + event.relative.y, max_y, min_y)
		_force_update_system()

func _force_update_system():
	# Berekening: (Huidig - Laag) / (Hoog - Laag)
	var ratio = (position.y - min_y) / (max_y - min_y)
	
	# [cite: 2026-02-04] Universal call with English logging
	MixManager.process_action(target_id, fader_type, fader_msg.to_upper(), ratio)

func _on_remote_move(id, type, val):
	# Match op ID en op het bericht (bijv. VOL of GAIN)
	if id == target_id and type == fader_msg.to_upper():
		var target_y = min_y + (val * (max_y - min_y))
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position:y", target_y, 0.4)
