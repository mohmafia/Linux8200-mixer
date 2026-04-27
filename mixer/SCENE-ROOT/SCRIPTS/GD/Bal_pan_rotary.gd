extends Sprite2D

@export_group("Rotary Config")
@export var target_id: String = "mixer-in-1"     # zelfde als fader
@export var fader_type: String = "INPUT"         # zelfde als fader
@export var pan_msg: String = "PAN"              # enige verschil: PAN ipv VOL
@export var error_prefix: String = "ROT-01"

var dragging := false
var rotation_min := 0.0
var rotation_max := 298.0
var sensitivity := 1.8

var current_value := 0.5
var is_windows := OS.get_name() == "Windows"


func _ready():
	# Zet de knop op de juiste beginstand
	rotation_degrees = (current_value * (rotation_max - rotation_min)) + rotation_min

	print("[PAN-INIT] Loaded pan for:", target_id, " value:", current_value)


func _input(event):

	if event is InputEventMouseButton:
		if event.pressed and get_rect().has_point(to_local(event.position)):
			dragging = true
		else:
			if dragging:
				_sync_to_mixmanager()
			dragging = false

	elif event is InputEventMouseMotion and dragging:
		rotation_degrees = clamp(
			rotation_degrees - event.relative.y * sensitivity,
			rotation_min,
			rotation_max
		)
		current_value = (rotation_degrees - rotation_min) / (rotation_max - rotation_min)


func _sync_to_mixmanager():
	# Stuurt PAN naar MixManager → Go
	print("[PAN] target:", target_id, " value:", current_value)
	MixManager.process_action(target_id, fader_type, pan_msg.to_upper(), current_value)


func set_knob_value(target_val: float):
	current_value = clamp(target_val, 0.0, 1.0)
	var target_deg := (current_value * (rotation_max - rotation_min)) + rotation_min

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", target_deg, 0.15)
