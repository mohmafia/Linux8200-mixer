extends Sprite2D

@export var my_id: String = "MIX-GR"
@export var my_type: String = "gr_meter"
@export var my_msg: String = "gr_level"
@export var error_prefix: String = "ERR-AVU-01"

var min_angle = -45.0
var max_angle = 45.0
var target_value: float = 0.0
var current_value: float = 0.0
var is_windows = OS.get_name() == "Windows"

func _ready():
	if Engine.has_meta("MixManager"):
		var manager = Engine.get_meta("MixManager")
		# HIER ZIT DE FIX: we gebruiken avu_update (4 args)
		if manager.has_signal("avu_update"):
			manager.avu_update.connect(_on_vu_update)

func _on_vu_update(incoming_id: String, _type: String, incoming_msg: String, value: float):
	if incoming_id == my_id and incoming_msg == my_msg:
		target_value = value

func _process(delta):
	current_value = lerp(current_value, target_value, 15.0 * delta)
	rotation_degrees = lerp(min_angle, max_angle, current_value)
