extends Node

signal configs_loaded

var base_path = ""
var data_cache = {}
var save_timer: Timer

# De kanalen die we gebruiken (overeenkomstig met je knoppen en Go backend)
const CHANNELS = [
	"mic1", "mic2", 
	"virt1", "virt2", "virt3", "virt4", "virt5", "virt6", "virt7", "virt8", 
	"master_a", "master_b", "master_c"
]

func _ready():
	DebugManager.log_info("CONFIG: Start initialisatie...")
	setup_linux_paths()
	
	# Timer om schijfgebruik te beperken bij schuiven
	save_timer = Timer.new()
	save_timer.wait_time = 2.0 
	save_timer.one_shot = true
	add_child(save_timer)
	save_timer.timeout.connect(_on_save_timer_timeout)
	
	ensure_all_configs()
	load_everything()

func setup_linux_paths():
	# OS check voor Windows/Linux paden
	if OS.get_name() == "Windows":
		base_path = "user://config/"
	else:
		base_path = OS.get_config_dir() + "/my_mixer/"
		
	if not DirAccess.dir_exists_absolute(base_path + "channels/"):
		DirAccess.make_dir_recursive_absolute(base_path + "channels/")

func ensure_all_configs():
	# Zorg dat elk INI bestand bestaat, anders aanmaken (zoals gevraagd)
	for ch in CHANNELS:
		var path = base_path + "channels/" + ch + ".ini"
		if not FileAccess.file_exists(path):
			var config = ConfigFile.new()
			config.set_value("Settings", "label", ch.to_upper())
			config.set_value("Settings", "volume", 0.5)
			config.set_value("Settings", "mute", false)
			config.save(path)

func load_everything():
	data_cache.clear()
	for ch in CHANNELS:
		var config = ConfigFile.new()
		var path = base_path + "channels/" + ch + ".ini"
		if config.load(path) == OK:
			data_cache[ch] = {
				"label": config.get_value("Settings", "label", ch.to_upper()),
				"volume": config.get_value("Settings", "volume", 0.5),
				"mute": config.get_value("Settings", "mute", false)
			}
	configs_loaded.emit()
	DebugManager.log_info("CONFIG: Alle INI's geladen. (Code: CFG-001)")

# --- DIT IS DE FUNCTIE DIE DE CRASHES VEROORZAAKTE ---
# Hij accepteert nu netjes 3 argumenten: kanaal, sleutel en standaardwaarde.
func get_cached_value(channel: String, key: String, default_value):
	if data_cache.has(channel) and data_cache[channel].has(key):
		return data_cache[channel][key]
	return default_value

func save_setting(channel: String, key: String, value):
	# Update de cache en start de timer voor het opslaan naar schijf
	if not data_cache.has(channel):
		data_cache[channel] = {}
	data_cache[channel][key] = value
	save_timer.start()

func _on_save_timer_timeout():
	for ch in data_cache.keys():
		var path = base_path + "channels/" + ch + ".ini"
		var config = ConfigFile.new()
		for key in data_cache[ch].keys():
			config.set_value("Settings", key, data_cache[ch][key])
		config.save(path)
	DebugManager.log_info("CONFIG: Wijzigingen opgeslagen naar INI's. (Code: CFG-OK)")
