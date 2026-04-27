extends Sprite2D

@export_group("Fader Config")
@export var target_id: String = "mixer-master-A"
@export var fader_type: String = "MASTER"
@export var fader_msg: String = "VOL"

@export_group("Movement Limits")
@export var min_y: float = 708
@export var max_y: float = 536

var dragging = false
var last_sent_ratio: float = -1.0


func _ready():
	MixManager.remote_fader_move.connect(_on_remote_move)
	_load_initial_position()
	print("[MASTER-FADER-INIT] Loaded fader for:", target_id)


func _load_initial_position():
	var section = "inputs" if fader_type == "INPUT" else "masters"
	var saved_vol = 0.0

	if MixManager.mixer_data.has(section) and MixManager.mixer_data[section].has(target_id):
		saved_vol = MixManager.mixer_data[section][target_id].get(fader_msg.to_lower(), 0.0)

	position.y = min_y - (saved_vol * (min_y - max_y))
	last_sent_ratio = saved_vol

	# NIEUW: stuur volume direct naar pactl
	pactl.set_volume(target_id, saved_vol)

	print("[MASTER-FADER-LOAD] target:", target_id, " initial volume:", saved_vol)



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

	print("[MASTER-FADER] target:", target_id, " ratio:", ratio)

	# Direct de autoload aanroepen – geen Engine.get_singleton
	pactl.set_volume(target_id, ratio)

	if abs(ratio - last_sent_ratio) > 0.001:
		MixManager.process_action(target_id, fader_type, fader_msg.to_upper(), ratio)
		last_sent_ratio = ratio


func _on_remote_move(id, msg, val):
	if id == target_id and msg == fader_msg.to_upper():
		var target_y = min_y - (val * (min_y - max_y))
		last_sent_ratio = val

		print("[MASTER-REMOTE-FADER] Syncing remote move for:", id, " val:", val)

		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position:y", target_y, 0.4)
