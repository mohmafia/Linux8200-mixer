extends Sprite2D
# --- [cite: 2026-02-10] Universal Settings via Inspector ---
@export_group("Fader Config")
@export var target_id: String = "EQ_BASS"
@export var fader_type: String = "EQ"
@export var fader_msg: String = "BASS"
@export_group("Movement Limits")
@export var min_y: float = 26.0
@export var max_y: float = -90.0
var dragging = false
var last_sent_ratio: float = -1.0

func _ready():
	MixManager.remote_fader_move.connect(_on_remote_move)
	_load_initial_position()
	print("[FADER-INIT] Loaded fader for:", target_id)

func _load_initial_position():
	var section = "eq"
	var saved_val = 0.5  # midden = flat
	if MixManager.mixer_data.has(section) and MixManager.mixer_data[section].has(target_id):
		saved_val = MixManager.mixer_data[section][target_id].get(fader_msg.to_lower(), 0.5)
	position.y = min_y - (saved_val * (min_y - max_y))
	last_sent_ratio = saved_val

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and get_rect().has_point(to_local(event.position)):
			dragging = true
			get_viewport().set_input_as_handled()
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		position.y = clamp(position.y + event.relative.y, max_y, min_y)
		_check_and_update()

func _check_and_update():
	var ratio = (min_y - position.y) / (min_y - max_y)
	if abs(ratio - last_sent_ratio) > 0.001:
		MixManager.process_action(target_id, fader_type, fader_msg.to_upper(), ratio)
		last_sent_ratio = ratio

func _on_remote_move(id, msg, val):
	if id == target_id and msg == fader_msg.to_upper():
		var target_y = min_y - (val * (min_y - max_y))
		last_sent_ratio = val
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position:y", target_y, 0.4)
