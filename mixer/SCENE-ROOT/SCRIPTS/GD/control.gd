extends Control  # Root node


func _ready():
	get_window().set_title("LINUX MIXER BY DAN!!!")  # Zet de titelbalk
	# Print de volledige node tree
	#print(debug_generate_tree_map(get_tree().get_root()))
	DebugManager.set_label($CanvasLayer/DebugOutput)
	
# Zet de max frames per seconde op 30 (of 20 als je CPU wilt sparen)
	Engine.max_fps = 60 


# --- DEZE FUNCTIE HELEMAAL ONDERAAN PLAKKEN ---
func debug_generate_tree_map(node: Node, indent: String = "") -> String:
	var result = indent + node.name + " (" + node.get_class() + ")\n"
	for child in node.get_children():
		# Gebruik een unieke naam om conflicten met de engine te voorkomen
		result += debug_generate_tree_map(child, indent + "  ")
	return result
