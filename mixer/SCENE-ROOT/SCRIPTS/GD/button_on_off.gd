extends Button

# --- CONFIGURATIE ---
@export var target_id: String = "Mix_GlobComp" 
@export var is_global: bool = true
var my_type = "button"
var my_msg = "comp_on"
var error_prefix = "ERR-COMP-SW-A"

var is_active: bool = false

func _ready():
	# Bepaal de ID op basis van Global of Per Master
	if is_global:
		target_id = "Mix_GlobComp"
		error_prefix = "ERR-COMP-GLO"
	else:
		# FIX: to_upper() in plaats van upper()
		error_prefix = "ERR-COMP-SW-" + target_id.replace("Mix_", "").to_upper()
	
	# Haal de huidige status op uit de MixManager cache
	if MixManager.mixer_data["channels"].has(target_id):
		is_active = MixManager.mixer_data["channels"][target_id].get(my_msg, false)
	
	_update_visuals()

func _pressed():
	# Flip de status
	is_active = !is_active
	
	# Update de visuele stand van de knop
	_update_visuals()
	
	# Stuur naar de MixManager (4-argumenten taal)
	MixManager.send_to_backend(target_id, my_type, my_msg, is_active)

func _update_visuals():
	if is_active:
		# FEL ROOD als de compressor AAN staat
		modulate = Color(1, 0, 0) 
	else:
		# NORMAAL (wit/neutraal) als de compressor UIT staat
		modulate = Color(1, 1, 1) 

	if OS.get_name() == "Windows":
		print("[%s] Knop %s | Status: %s" % [error_prefix, target_id, "AAN (ROOD)" if is_active else "UIT (NORMAAL)"])

	if OS.get_name() == "Windows":
		print("[%s] Knop %s is nu: %s" % [error_prefix, target_id, "AAN" if is_active else "UIT"])
