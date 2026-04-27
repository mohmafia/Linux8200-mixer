extends TextureButton

# We laden de scene alvast in het geheugen
var fx_scene = preload("res://SCENE-ROOT/FX-Scene/FX-Scene.tscn")
var window_instance = null
var error_prefix = "ERR-WINDOW-LAUNCH"

func _ready():
	# Verbind de pressed signal van de knop zelf (als je dat nog niet in de editor hebt gedaan)
	self.pressed.connect(_on_pressed)

func _on_pressed():
	# 1. Check of het venster al bestaat en nog geldig is
	if window_instance != null and is_instance_valid(window_instance):
		window_instance.show() # Maak zichtbaar als het verborgen was
		window_instance.grab_focus() # Breng naar de voorgrond
		
		if OS.get_name() == "Windows":
			print("[%s] Venster bestond al, focus hersteld." % error_prefix)
		return

	# 2. Maak een nieuwe instantie van de compressor scene
	window_instance = fx_scene.instantiate()
	
	# 3. Voeg de nieuwe window toe aan de root van de game
	# We gebruiken call_deferred voor de veiligheid, zoals we gewend zijn
	get_tree().root.call_deferred("add_child", window_instance)
	
	# 4. een tweede window openen
	# We vertellen de nieuwe window direct welk kanaal hij moet laden
	if window_instance.has_method("set_channel"):
		window_instance.set_channel("mix-in-1") # Standaard op kanaal 1 bij openen

	# 4. OS Check voor debuggen
	if OS.get_name() == "Windows":
		print("[%s] Nieuw compressor venster geopend op aparte desktop/monitor." % error_prefix)

# Oude functie laten we even staan voor de referentie, maar hernoemen we
func On_button_pressed_settings_scene_OLD():
	# Deze gebruikten we vroeger om de hele scene te wisselen
	pass
