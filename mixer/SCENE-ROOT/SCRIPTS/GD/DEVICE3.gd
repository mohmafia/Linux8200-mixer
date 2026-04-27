extends Control

# --- CONFIGURATIE ---
@export var target_id: String = "Mix_CH5"
var error_prefix = "ERR-VU-05"
var is_windows = OS.get_name() == "Windows"

# --- LED NODES ---
@onready var led_green := $DEVICE3_led_green
@onready var led_green2 := $DEVICE3_led_green2
@onready var led_yellow := $DEVICE3_led_yellow
@onready var led_red1 := $DEVICE3_led_red1
@onready var led_red2 := $DEVICE3_led_red2
@onready var clip_label := $DEVICE3_clip

# --- DATA ---
var current_vu_level: float = 0.0
var fall_speed: float = 1.2 
var clip_timer: float = 0.1 # [NIEUW] Timer voor zichtbaarheid

func _ready():
	if MixManager.has_signal("vu_update"):
		MixManager.vu_update.connect(_on_vu_update)
	
	# Forceer clip label even UIT bij start
	if clip_label:
		clip_label.visible = false
		clip_label.modulate = Color(1, 1, 1, 1) # Reset kleur naar wit/standaard

func _on_vu_update(id: String, value: float):
	if id == target_id:
		# Peak detection
		if value > current_vu_level:
			current_vu_level = value
		
		# [CRUCIAAL] Als de waarde clipt, zet de timer op een vaste tijd
		if value >= 0.80:
			clip_timer = 0.06 # Blijf 300ms zichtbaar

func _process(delta):
	# 1. Decay (balkjes zakken)
	if current_vu_level > 0:
		current_vu_level -= fall_speed * delta
	current_vu_level = max(current_vu_level, 0.0)
	
	# 2. CLIP TIMER LOGICA
	if clip_timer > 0:
		clip_timer -= delta
		if clip_label:
			clip_label.visible = true
			# We laten hem rood flikkeren voor extra attentie
			clip_label.modulate = Color(1, 0, 0, 1) 
	else:
		if clip_label:
			clip_label.visible = false
	
	_update_leds(current_vu_level)

func _update_leds(volume: float):
	var off = Color(0.12, 0.12, 0.12, 1.0)
	
	# We maken de drempels iets soepeler
	led_green.modulate = Color.WHITE if volume > 0.02 else off
	led_green2.modulate = Color.WHITE if volume > 0.15 else off
	led_yellow.modulate = Color.YELLOW if volume > 0.35 else Color(0.2, 0.2, 0)
	led_red1.modulate = Color.RED if volume > 0.60 else Color(0.2, 0, 0)
	# Als we deze op 0.85 zetten, zal hij vaker tegelijk met de clip (0.99) oplichten
	led_red2.modulate = Color.RED if volume > 0.75 else Color(0.2, 0, 0)
