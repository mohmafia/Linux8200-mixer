@tool
extends EditorScript

# [cite: 2026-02-10] Volledige code voor de Rename Tool
# Gebruik: Selecteer een node in de Scene Tree en druk op CTRL+SHIFT+X
func _run():
	# Haal de node op die je op dit moment hebt aangeklikt in de Scene Tree
	var selected_node = get_editor_interface().get_selection().get_selected_nodes()
	
	if selected_node.is_empty():
		print("[ERR-TOOL-01] Selecteer eerst de 'vbox' of 'synth_carrier' node!")
		return

	for node in selected_node:
		_rename_recursive(node)
	
	print("[LOWER-TOOL] Klaar! Geselecteerde nodes en hun kinderen zijn nu lowercase.")

func _rename_recursive(node: Node):
	# Hernoem de huidige node naar kleine letters
	node.name = node.name.to_lower()
	
	# Doe hetzelfde voor alle kinderen (en hun kinderen...)
	for child in node.get_children():
		_rename_recursive(child)
