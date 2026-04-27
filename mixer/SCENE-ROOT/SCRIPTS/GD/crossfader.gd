extends Sprite2D

# --- [cite: 2026-02-10] Universal Settings via Inspector ---
@export_group("Crossfader Config")
@export var target_id: String = "xfader_1"  # Nieuwe Engelse ID
@export var fader_type: String = "SYSTEM"   # SYSTEM of WORKAROUND
@export var fader_msg: String = "POS"      # Position

@export_group("Movement Limits")
@export var min_x: float = -44.0  # Left (0.0)
@export var max_x: float = 112.0  # Right (1.0)

var dragging = false

func _ready():
	# [cite: 2026-02-27] Connect to universal MixManager signal
	MixManager.remote_fader_move.connect(_on_remote_move)
	
	_load_initial_position()

func _load_initial_position():
	# We kijken in de 'system' lade voor de crossfader
	var saved_pos = 0.5 # Default: Midden
	
	# Crash-safe check voor de nieuwe MixManager dictionaries
	if MixManager.mixer_data.has("system") and MixManager.mixer_data["system"].has(target_id):
		saved_pos = MixManager.mixer_data["system"][target_id].get(fader_msg.to_lower(), 0.5)
	
	# Zet fader op de juiste positie
	position.x = min_x + (saved_pos * (max_x - min_x))

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and get_rect().has_point(to_local(event.position)):
			dragging = true
			get_viewport().set_input_as_handled()
		else:
			dragging = false
	
	elif event is InputEventMouseMotion and dragging:
		# Horizontale beweging (X-as)
		position.x = clamp(position.x + event.relative.x, min_x, max_x)
		_force_update_system()

func _force_update_system():
	# Berekening: (Huidig - Min) / Bereik
	var ratio = (position.x - min_x) / (max_x - min_x)
	
	# [cite: 2026-02-04] Universal call with English logging
	# ID: xfader_1 | TYPE: SYSTEM | MSG: POS | VAL: 0.5
	MixManager.process_action(target_id, fader_type, fader_msg.to_upper(), ratio)

func _on_remote_move(id, type, val):
	# Match op ID en op het type (bijv. SYSTEM)
	if id == target_id and type == fader_type:
		var target_x = min_x + (val * (max_x - min_x))
		
		# Vloeibare beweging voor de 'Crossfader Dance'
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position:x", target_x, 0.3)
