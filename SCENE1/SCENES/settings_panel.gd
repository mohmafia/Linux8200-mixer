extends Node2D


func _ready():
	print("--- START SCANNING SETTINGS SCENE NODES ---")
	print_all_children(self, "")
	print("--- END SCANNING SETTINGS SCENE NODES ---")

func print_all_children(node: Node, indent: String):
	# Print de huidige node naam en het type tussen haakjes
	print(indent + "- " + node.name + " (" + node.get_class() + ")")
	
	# Loop door alle kinderen van deze node heen
	for child in node.get_children():
		# Gebruik recursie om ook de kinderen van kinderen te vinden
		print_all_children(child, indent + "    ")
