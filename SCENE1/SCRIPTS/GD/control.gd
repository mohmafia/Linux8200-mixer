extends Control  # Root node

func _ready():
	get_window().set_title("LINUX MIXER BY DAN!!!")  # Zet de titelbalk
#	debug_print_tree($".")  # vervang $".", of kies je MixerRoot node

#func debug_print_tree(node: Node = null, indent: String = ""):
#	if node == null:
#		node = get_tree().root  # begin bij root of kies je MixerRoot
#	print(indent, node.name, " (", node, ")")
#	for child in node.get_children():
#		debug_print_tree(child, indent + "  ")  # extra indent voor child nodes
