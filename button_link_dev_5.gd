extends Button

@onready var fader_left = $"../Fader_device5_L"
@onready var fader_right = $"../Fader_device5_R"

var linked = false
var updating = false

func _ready():
	self.modulate = Color.WHITE
	connect("pressed", Callable(self, "_on_pressed"))
	fader_left.connect("volume_changed", Callable(self, "_on_fader_left_changed"))
	fader_right.connect("volume_changed", Callable(self, "_on_fader_right_changed"))

func _on_pressed():
	linked = !linked
	self.modulate = Color.RED if linked else Color.WHITE

func _on_fader_left_changed(_value):
	if linked and not updating:
		updating = true
		fader_right.position.y = fader_left.position.y
		fader_right.update_volume()
		updating = false

func _on_fader_right_changed(_value):
	if linked and not updating:
		updating = true
		fader_left.position.y = fader_right.position.y
		fader_left.update_volume()
		updating = false
