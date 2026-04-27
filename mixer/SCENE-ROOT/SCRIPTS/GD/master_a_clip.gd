extends Control

# [cite: 2026-03-11] De poorten zijn 5555/5556, ID's Master_A, Master_B, of Master_C
@export var my_id: String = "Master_A" 

# --- LED NODES ---
@onready var led_clip := $clip_master_a

# --- LOGICA ---
var clip_timer: float = 0.0

func _ready():
	# [cite: 2026-03-10] Gebruik de directe MixManager referentie
	if MixManager.has_signal("vu_update"):
		MixManager.vu_update.connect(_on_vu_update)
	
	# Standaard op gedimd rood ("uit" stand)
	if led_clip:
		led_clip.modulate = Color(0.2, 0, 0, 1.0)

# De backend stuurt nu: VU|Master_A|1.0000
func _on_vu_update(incoming_id: String, value: float):
	if incoming_id == my_id:
		# Als PipeWire een waarde van 1.0 (of hoger door gain) geeft, clippen we
		if value >= 0.97:
			clip_timer = 0.1 # Iets langere hold voor de master (0.4s)
			# DebugManager.log_data("MASTER_CLIP", my_id + " is clipping op PipeWire!")

func _process(delta):
	if clip_timer > 0:
		clip_timer -= delta
		# Fel rood met glow (modulate boven 1.0 werkt als je HDR/Glow aan hebt)
		if led_clip:
			led_clip.modulate = Color(1.9, 0, 0, 1.0) 
	else:
		# Terug naar gedimd/uit
		if led_clip:
			led_clip.modulate = Color(0.2, 0, 0, 1.0)
