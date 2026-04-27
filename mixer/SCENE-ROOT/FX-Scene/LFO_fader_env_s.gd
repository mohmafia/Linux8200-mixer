# with mixmanager sync - MANUAL LED VERSION + AUTO BOUNCE ON START
extends Sprite2D

# --- [cite: 2026-02-10] Settings via Inspector ---
@export_group("Fader Config")
@export var my_id: String = " "      # bijv. virt1 t/m virt8 [cite: 2026-01-18]
@export var my_type: String = " "    # INPUT, MASTER of FX
@export var my_msg: String = " "     # PITCH, LEVEL, enz.
@export var error_prefix: String = "FDR-01" # [cite: 2026-02-04]

# --- POSITION SETTINGS ---
const Y_START = 1363.0  # Onderkant (Groen)
const Y_END = 1170.0    # Bovenkant (Rood)

var dragging = false
var current_value = 0.0 # 0.0 tot 1.0
var is_windows = OS.get_name() == "Windows" # [cite: 2026-01-28]

# HIER ZET JE DE NAAM VAN JOUW LED NODE [Handmatige koppeling]
@onready var my_led = $led_fader_env_s

func _ready():
	# [cite: 2026-02-05] OS Check bij opstarten
	_load_value_from_cache()
	
	# Zet fader direct op de juiste plek op basis van cache data
	position.y = lerp(Y_START, Y_END, current_value)
	_update_logic()
	
	if is_windows:
		print("[%s] Fader %s (%s) geladen. Start bounce test..." % [error_prefix, my_id, my_msg])
	
	# --- DIT ONTBAK ER: ROEP DE FUNCTIE AAN ---
	# We wachten heel even (0.1s) zodat de scene volledig geladen is
	get_tree().create_timer(0.1).timeout.connect(do_bounce_test)

func _load_value_from_cache():
	var section = "inputs" if my_type == "INPUT" else "masters"
	if MixManager.mixer_data.has(section) and MixManager.mixer_data[section].has(my_id):
		if MixManager.mixer_data[section][my_id].has(my_msg.to_lower()):
			current_value = MixManager.mixer_data[section][my_id][my_msg.to_lower()]
		else:
			current_value = 0.0
	else:
		current_value = 0.0

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and get_rect().has_point(to_local(event.position)):
				dragging = true
				get_viewport().set_input_as_handled()
			else:
				if dragging:
					_sync_to_mixmanager()
				dragging = false
		
		# [cite: 2026-03-03] Rechtermuisklik voor Factory Reset
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if get_rect().has_point(to_local(event.position)):
				_factory_reset()

	if event is InputEventMouseMotion and dragging:
		position.y = clamp(get_parent().get_local_mouse_position().y, Y_END, Y_START)
		_update_logic()
		get_viewport().set_input_as_handled()

# --- DE BOUNCE FUNCTIE (NU MET AUTOMATISCHE UPDATE) ---
func do_bounce_test():
	if dragging: return
	
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Stap 1: Naar boven
	tween.tween_property(self, "position:y", Y_END, 0.8)
	
	# Stap 2: Naar beneden
	tween.tween_property(self, "position:y", Y_START, 0.8)
	
	# Stap 3: Zorg dat de waarden constant worden bijgewerkt tijdens de animatie
	# Dit is de motor die de fader-logica laat draaien terwijl de Tween beweegt
	tween.finished.connect(_sync_to_mixmanager)

func _process(_delta):
	# Als de fader niet door de muis wordt bewogen maar wel op een andere plek staat
	# dan waar de 'current_value' zegt, updaten we de boel.
	if not dragging:
		_update_logic()

func _update_logic():
	current_value = remap(position.y, Y_START, Y_END, 0.0, 1.0)
	_update_led_gradient()

func _sync_to_mixmanager():
	MixManager.process_action(my_id, my_type, my_msg.to_upper(), current_value)

func _update_led_gradient():
	if not my_led: return
	
	var final_color : Color
	if current_value < 0.5:
		final_color = Color.GREEN.lerp(Color.YELLOW, current_value * 2.0)
	else:
		final_color = Color.YELLOW.lerp(Color.RED, (current_value - 0.5) * 2.0)
	
	my_led.modulate = final_color
	my_led.self_modulate.a = 0.7 + (current_value * 0.3)

func _factory_reset():
	current_value = 0.0
	position.y = Y_START
	_update_logic()
	_sync_to_mixmanager()
	print("[%s] Factory reset uitgevoerd op %s" % [error_prefix, my_id])
