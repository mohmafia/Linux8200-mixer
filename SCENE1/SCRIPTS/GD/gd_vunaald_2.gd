extends Sprite2D

var min_angle = -45  # Minimale hoek (-20 dB)
var max_angle = 45  # Maximale hoek (+5 dB)
var bpm = 130  # BPM van de techno beat
var time_elapsed = 0.0  # Tijd bijhouden
var vu_target = 0.0  # Doelwaarde van de naald
var vu_current = 0.0  # Huidige waarde van de naald
var damping_factor = 0.21  # Hoeveelheid demping (lager = trager)

func _process(delta):
	time_elapsed += delta

	# Simuleer een techno beat met een sinusgolf
	var beat_strength = abs(sin(time_elapsed * bpm * 0.0523)) * 1.0 

	# Voeg random fluctuatie toe voor realisme
	var noise = randf() * 0.1 - 0.1  

	# Stel een doelwaarde vast
	vu_target = beat_strength + noise  

	# Simuleer demping met geleidelijke verandering naar de doelwaarde
	vu_current = lerp(vu_current, vu_target, damping_factor)

	# Bereken nieuwe rotatiehoek voor de naald
	var angle = lerp(min_angle, max_angle, vu_current)
	rotation_degrees = angle
