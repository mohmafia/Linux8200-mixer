# [cite: 2026-03-01] Universal LN Button Script with Radio-Group logic
extends Button

# --- [cite: 2026-02-10] Universal Settings via Inspector ---
@export_group("Button Config")
@export var target_id: String = "LN-1176"      # De ID van je compressor
@export var button_type: String = "COMPRESSOR" # Voor de MixManager lade
@export var button_msg: String = "ratio_4"     # Bijv: ratio_4, ratio_8, attack, release
@export var error_prefix: String = "LN-BTN"    # [cite: 2026-02-04] Error Code Prefix

@export_group("Behavior")
@export var is_radio_button: bool = true       # Voor Ratio knoppen (slechts 1 aan)
@export var radio_group_name: String = "ratio" # Knoppen met dezelfde groep beïnvloeden elkaar

@export_group("Visuals")
@export var color_on: Color = Color(2.0, 0.0, 0.0, 1.0)
@export var color_off: Color = Color(1.0, 1.0, 1.0, 1.0) # Normaal wit

var is_on: bool = true
var is_windows = OS.get_name() == "Windows" # [cite: 2026-02-05] OS Check

func _ready():
	# [cite: 2026-02-05] OS Setup
	if is_windows:
		print("[%s] Initializing %s on Windows" % [error_prefix, button_msg])
	
	# Verbind het standaard Button signaal
	if not is_connected("pressed", _on_pressed):
		connect("pressed", _on_pressed)
	
	_load_initial_state()

func _load_initial_state():
	# We zoeken de status op in MixManager (lade: compressors) [cite: 2026-01-15]
	var section = "compressors"
	
	if MixManager.mixer_data.has(section) and MixManager.mixer_data[section].has(target_id):
		var current_val = MixManager.mixer_data[section][target_id].get(button_msg.to_lower(), 0.0)
		is_on = (current_val > 0.0)
	
	_update_visuals()

func _on_pressed():
	# Als het een radio button is en hij is al aan, doe niks (je kunt een ratio niet 'uit' zetten)
	if is_radio_button and is_on:
		return
		
	is_on = !is_on
	
	# Radio-logica: Zet andere knoppen in dezelfde groep uit
	if is_radio_button and is_on:
		_handle_radio_group()
		
	_update_visuals()
	_sync_to_mixmanager()

func _handle_radio_group():
	# Zoek alle knoppen in dezelfde container die ook dit script hebben
	var siblings = get_parent().get_children()
	for sibling in siblings:
		if sibling != self and sibling.has_method("_is_ln_button"):
			if sibling.radio_group_name == self.radio_group_name:
				sibling.remote_turn_off()

func remote_turn_off():
	# Wordt aangeroepen door een andere knop in de groep
	if is_on:
		is_on = false
		_update_visuals()
		# We hoeven hier niet te syncen, want de nieuwe knop stuurt zijn eigen aanroep

func _is_ln_button(): return true # Helper voor herkenning

func _update_visuals():
	# Alleen de kleur verandert, de TEXT en de SIZE blijven exact hetzelfde
	# Hierdoor verspringt je layout niet.
	self.modulate = color_on if is_on else color_off

func _sync_to_mixmanager():
	# [cite: 2026-02-04] Universele aanroep
	var val = 1.0 if is_on else 0.0
	
	if MixManager.has_method("process_action"):
		MixManager.process_action(target_id, button_type, button_msg.to_upper(), val)
	else:
		printerr("[%s-ERR-01] MixManager missing process_action" % error_prefix)
