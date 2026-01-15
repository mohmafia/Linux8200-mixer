extends Button



var on = false

func _ready():
	self.modulate = Color.WHITE
	connect("pressed", Callable(self, "_on_pressed"))


func _on_pressed():
	on = !on
	self.modulate = Color.RED if on else Color.WHITE
