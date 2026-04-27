# Master Display Controller - High Resolution Waveforms
extends Control

# --- [cite: 2026-02-10] Nodes ---
#@onready var name_label = $waveformnamelabel  # Het label waar "Complex" stond
@onready var wave_line = $label_black_background/waveformline2d    # De Line2D voor de rode golfvorm

# --- WAVEFORM DATA ---
var waveforms = ["SAW", "SQUARE", "TRIANGLE", "NOISE"]
var current_idx = 1

# --- DISPLAY SETTINGS ---
var resolution = 600  # Hoeveel puntjes we tekenen (hoger = vloeiender)
var cycles = 4.2      # Hoeveel golven we laten zien op het scherm
var display_width = 200.0
var display_height = 40.0

func _ready():
	# Zorg dat de Line2D mooi rood en dun is
	if wave_line:
		wave_line.width = 3.0
		wave_line.default_color = Color.RED
		wave_line.antialiased = true
	_update_display()

# Wordt aangeroepen door de pijltjes
func change_waveform(direction: int):
	current_idx = wrapi(current_idx + direction, 0, waveforms.size())
	_update_display()
	_sync_to_go()

func _update_display():
	#if name_label:
		#name_label.text = waveforms[current_idx]
	_draw_waveform_shape()

func _draw_waveform_shape():
	if not wave_line: return
	wave_line.clear_points()
	
	for i in range(resolution + 1):
		# t gaat van 0.0 naar 1.0 (de x-as van het scherm)
		var t = float(i) / resolution
		var x = t * display_width
		var y = 0.0
		
		# Bereken de 'fase' op basis van het aantal cycli
		var phase = t * cycles
		
		match waveforms[current_idx]:
			"SAW":
				# Zaagtand formule: gaat van 1 naar -1
				y = (1.0 - 2.0 * (phase - floor(phase + 0.5)))
			"SQUARE":
				# Blokgolf: boven als sinus positief is, onder als negatief
				y = 1.0 if sin(phase * TAU) > 0 else -1.0
			"TRIANGLE":
				# Driehoek: absolute waarde van de zaagtand
				y = 2.0 * abs(2.0 * (phase - floor(phase + 0.5))) - 1.0
			"NOISE":
				# Willekeurige ruis
				y = randf_range(-1.0, 1.0)
		
		# Vermenigvuldig met de hoogte van het display
		var pos = Vector2(x, y * display_height)
		wave_line.add_point(pos)

func _sync_to_go():
	# [cite: 2026-02-04] Sync naar MixManager
	MixManager.process_action("Carrier_OSC", "FX", "WAVE_TYPE", float(current_idx))

# [cite: 2026-03-03] Factory Reset naar SAW
func _factory_reset():
	current_idx = 0
	_update_display()
	_sync_to_go()
