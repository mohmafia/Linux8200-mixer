extends Node

# [2026-03-22] MixManager - DE CENTRALE HUB (Schone Lei)
# Verantwoordelijk voor: Cache, Handshaking en het aansturen van Pactl & Go.

# --- [ STATUS & CONFIG ] ---
var mixer_data = {
	"inputs": {},
	"masters": {},
	"system": {},
	"workarounds": {},
	"compressors": {},
	"eq": {}
}

var pending_handshakes = {}
var handshake_timeout_ms = 200

# Signalen voor de UI (meters en remote control)
signal remote_fader_move(id, msg, val) 
signal vu_update(id, value) 
signal pvu_update(id, msg, value) 
signal avu_update(id, type, msg, val)

@onready var debug_label = get_node_or_null("/root/MainScene/UI/DebugLabel")

func _ready():
	Engine.set_meta("MixManager", self)
	_fill_default_cache()
	_log_debug("[SYSTEM] MixManager Online. Fundament is geladen.", "green")
	TCP.packet_received.connect(_on_backend_packet)


func _on_backend_packet(cmd: int, payload: PackedByteArray):
	handle_backend_command(cmd, payload)


func handle_backend_command(cmd: int, payload: PackedByteArray):
	print("TCP CMD:", cmd, "Payload:", payload)

# --- [ DE CENTRALE MOTOR ] ---

func process_action(id: String, type: String, msg: String, val: float):
	# 1. Update de interne Cache (Single Source of Truth)
	_update_cache(id, type, msg, val)
	
	# 2. Directe aansturing van Linux Audio via Pactl
	# Alleen voor volume/mute — NIET voor EQ
	if (msg == "vol" or msg == "mute") and type != "EQ":
		if has_node("/root/Pactl"):
			if msg == "vol":
				get_node("/root/Pactl").set_volume(id, val)
			elif msg == "mute":
				var is_muted = val > 0.5
				get_node("/root/Pactl").set_mute(id, is_muted)
	
	# 3. Registreer de Handshake verwachting voor Go
	var key = id + "_" + msg
	pending_handshakes[key] = Time.get_ticks_msec()
	
	# 4. Stuur naar Go-Backend voor DSP (EQ/Comp) en Handshake
	if has_node("/root/BackendManager"):
		get_node("/root/BackendManager").send_data({
			"id": id,
			"type": type,
			"msg": msg,
			"val": val
		})

# --- [ NETWERK ONTVANGST ] ---

func handle_incoming_packet(packet: String):
	# 0. Opschonen
	packet = packet.strip_edges()
	if packet.is_empty():
		return

	# 1. ANALOGE VU (AVU)
	if packet.begins_with("AVU|"):
		var parts = packet.split("|")
		if parts.size() == 4:
			var id = parts[1]
			var valL = float(parts[2])
			var valR = float(parts[3])
			emit_signal("avu_update", id, "AVU", "lvl_L", valL)
			emit_signal("avu_update", id, "AVU", "lvl_R", valR)
		return

	# 2. STANDAARD VU
	if packet.begins_with("VU|"):
		var parts = packet.split("|")
		if parts.size() == 3:
			emit_signal("vu_update", parts[1], float(parts[2]))
			emit_signal("pvu_update", parts[1], "mono", float(parts[2]))
		return

	# 3. CLIP LED
	if packet.begins_with("CLIP|"):
		var parts = packet.split("|")
		if parts.size() == 3:
			emit_signal("clip_update", parts[1], int(parts[2]))
		return

	# 4. STATUS
	if packet.begins_with("STATUS|"):
		var parts = packet.split("|")
		if parts.size() == 3:
			emit_signal("status_update", parts[1], parts[2])
		return

	# 5. JSON / HANDSHAKE DATA
	if packet.begins_with("{"):
		var json = JSON.parse_string(packet)
		if json is Dictionary:
			var id = json.get("id", "")
			var msg = json.get("msg", "")
			
			if json.get("status") == "OK":
				var key = id + "_" + msg
				if pending_handshakes.has(key):
					pending_handshakes.erase(key)
			else:
				var type = json.get("type", "INPUT")
				var val = float(json.get("val", 0.0))
				emit_signal("remote_fader_move", id, msg, val)
				_update_cache(id, type, msg, val)

func _process(_delta):
	var now = Time.get_ticks_msec()
	for key in pending_handshakes.keys():
		if now - pending_handshakes[key] > handshake_timeout_ms:
			_log_error("[err-mix-001] TIMEOUT: Geen respons van Go voor " + key)
			pending_handshakes.erase(key)

# --- [ HELPERS & CACHE ] ---

func _update_cache(id: String, type: String, msg: String, val: float):
	var section = ""
	match type:
		"INPUT": section = "inputs"
		"MASTER": section = "masters"
		"SYSTEM": section = "system"
		"COMPRESSOR": section = "compressors"
		"WORKAROUND": section = "workarounds"
		"EQ": section = "eq"

	if section != "" and mixer_data.has(section):
		if not mixer_data[section].has(id):
			mixer_data[section][id] = {}
		mixer_data[section][id][msg.to_lower()] = val

func _fill_default_cache():
	# Inputs CH1-8
	for i in range(1, 9):
		mixer_data["inputs"]["mixer-in-" + str(i)] = {"vol": 0.0, "mute": 0.0}
	
	# Masters A/B/C
	for m in ["A", "B", "C"]:
		mixer_data["masters"]["mixer-master-" + m] = {"vol": 0.0, "on_air": 0.0}
	
	# EQ
	mixer_data["eq"] = {
		"EQ_BASS": {"bass": 0.5},
		"EQ_TREBLE": {"treble": 0.5}
	}

func _log_debug(text: String, color: String = "white"):
	if debug_label:
		var ts = Time.get_time_string_from_system()
		debug_label.append_text("\n" + ts + " [color=" + color + "]" + text + "[/color]")

func _log_error(text: String):
	_log_debug(text, "red")
	printerr(text)
