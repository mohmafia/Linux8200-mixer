extends Button

# --- [cite: 2026-02-10] Settings via Inspector ---
@export_group("Master Toggle Settings")
@export var master_label: String = "Master-C"
@export var virtual_sink_name: String = "mix-out-master-C"
@export var speaker_sink_name: String = "default-speakers" # Fallback/System default
@export var setting_id: String = "master_c_toggle"

# --- State Variables ---
var is_on_air: bool = false # False = White (Speakers), True = Red (Virtual Sink)

func _ready():
	# [cite: 2026-02-05] OS Check
	if OS.get_name() == "Linux":
		self.pressed.connect(_on_toggle_pressed)
		update_visuals()
	else:
		self.disabled = true
		self.text = "WIN_MODE"

func _on_toggle_pressed():
	is_on_air = !is_on_air # Flip the state
	
	var target_sink = virtual_sink_name if is_on_air else speaker_sink_name
	var state_msg = "ON_AIR" if is_on_air else "MONITOR_ONLY"
	
	# [cite: 2026-02-04] English Logging & Universal MixManager
	print("[INFO] %s Toggle: %s (Target: %s)" % [master_label, state_msg, target_sink])
	
	# Notify the MixManager (which handles INI and Go-backend)
	var value = 1.0 if is_on_air else 0.0
	MixManager.process_action(setting_id, "MASTER_TOGGLE", state_msg, value)
	
	# Execute the routing change via pactl
	_execute_routing(target_sink)
	
	# Update the look of the button
	update_visuals()

func update_visuals():
	if is_on_air:
		# Red color for On-Air/Virtual Sink
		self.modulate = Color(1.0, 0.2, 0.2) # Red
		self.text = master_label + " (VIRT)"
	else:
		# White color for Speakers/Monitoring
		self.modulate = Color(1.0, 1.0, 1.0) # White
		self.text = master_label + " (SPK)"

func _execute_routing(sink_name):
	# Here we tell Linux to move the Master stream to the chosen sink
	var output = []
	# Note: The Go-backend will eventually handle the heavy lifting, 
	# but we can trigger a move-sink-input or set-default-sink here.
	OS.execute("pactl", ["set-default-sink", sink_name], output, true, false)
