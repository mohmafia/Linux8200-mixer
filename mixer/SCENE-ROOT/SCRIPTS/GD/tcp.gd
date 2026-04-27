extends Node

# Pactl Singleton, Sinks, Routing, Cleaning up.
# Go is de engine (Internal bus, Effects, Analysis). 
# De handshake is de wet.

signal connected
signal disconnected
signal packet_received(cmd, payload)

var tcp := StreamPeerTCP.new()
var host := "127.0.0.1"
var port := 5557
var is_connected := false
var _timer_retry := 0.0

func _ready():
	# Verbind het eigen signaal om inkomende pakketten te loggen (handig voor debug)
	self.packet_received.connect(_on_packet_received_debug)
	
	print("[GODOT TCP] Initialiseren…")
	_try_connect()

func _try_connect():
	tcp.poll()
	var status = tcp.get_status()

	if status == StreamPeerTCP.STATUS_CONNECTING or status == StreamPeerTCP.STATUS_CONNECTED:
		return

	if status != StreamPeerTCP.STATUS_NONE:
		tcp = StreamPeerTCP.new()

	print("[GODOT TCP] Verbinden met backend…")
	var err = tcp.connect_to_host(host, port)
	if err != OK:
		print("[GODOT TCP] Directe fout bij starten verbinding: ", err)

func _process(delta):
	tcp.poll()
	var status = tcp.get_status()

	match status:
		StreamPeerTCP.STATUS_NONE, StreamPeerTCP.STATUS_ERROR:
			if is_connected:
				_on_disconnected()
			
			_timer_retry += delta
			if _timer_retry > 2.0:
				_timer_retry = 0.0
				_try_connect()

		StreamPeerTCP.STATUS_CONNECTING:
			pass

		StreamPeerTCP.STATUS_CONNECTED:
			if not is_connected:
				_on_connected()
			
			while tcp.get_available_bytes() > 0:
				_read_packet()

func _read_packet():
	# We hebben minimaal 3 bytes nodig (2 CMD + 1 LEN)
	if tcp.get_available_bytes() < 3:
		return

	var cmd = tcp.get_u16()
	var length = tcp.get_u8()

	# Wacht tot de volledige payload binnen is
	while tcp.get_available_bytes() < length:
		tcp.poll() 
		if tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED: 
			return

	var payload_data = tcp.get_data(length)
	if payload_data[0] == OK:
		var payload = payload_data[1]
		emit_signal("packet_received", cmd, payload)

# --- DEBUG FUNCTIE ---
func _on_packet_received_debug(cmd: int, payload: PackedByteArray):
	# Zet de byte-array om naar leesbare tekst
	var message = payload.get_string_from_utf8()
	print("[TCP IN] CMD: %d | Bericht: %s" % [cmd, message])
	
	# Hier kun je later filters maken, bijv:
	# if cmd == 0x0001: (Doe iets met de Hello handshake)

func _on_connected():
	is_connected = true
	print("[GODOT TCP] Verbonden met backend!")
	emit_signal("connected")

func _on_disconnected():
	is_connected = false
	print("[GODOT TCP] Verbinding verloren!")
	emit_signal("disconnected")

func send_command(cmd: int, payload: PackedByteArray):
	if tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		print("[GODOT TCP] Kan command niet sturen: niet verbonden.")
		return

	var packet = PackedByteArray()
	# CMD (BigEndian)
	packet.append((cmd >> 8) & 0xFF)
	packet.append(cmd & 0xFF)
	# LEN
	packet.append(payload.size())
	# PAYLOAD
	packet.append_array(payload)

	tcp.put_data(packet)
