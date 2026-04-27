extends Node

# Pactl.gd – Godot 4.4
# Sinks + volume + mute + routing + debug + nette cleanup

var is_linux: bool = OS.get_name() == "Linux" or OS.get_name() == "X11"
var active_modules: Array[String] = []


func _ready() -> void:
	#print("[PACTL] _ready() – is_linux:", is_linux)
	if is_linux:
		call_deferred("initialize_mixer_sinks")


# ---------------------------------------------------------
# INIT: SINKS AANMAKEN + ROUTING
# ---------------------------------------------------------

func initialize_mixer_sinks() -> void:
	if not is_linux:
		return

	#print("[PACTL] Initializing mixer sinks...")

	# Masters
	for m in ["A", "B", "C"]:
		var sink_name: String = "mixer-master-" + m
		var desc: String = "Master_" + m
		create_sink(sink_name, desc)

	# Inputs
	for i in range(1, 9):
		var sink_name: String = "mixer-in-" + str(i)
		var desc: String = "Mix_CH" + str(i)
		create_sink(sink_name, desc)

	# Bridge master-A → fysieke default sink
	#print("[PACTL] Creating loopback mixer-master-A → @DEFAULT_SINK@")
	_execute(PackedStringArray([
		"load-module",
		"module-loopback",
		"source=mixer-master-A.monitor",
		"sink=@DEFAULT_SINK@",
		"latency_msec=5"
	]))

	# ROUTE alle inputs naar master A
	#print("[PACTL] Creating loopbacks mixer-in-X → mixer-master-A")
	#for i in range(1, 9):
	#	_execute(PackedStringArray([
	#		"load-module",
	#		"module-loopback",
	#		"source=mixer-in-%d.monitor" % i,
	#		"sink=mixer-master-A",
	#		"latency_msec=5"
	#	]))

	# Zorg dat master-A hoorbaar is
	set_mute("mixer-master-A", false)


func create_sink(s_name: String, description: String) -> void:
	if not is_linux:
		return

	#print("[PACTL] Creating sink:", s_name, "desc:", description)

	var args: PackedStringArray = PackedStringArray([
		"load-module",
		"module-null-sink",
		"sink_name=" + s_name,
		"sink_properties=device.description=" + description
	])

	var output: Array = []
	var code: int = OS.execute("pactl", args, output, true)

	#print("[PACTL] create_sink RC:", code, "OUT:", output)

	if code == 0 and output.size() > 0:
		var module_id: String = str(output[0]).strip_edges()
		active_modules.append(module_id)
		#print("[PACTL] Registered module:", module_id, "for sink:", s_name)

		# Start veilig op mute
		set_mute(s_name, true)
	else:
		printerr("[PACTL] ERROR: Failed to create sink:", s_name)


# ---------------------------------------------------------
# VOLUME & MUTE
# ---------------------------------------------------------

func set_volume(s_name: String, val: float) -> void:
	if not is_linux:
		return

	#print("[PACTL] set_volume request →", s_name, "val:", val)

	var clamped: float = clamp(val, 0.0, 1.0)
	var vol_pct: String = str(int(clamped * 100.0)) + "%"
	#print("[PACTL] → Target volume:", vol_pct)

	var sink_id: String = get_sink_id(s_name)
	if sink_id == "":
		printerr("[PACTL] ERROR: No sink ID found for:", s_name)
		return

	#print("[PACTL] Using sink ID:", sink_id)
	_execute(PackedStringArray(["set-sink-volume", sink_id, vol_pct]))


func set_mute(s_name: String, mute: bool) -> void:
	if not is_linux:
		return

	#print("[PACTL] set_mute request →", s_name, "mute:", mute)

	var sink_id: String = get_sink_id(s_name)
	if sink_id == "":
		printerr("[PACTL] ERROR: No sink ID found for mute:", s_name)
		return

	var m_val: String = "1" if mute else "0"
	#print("[PACTL] Using sink ID:", sink_id, "mute:", m_val)
	_execute(PackedStringArray(["set-sink-mute", sink_id, m_val]))


# ---------------------------------------------------------
# ROUTING: APP → INPUT
# ---------------------------------------------------------

func move_app_to_input(app_id: String, sink_name: String) -> void:
	if not is_linux:
		return

	#print("[PACTL] Routing request → app:", app_id, "→ sink:", sink_name)

	var sink_id: String = get_sink_id(sink_name)
	if sink_id == "":
		printerr("[PACTL] ERROR: No sink ID found for routing to:", sink_name)
		return

	#print("[PACTL] EXEC: move-sink-input", app_id, "→", sink_id)
	_execute(PackedStringArray(["move-sink-input", app_id, sink_id]))

	# Zorg dat de input hoorbaar is
	set_mute(sink_name, false)


# ---------------------------------------------------------
# SINK-ID LOOKUP
# ---------------------------------------------------------

func get_sink_id(name: String) -> String:
	if not is_linux:
		return ""

	#print("[PACTL] get_sink_id() for:", name)

	var out: Array = []
	var code: int = OS.execute(
		"pactl",
		PackedStringArray(["list", "sinks"]),
		out,
		true
	)

	if code != 0:
		printerr("[PACTL] ERROR: 'pactl list sinks' failed:", code, "OUT:", out)
		return ""

	var text: String = "".join(out)
	var lines: PackedStringArray = text.split("\n")

	var current_id: String = ""

	for raw_line in lines:
		var line: String = raw_line.strip_edges()

		if line.begins_with("Sink #"):
			current_id = line.replace("Sink #", "").strip_edges()

		if line.begins_with("Name:") and line.contains(name):
			#print("[PACTL] get_sink_id →", name, "→", current_id)
			return current_id

	#print("[PACTL] get_sink_id → NOT FOUND:", name)
	return ""


# ---------------------------------------------------------
# EXEC WRAPPER
# ---------------------------------------------------------

func _execute(args: PackedStringArray) -> int:
	if not is_linux:
		return 0

	#print("[PACTL] EXEC:", args)
	var out: Array = []
	var code: int = OS.execute("pactl", args, out, true)
	#print("[PACTL] RC:", code, "OUT:", out)
	return code


# ---------------------------------------------------------
# CLEANUP (MUTE EERST → DAN PAS OPRUIMEN)
# ---------------------------------------------------------

func _exit_tree() -> void:
	if not is_linux:
		return

	print("[PACTL] Cleaning up mixer sinks...")

	# 1. Eerst alle mixer-sinks muten om BBRRRRR te voorkomen
	for m in ["A", "B", "C"]:
		set_mute("mixer-master-" + m, true)
	for i in range(1, 9):
		set_mute("mixer-in-" + str(i), true)

	# Kleine pauze zodat PipeWire de mute kan verwerken
	OS.delay_msec(100)

	# 1. Eerst ALLE loopbacks unloaden
	print("[PACTL] Unloading loopbacks first")
	OS.execute("pactl", ["unload-module", "module-loopback"], [], false)

	# 2. Daarna pas de sinks
	for m in active_modules:
		print("[PACTL] Unloading sink module:", m)
		OS.execute("pactl", ["unload-module", m], [], false)

	print("[PACTL] Cleanup done.")
