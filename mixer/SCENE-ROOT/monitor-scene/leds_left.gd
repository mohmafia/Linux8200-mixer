# [cite: 2026-03-01] American Audio DB Display MKII - Dot Mode
extends HBoxContainer

# --- CONFIGURATIE (Protocol conform) ---
@export var my_id: String = "Monitor_OUT"
@export var my_type: String = "dbdisplay"
@export var my_msg: String = "lvl_L" # lvl_L voor leds-left, lvl_R voor leds-right
@export var error_prefix: String = "ERR-MON-01"

# --- INSTELLINGEN (Ballistiek) ---
var update_interval := 0.042 
var time_accumulator := 0.0
var gain := 1.9 # Iets lager dan Precision voor de DB Display MKII schaal

var current_dot_pos : float = 0.0 
var current_peak_index : int = 0
var peak_hold_timer : float = 0.0
const PEAK_HOLD_TIME : float = 1.5

const FALL_SPEED = 8.0  # Iets trager voor een vintage look
const ATTACK_SPEED = 14.0 

var all_leds: Array = []
var is_windows = OS.get_name() == "Windows" # [cite: 2026-02-05]

func _ready():
	_initialize_leds()
	
	# Luister naar de MixManager voor updates
	if Engine.has_meta("MixManager"):
		var manager = Engine.get_meta("MixManager")
		if manager.has_signal("vu_update"):
			manager.vu_update.connect(_on_vu_update)
	
	if is_windows:
		print("[%s] %s:%s geladen op Windows" % [error_prefix, my_id, my_msg])

func _initialize_leds():
	# We laden alle sprites uit de HBoxContainer
	# Omdat de sprites namen hebben als led_green, led_green2, etc.
	# pakken we gewoon alle kinderen van deze container.
	var children = get_children()
	if children.size() == 0:
		printerr("ERROR_%s_002: Geen sprites gevonden in %s" % [error_prefix, name])
		return
		
	for child in children:
		if child is Sprite2D:
			all_leds.append(child)
	
	if is_windows:
		print("[%s] %d LEDs geïnitialiseerd in %s" % [error_prefix, all_leds.size(), name])

func _on_vu_update(incoming_id: String, incoming_msg: String, value: float):
	# Strikte ID en MSG check [cite: 2026-02-04]
	if incoming_id == my_id and incoming_msg == my_msg:
		_process_vulevel(value)

func _process(delta):
	# Peak timers bijwerken
	if peak_hold_timer > 0:
		peak_hold_timer -= delta
	else:
		if current_peak_index > 0:
			current_peak_index -= 1
			
	# Windows Simulatie (Zonder MixManager) [cite: 2026-01-28]
	if is_windows and not Engine.has_meta("MixManager"):
		time_accumulator += delta
		if time_accumulator >= update_interval:
			_process_vulevel(randf() * 0.9) # Simuleer signaal voor test
			time_accumulator = 0.0

func _process_vulevel(value: float):
	var target_index = clamp(value * gain * all_leds.size(), 0.0, float(all_leds.size()))
	
	# Ballistiek (Attack/Fall)
	var d = 0.016 
	if target_index > current_dot_pos:
		current_dot_pos = lerp(current_dot_pos, target_index, ATTACK_SPEED * d)
	else:
		current_dot_pos = lerp(current_dot_pos, target_index, FALL_SPEED * d)
	
	_render_leds(current_dot_pos)

func _render_leds(dot_pos: float):
	var active_index = clamp(int(dot_pos), 0, all_leds.size() - 1)

	# Peak update logica
	if active_index >= current_peak_index:
		current_peak_index = active_index
		peak_hold_timer = PEAK_HOLD_TIME

	for i in range(all_leds.size()):
		var led = all_leds[i]
		
		# DOT MODE: Alleen het actieve lampje (en eentje eronder) is fel
		if i == active_index or i == active_index - 1:
			led.modulate = Color(1.5, 1.5, 1.5, 1.0) # Fel (HDR)
		# PEAK: De hoogste waarde blijft even 'plakken'
		elif i == current_peak_index:
			led.modulate = Color(1.2, 1.2, 1.2, 1.0) 
		# DIM: De rest staat 'uit' maar blijft zichtbaar [cite: 2026-02-27]
		else:
			led.modulate = Color(1.0, 1.0, 1.0, 0.35)
