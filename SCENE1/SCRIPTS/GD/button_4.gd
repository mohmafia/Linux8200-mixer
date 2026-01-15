extends Button

func _ready():
	self.modulate = Color.WHITE
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	var manager = get_node("/root/Compressor") # of een ander pad waar je manager zit
	manager.set_active(self)
