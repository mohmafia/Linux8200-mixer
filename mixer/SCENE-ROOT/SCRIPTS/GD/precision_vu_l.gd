extends Control

# --- CONFIGURATIE ---
@export var my_id: String = "Master_A"
@export var my_type: String = "AVU"
@export var my_msg: String = "lvl_L"
@export var error_prefix: String = "ERR-PVU-01"

var update_interval := 0.042 
var time_accumulator := 0.0
var gain := 0.97
var current_dot_pos : float = 0.0 
var current_peak_index : int = 0
var peak_hold_timer : float = 0.0
const PEAK_HOLD_TIME : float = 0.9
const FALL_SPEED = 36.0
const ATTACK_SPEED = 55.0
var all_leds: Array = []
var is_windows = OS.get_name() == "Windows"

func _ready():
	_initialize_leds()
	MixManager.avu_update.connect(_on_vu_update)
#	if Engine.has_meta("MixManager"):
#		var manager = Engine.get_meta("MixManager")
#		# HIER ZIT DE FIX: we gebruiken pvu_update (3 args)
#		if manager.has_signal("pvu_update"):
#			manager.pvu_update.connect(_on_vu_update)
	
	if is_windows:
		print("[%s] %s:%s geladen" % [error_prefix, my_id, my_msg])

func _initialize_leds():
	for i in range(1, 13):
		var node = get_node_or_null("Pvugreen_L" + ("" if i == 1 else str(i)))
		if node: all_leds.append(node)
	for i in range(1, 11):
		var node = get_node_or_null("Pvuyellow_L" + ("" if i == 1 else str(i)))
		if node: all_leds.append(node)
	for i in range(1, 7):
		var node = get_node_or_null("Pvured_L" + ("" if i == 1 else str(i)))
		if node: all_leds.append(node)

func _on_vu_update(incoming_id: String, _type: String, incoming_msg: String, value: float):
	if incoming_id == my_id and (incoming_msg == my_msg or incoming_msg == "mono"):
		_process_vulevel(value)

func _process(delta):
	if peak_hold_timer > 0:
		peak_hold_timer -= delta
	else:
		if current_peak_index > 0:
			current_peak_index -= 1
	if is_windows and not Engine.has_meta("MixManager"):
		time_accumulator += delta
		if time_accumulator >= update_interval:
			_process_vulevel(randf() * 0.8)
			time_accumulator = 0.0

func _process_vulevel(value: float):
	var target_index = clamp(value * gain * all_leds.size(), 0.0, float(all_leds.size()))
	var d = 0.016 
	if target_index > current_dot_pos:
		current_dot_pos = lerp(current_dot_pos, target_index, ATTACK_SPEED * d)
	else:
		current_dot_pos = lerp(current_dot_pos, target_index, FALL_SPEED * d)
	_render_leds(current_dot_pos)

func _render_leds(dot_pos: float):
	var active_index = clamp(int(dot_pos), 0, all_leds.size() - 1)
	if active_index >= current_peak_index:
		current_peak_index = active_index
		peak_hold_timer = PEAK_HOLD_TIME
	for i in range(all_leds.size()):
		var led = all_leds[i]
		if i == active_index or i == active_index - 1:
			led.modulate = Color(1.1, 1.1, 1.0, 1.0)
		elif i == current_peak_index:
			led.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			led.modulate = Color(1.0, 1.0, 1.0, 0.38)
