extends MenuButton

func _ready():
	if SystemCheck.is_linux():
		# Perform DSP/mixer/pre-amp logic
		var devices = AudioServer.get_output_device_list()
		for d in devices:
			print(d)
			get_popup().add_item(d)

		get_popup().connect("id_pressed", Callable(self, "_on_item_selected"))
	else:
		#print("WINDOWS: DSP uitgeschakeld")
		pass


func _on_item_selected(index):
	if SystemCheck.is_linux():
		var selected = get_popup().get_item_text(index)
		AudioServer.output_device = selected
		print("Geselecteerd device:", selected)
	else:
		#print("WINDOWS: functie uitgeschakeld")
		pass
