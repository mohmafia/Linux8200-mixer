# ==========================================================
# CONFIG MANAGER (Read/Write + Data Cache)
# ==========================================================
extends Node

var base_path = ""
# De 'cache' houdt alle settings in het geheugen voor snelheid
var data_cache = {} 

func _ready():
	if OS.get_name() != "Linux":
		print("!!! WRONG OS !!!! ONLY LINUX !!!")
		return
	
	setup_linux_paths()
	load_all_configs() # We laden alles direct in het geheugen

func setup_linux_paths():
	base_path = OS.get_config_dir() + "/my_mixer/channels/"
	if not DirAccess.dir_exists_absolute(base_path):
		DirAccess.make_dir_recursive_absolute(base_path)

# --- LEZEN ---
func load_all_configs():
	# We scannen de map op alle .ini bestanden
	var dir = DirAccess.open(base_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".ini"):
				load_channel_into_cache(file_name)
			file_name = dir.get_next()
	print("ConfigManager: Cache gevuld met ", data_cache.size(), " kanalen.")

func load_channel_into_cache(file_name: String):
	var channel_id = file_name.replace(".ini", "")
	var config = ConfigFile.new()
	var err = config.load(base_path + file_name)
	
	if err == OK:
		# We slaan alle settings van dit kanaal op in onze Dictionary
		data_cache[channel_id] = {
			"label": config.get_value("Settings", "label", channel_id),
			"volume": config.get_value("Settings", "volume", 0.0),
			"mute": config.get_value("Settings", "mute", false),
			"is_stereo": config.get_value("Settings", "is_stereo", true)
		}

# --- GEBRUIKEN ---
# Hiermee kan je UI straks vragen: "Hoe hard moet fader Input_1 staan?"
func get_cached_value(channel_name: String, key: String):
	if data_cache.has(channel_name):
		return data_cache[channel_name].get(key)
	return null

# --- SCHRIJVEN ---
func save_setting(channel_name: String, key: String, value):
	# 1. Update de cache (geheugen)
	if data_cache.has(channel_name):
		data_cache[channel_name][key] = value
	
	# 2. Schrijf naar de eigen INI op schijf
	var config = ConfigFile.new()
	var path = base_path + channel_name + ".ini"
	config.load(path)
	config.set_value("Settings", key, value)
	config.save(path)
