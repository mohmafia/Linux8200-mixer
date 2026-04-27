extends Button

# --- [cite: 2026-02-10] Universal Settings via Inspector ---
@export_group("Workaround Config")
@export var toggle_id: String = "fix_stereo" 
@export var label_text: String = "FORCE STEREO" # Use a space, script will split it

@export_group("Visuals")
@export var color_on: Color = Color(1.0, 0.2, 0.2) # Red
@export var color_off: Color = Color(1.0, 1.0, 1.0) # White

var is_active: bool = false

func _ready():
	# [cite: 2026-02-27] Formatting text for two lines automatically
	# Replaces the first space with a newline
	self.text = label_text.replace(" ", "\n")
	
	# Visual defaults
	self.modulate = color_off
	self.pressed.connect(_on_button_toggled)
	
	# [cite: 2026-02-05] OS Check
	if OS.get_name() == "Windows":
		print("[INFO] %s: Button initialized (Win Simulation)" % toggle_id)

func _on_button_toggled():
	is_active = !is_active
	
	# Apply modulation: Red for ON, White for OFF
	self.modulate = color_on if is_active else color_off
		
	# [cite: 2026-02-04] English Logging for international users
	var state_msg = "ENABLED" if is_active else "DISABLED"
	var val = 1.0 if is_active else 0.0
	
	print("[WORKAROUND] %s set to %s" % [toggle_id.to_upper(), state_msg])
	
	# Send to the central MixManager
	if MixManager:
		MixManager.process_action(toggle_id, "WORKAROUND", state_msg, val)

# External reset function for the MixManager
func set_external_state(new_state: bool):
	is_active = new_state
	self.modulate = color_on if is_active else color_off
