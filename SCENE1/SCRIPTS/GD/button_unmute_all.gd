extends Button

# Vul dit in de inspector in: bijv. "unmute_all" of "force_stereo"
@export var setting_key: String = "" 

# Standaard staat alles op TRUE (AAN)
var on = true

func _ready():
	if not SystemCheck.is_linux():
		self.disabled = true
		return

	# We kijken of er al een opgeslagen waarde is. 
	# Als die er niet is, gebruiken we onze standaard 'true'.
	var saved_state = ConfigManager.get_cached_value("System", setting_key)
	if saved_state != null:
		on = saved_state
	
	update_visuals()
	self.pressed.connect(_on_pressed)

func _on_pressed():
	on = !on
	update_visuals()
	
	# Sla de nieuwe status op
	ConfigManager.save_setting("System", setting_key, on)
	
	# Als dit de unmute_all knop is, voeren we de actie ook direct uit
	if setting_key == "unmute_all" and on == true:
		ConfigManager.force_unmute_all()

func update_visuals():
	# Rood als hij AAN staat, Wit als hij UIT staat
	self.modulate = Color.RED if on else Color.WHITE
