# [cite: 2026-02-27] Smart VU Controller (5 Green, 1 Red)
extends VBoxContainer

# Instellingen voor de kleuren
var color_green = Color("#00FF00") # Fel Groen
var color_red   = Color("#FF0000") # Fel Rood

# De "Dim" factor: hoe donker moet de 'uit' stand zijn? (0.2 is 20% helderheid)
var dim_factor = 0.15 

func update_vu(value: int):
	var containers = get_children()
	
	for i in range(containers.size()):
		# Pak de ColorRect uit de MarginContainer
		var rect = containers[i].get_child(0)
		
		# Bepaal de basiskleur (Index 5 is de bovenste/laatste)
		var base_color = color_green
		if i == 5: 
			base_color = color_red
		
		# Logica: Is het segment aan of uit?
		# We tellen van onder (0) naar boven (5)
		if i < value:
			rect.color = base_color # Volle sterkte
		else:
			# Maak de kleur donkerder voor de 'uit' stand
			rect.color = base_color * dim_factor
			
func _ready():
	# Zet de meter op 0 bij het opstarten zodat ze niet wit blijven
	update_vu(0)
