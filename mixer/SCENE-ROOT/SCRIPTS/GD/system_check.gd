extends Node
func print_full_tree(node: Node, prefix: String = ""):
	print(prefix + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		print_full_tree(child, prefix + "  ")
var os_name: String

func _ready():
	os_name = OS.get_name().to_lower()

func is_linux() -> bool:
	return os_name.find("linux") != -1

func is_windows() -> bool:
	return os_name.find("windows") != -1
