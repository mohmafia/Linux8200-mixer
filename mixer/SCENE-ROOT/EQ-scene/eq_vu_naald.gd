# Script voor individuele naald-sprite simulatie
extends Sprite2D

# --- CONFIGURATIE & ERROR CODES ---
@export var naald_id: String = "EQ-LINKS" # Verander naar EQ-RECHTS voor de tweede naald
@export var test_mode: bool = true

# Bereik van de naald in graden (pas dit aan tijdens de F1 race!)
@export var min_hoek: float = -55.0 
@export var max_hoek: float = 50.0
@export var zwaai_snelheid: float = 12.0

const ERR_SIM = "ERR-SPRITE-SIM"

var tijd: float = 0.0

func _ready():
	# OS Check voor Windows test-omgeving
	if OS.get_name() == "Windows":
		print("[%s] Simulatie gestart voor %s. Pas nu de 'Offset' aan." % [ERR_SIM, naald_id])
	
	# Initialisatie check
	if self.texture == null:
		if OS.get_name() == "Windows":
			print("[%s] WAARSCHUWING: Geen texture gevonden op sprite %s!" % [ERR_SIM, naald_id])

func _process(delta):
	if not test_mode:
		return
		
	# Simuleer een bewegende naald met een sinusgolf
	tijd += delta * zwaai_snelheid
	var swing = (sin(tijd) + 1.0) / 2.0 # Waarde tussen 0 en 1
	
	# Bereken de rotatie
	var nieuwe_rotatie = lerp(min_hoek, max_hoek, swing)
	
	# Pas rotatie direct toe op de eigen sprite
	self.rotation_degrees = nieuwe_rotatie

# --- HOE JE DE PIVOT NU INSTEELT ---
# 1. Start de scene. De naald begint te zwaaien.
# 2. Klik in de Scene Tree op de naald-sprite.
# 3. Ga naar de Inspector -> Offset.
# 4. Verschuif de 'Y' waarde van de Offset tot de naald exact om het 
#    middelpunt van de groene cirkel draait.
