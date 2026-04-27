extends Button

# Directe verwijzing naar de faders die bij DEZE knop horen
@onready var fader_left = $"../Fader_device5_L"
@onready var fader_right = $"../Fader_device5_R"

var linked: bool = false
var updating: bool = false

func _ready():
	self.modulate = Color.WHITE
	pressed.connect(_on_pressed)

func _on_pressed():
	linked = !linked
	# Rood als link aan is, wit als link uit is
	self.modulate = Color.RED if linked else Color.WHITE
	
	# Trek ze meteen gelijk als we de link aanzetten
	if linked and fader_left and fader_right:
		_sync_faders(fader_left, fader_right)

func _process(_delta):
	# Als de link aan staat, dwingen we ze om dezelfde Y-positie te houden
	if linked and not updating and fader_left and fader_right:
		if fader_left.position.y != fader_right.position.y:
			# Wie beweegt er? Die is de baas.
			if fader_left.get("dragging"):
				_sync_faders(fader_left, fader_right)
			elif fader_right.get("dragging"):
				_sync_faders(fader_right, fader_left)

func _sync_faders(source, target):
	updating = true
	target.position.y = source.position.y
	
	# Zorg dat de tweede fader ook zijn stand naar GO stuurt
	if target.has_method("force_update"):
		target.force_update()
	
	updating = false
