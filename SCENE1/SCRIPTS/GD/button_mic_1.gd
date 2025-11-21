extends MenuButton

func _ready():
	var popup = get_popup()
	popup.clear()
	popup.add_item("MIC1")
	popup.add_item("MIC2")

	# Optioneel: connect om te zien wat er geselecteerd wordt
	popup.connect("id_pressed", Callable(self, "_on_item_selected"))


func _on_item_selected(id):
	var selected = get_popup().get_item_text(id)
	print("Selected device:", selected)
