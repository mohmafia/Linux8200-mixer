extends Button


var linked = false
var updating = false

func _ready():
	self.modulate = Color.WHITE
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	linked = !linked
	self.modulate = Color.RED if linked else Color.WHITE
