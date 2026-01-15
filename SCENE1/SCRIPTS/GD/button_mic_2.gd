extends MenuButton

# In de Godot Inspector vul je hier de naam in (bijv. MIC1 of DEVICE1)
@export var channel_id: String = ""

func _ready():
	# We gebruiken jouw eigen SystemCheck singleton
	if SystemCheck.is_linux():
		setup_menu()
		load_saved_settings()
	elif SystemCheck.is_windows():
		# "WRONG OS" principe
		self.disabled = true
		self.text = "WRONG OS !!!!"
		print("!!! WRONG OS !!!! ONLY LINUX !!!")

func setup_menu():
	var popup = get_popup()
	popup.clear()
	
	# Vul het menu met hardware devices
	var devices = AudioServer.get_input_device_list()
	for d in devices:
		popup.add_item(d)

	# Verbind het signaal
	if not popup.id_pressed.is_connected(_on_item_selected):
		popup.id_pressed.connect(_on_item_selected)

func load_saved_settings():
	# Haal de opgeslagen waarde op uit de ConfigManager cache
	var saved_device = ConfigManager.get_cached_value(channel_id, "device")
	if saved_device:
		self.text = saved_device
		AudioServer.input_device = saved_device
	else:
		self.text = "Select Device..."

func _on_item_selected(index):
	# Omdat de popup alleen op Linux werkt (zie _ready), 
	# hoeven we hier niet nóg een keer de OS check te doen.
	var selected = get_popup().get_item_text(index)
	self.text = selected
	
	# Update hardware
	AudioServer.input_device = selected
	
	# Sla op via de ConfigManager
	ConfigManager.save_setting(channel_id, "device", selected)
	print("Config: ", channel_id, " opgeslagen met device: ", selected)
