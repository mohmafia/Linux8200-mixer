extends Node

# [cite: 2026-02-04] Error Codes:
# [err-be-001] Backend binary niet gevonden in mixer folder
# [err-be-002] Verkeerd data format (id/type mist)
# [err-be-003] UDP Bind mislukt
signal raw_json_received(json)

var socket = PacketPeerUDP.new()
var listen_port = 5555
var send_port = 5556
var backend_pid = -1

@onready var is_linux = OS.get_name() == "Linux" or OS.get_name() == "X11"

func _ready():
	socket.set_dest_address("127.0.0.1", send_port)
	var err = socket.bind(listen_port)
	
	if err != OK:
		print("[err-be-003] UDP Bind mislukt op poort: ", listen_port)
	
	if is_linux:
		_start_backend_process()
	else:
		print("Windows: Scene test-modus. Geen backend gestart.")

func _start_backend_process():
	# OS.get_executable_path().get_base_dir() pakt de map waar de mixer-binary staat.
	# We plakken daar DIRECT de naam van de backend achteraan met path_join.
	var p = OS.get_executable_path().get_base_dir().path_join("mixer_backend")
	
	if FileAccess.file_exists(p):
		backend_pid = OS.create_process(p, [])
		print("Backend gestart vanuit dezelfde map: ", p)
	else:
		# [cite: 2026-02-04] Foutmelding met het exacte pad dat gezocht werd
		printerr("[err-be-001] Backend NIET gevonden! Check of 'mixer_backend' naast de mixer staat op: ", p)

func _process(_delta):
	if socket.get_available_packet_count() > 0:
		while socket.get_available_packet_count() > 0:
			var raw_bytes = socket.get_packet()

			# DebugInspector FIRST
			var clean_bytes = DebugInspector.inspect_raw_packet(raw_bytes)
			var data_string = clean_bytes.get_string_from_utf8()


			# 1. AVU DATA CHECK
			if data_string.begins_with("AVU|"):
				if has_node("/root/MixManager"):
					get_node("/root/MixManager").handle_incoming_packet(data_string)
				continue
				
			# 2. VU DATA CHECK
			if data_string.begins_with("VU|"):
				if has_node("/root/MixManager"):
					get_node("/root/MixManager").handle_incoming_packet(data_string)
				continue

			# 2. JSON DATA CHECK
			if data_string.begins_with("{") or data_string.begins_with("["):
				var json = JSON.parse_string(data_string)
				if json:
					emit_signal("raw_json_received", json)
					if has_node("/root/MixManager"):
						get_node("/root/MixManager").handle_incoming_packet(data_string)

func send_data(data: Dictionary):
	if not data.has("id") or not data.has("type"):
		printerr("[err-be-002] Data format error.")
		return

	var json_string = JSON.stringify(data)
	if is_linux:
		socket.put_packet(json_string.to_utf8_buffer())
	else:
		print("🧪 TX (Test): ", json_string)

func _exit_tree():
	if backend_pid != -1:
		OS.kill(backend_pid)
