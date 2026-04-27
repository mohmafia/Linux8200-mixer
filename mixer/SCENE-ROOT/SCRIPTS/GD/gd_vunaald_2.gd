extends Sprite2D

@export var my_id: String = "Master_A"
@export var my_type: String = "AVU"
@export var my_msg: String = "lvl_L"
@export var error_prefix: String = "ERR-AVU-01"

var min_angle = -45.0
var max_angle = 45.0
var target_value: float = 0.0
var current_value: float = 0.0

func _ready():
	# DIRECT verbinden met autoload MixManager
	#if MixManager.has_signal("avu_update"):
	MixManager.avu_update.connect(_on_vu_update)

func _on_vu_update(incoming_id: String, _type: String, incoming_msg: String, value: float):
	if incoming_id == my_id and incoming_msg == my_msg:
		target_value = value

func _process(delta):
	current_value = lerp(current_value, target_value, 7.0 * delta)
	rotation_degrees = lerp(min_angle, max_angle, current_value)
