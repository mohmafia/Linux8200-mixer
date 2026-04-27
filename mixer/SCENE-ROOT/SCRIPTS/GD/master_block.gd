extends Sprite2D

@export var target_id: String = "Mix_MASTER_A"
@export var min_y: float = 708
@export var max_y: float = 520

var dragging = false

# We definiëren hier 'fader_side' voor CH1 t/m 3, omdat dit geen stereo-gesplitste faders zijn
var fader_side = "fader" 

func _ready():
	# Luister naar de MixManager voor de Fader Dance van Go
	MixManager.remote_fader_move.connect(_on_remote_move)
	
	# Initialisatie bij opstarten
	if MixManager.mixer_data["channels"].has(target_id):
		var saved_vol = MixManager.mixer_data["channels"][target_id].get("vol", 0.0)
		position.y = min_y - (saved_vol * (min_y - max_y))
	else:
		position.y = min_y

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and get_rect().has_point(to_local(event.position)):
			dragging = true
			get_viewport().set_input_as_handled()
		else:
			dragging = false
	
	elif event is InputEventMouseMotion and dragging:
		position.y = clamp(position.y + event.relative.y, max_y, min_y)
		_force_update_backend()

# Hulpmiddel om de berekening te doen en te versturen
func _force_update_backend():
	var ratio = (min_y - position.y) / (min_y - max_y)
	MixManager.send_to_backend(target_id, fader_side, "vol", ratio)

# DE GEANIMEERDE FADER DANCE (De update voor je bestaande scripts)
func _on_remote_move(id, type, val):
	if id == target_id and type == fader_side:
		# 1. Bereken waar de fader naartoe moet
		var target_y = min_y + (val * (max_y - min_y))
		
		# 2. Maak de 'vloeibare' beweging
		var tween = create_tween()
		
		# We gebruiken TRANS_QUAD en EASE_OUT voor die luxe 'motorized fader' look
		# 0.4 seconden is vaak de 'sweet spot' voor snelheid en soepelheid
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position:y", target_y, 0.4)
		
		# 3. Optioneel: Update de interne cache-waarde (als je die gebruikt)
		if has_signal("volume_changed"):
			emit_signal("volume_changed", val)
