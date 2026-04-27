
# Script: meter_simulatie.gd
# Hang dit aan de parent node van je naald-sprites
extends Window

# --- CONFIGURATIE & ERROR CODES ---
const ERR_CODE = "ERR-REQ20-SIM"

@export var test_mode: bool = true
@export var naald_links: Sprite2D
@export var naald_rechts: Sprite2D

# Pas deze hoeken aan tot de naald precies de schaal volgt
@export var min_hoek: float = -55.0  # Uiterst links
@export var max_hoek: float = 55.0   # Uiterst rechts
@export var snelheid: float = 1.5    # Hoe snel de naald zwaait

var tijd: float = 0.0

func _ready():

	close_requested.connect(_on_close_requested)


	# OS Check voor jouw Windows test-omgeving
	if OS.get_name() == "Windows":
		print("[%s] Simulatie gestart. Pas de 'Offset' van de sprites aan in de Inspector." % ERR_CODE)
	
	if not naald_links or not naald_rechts:
		if OS.get_name() == "Windows":
			print("[%s] ERROR: Vergeet niet de naalden in de Inspector te slepen!" % ERR_CODE)

func _process(delta):
	if not test_mode:
		return
		
	if naald_links and naald_rechts:
		# We maken een vloeiende beweging van 0.0 naar 1.0 en weer terug
		tijd += delta * snelheid
		var swing = (sin(tijd) + 1.0) / 2.0 
		
		# Bereken de hoek op basis van jouw min/max instellingen
		var huidige_hoek = lerp(min_hoek, max_hoek, swing)
		
		# Pas de rotatie toe op de sprites
		naald_links.rotation_degrees = huidige_hoek
		naald_rechts.rotation_degrees = huidige_hoek
func _on_close_requested():
	queue_free()   # sluit en verwijdert de window
# --- TIPS VOOR DE PIVOT (HET DRAAIPUNT) ---
# 1. Selecteer je naald-sprite in de Scene Tree.
# 2. Ga in de Inspector naar 'Offset'.
# 3. Verander de Y-waarde van de Offset (bijv. -50 of 50).
# 4. Je ziet het draaipunt (het rode kruisje) verschuiven naar de basis van de naald.
