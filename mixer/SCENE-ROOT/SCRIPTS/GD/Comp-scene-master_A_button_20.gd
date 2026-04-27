extends ColorRect

# --- CONFIGURATIE ---
@export_group("Instellingen")
@export var button_id: String = "DE-ESSER_R"
@export var manager_node: NodePath

@export_group("Unieke Kleuren")
@export var color_on: Color = Color(1.0, 0.5, 0.0, 1.0) # Oranje
@export var color_off: Color = Color(0.1, 0.1, 0.1, 1.0) # Donkergrijs

var is_on: bool = false
var is_windows = OS.get_name() == "Windows"

func _ready():
	# Zorg dat hij kliks pakt
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)
	
	# Zet hem direct op de kleur uit de inspector
	_update_visuals()

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_on = !is_on
		_update_visuals()
		_notify_manager()

func _update_visuals():
	# We gebruiken GEEN modulate meer, alleen de harde kleur
	if is_on:
		self.color = color_on
	else:
		self.color = color_off
	
	# Debug print om in de console te zien wat er gebeurt
	if is_windows:
		print("[%s] Kleur aangepast naar: %s" % [button_id, self.color])

func _notify_manager():
	var manager = get_node_or_null(manager_node)
	if manager and manager.has_method("receive_button_signal"):
		manager.receive_button_signal(button_id, is_on)
