extends Node

# ==========================================================
# CONFIG
# ==========================================================
var log_dir := "user://logs/"
var log_file_path := log_dir + "mixer_session.log"

const MAX_LOG_SIZE := 4 * 1024 * 1024        # 4 MB
const MAX_LOG_DAYS := 4                      # 4 dagen
const MAX_ROTATIONS := 4                     # mixer_session.log.1 → .4

var debug_label: Node = null
var message_buffer = []
var first_log = true

# ==========================================================
# READY
# ==========================================================
func _ready():
	_ensure_log_dir()
	_rotate_logs_if_needed()
	_cleanup_old_logs()


# ==========================================================
# PUBLIC LOGGING API
# ==========================================================
func log_info(msg: String):
	log_msg(msg, false)

func log_error(msg: String, code: String = "ERR"):
	log_msg(msg, true, code)

func log_data(action: String, details: String):
	var line = Time.get_time_string_from_system() + " [DATA] " + action + ": " + details
	print(line)
	_save_to_file(line)
	_update_ui(line, false)

# ==========================================================
# CORE LOGGING
# ==========================================================
func log_msg(msg: String, is_error: bool = false, err_code: String = ""):
	var timestamp = Time.get_time_string_from_system()
	var type = " [OK]    "
	if is_error:
		type = " [FAIL] "

	var error_string = ""
	if err_code != "":
		error_string = " (Code: " + err_code + ")"

	var full_line = timestamp + type + msg + error_string
	print(full_line)
	_save_to_file(full_line)

	if debug_label == null:
		message_buffer.append({"text": full_line, "error": is_error})
	else:
		_update_ui(full_line, is_error)

# ==========================================================
# UI LINKING
# ==========================================================
func set_label(p_label: Node):
	debug_label = p_label

	for old in message_buffer:
		_update_ui(old.text, old.error)

	message_buffer.clear()
	log_info("NOTICE!!! SYSTEM:  (OK! Code: DEBUG-001)")

func _update_ui(text: String, is_error: bool):
	if debug_label and debug_label is RichTextLabel:
		if is_error:
			debug_label.push_color(Color.RED)

		debug_label.add_text(text + "\n")

		if is_error:
			debug_label.pop()

		# Auto-scroll
		await get_tree().process_frame
		var v_scroll = debug_label.get_v_scroll_bar()
		if v_scroll:
			v_scroll.value = v_scroll.max_value


# ==========================================================
# FILE HANDLING + ROTATION
# ==========================================================
func _ensure_log_dir():
	if not DirAccess.dir_exists_absolute(log_dir):
		DirAccess.make_dir_recursive_absolute(log_dir)

func _save_to_file(text: String):
	var file: FileAccess

	if first_log:
		file = FileAccess.open(log_file_path, FileAccess.WRITE)
		if file:
			file.store_line("=== NIEUWE SESSIE: " + Time.get_datetime_string_from_system() + " ===")
			first_log = false
	else:
		file = FileAccess.open(log_file_path, FileAccess.READ_WRITE)
		if file:
			file.seek_end()

	if file:
		file.store_line(text)
		file.close()

# ==========================================================
# LOG ROTATION (4 MB / 4 DAYS)
# ==========================================================
func _rotate_logs_if_needed():
	if not FileAccess.file_exists(log_file_path):
		return

	var f := FileAccess.open(log_file_path, FileAccess.READ)
	if not f:
		return

	var size: int = f.get_length()
	f.close()

	if size < MAX_LOG_SIZE:
		return

	# Rotate existing logs
	for i in range(MAX_ROTATIONS, 0, -1):
		var old := log_file_path + "." + str(i)
		var older := log_file_path + "." + str(i + 1)

		if FileAccess.file_exists(old):
			if i == MAX_ROTATIONS:
				DirAccess.remove_absolute(old)
			else:
				DirAccess.rename_absolute(old, older)

	# Move current log to .1
	DirAccess.rename_absolute(log_file_path, log_file_path + ".1")


func _cleanup_old_logs():
	var dir := DirAccess.open(log_dir)
	if not dir:
		return

	dir.list_dir_begin()
	var file := dir.get_next()

	while file != "":
		if file.begins_with("mixer_session.log"):
			var path := log_dir + file
			var modified := FileAccess.get_modified_time(path)
			var age_days := (Time.get_unix_time_from_system() - modified) / 86400.0

			if age_days > MAX_LOG_DAYS:
				DirAccess.remove_absolute(path)

		file = dir.get_next()

	dir.list_dir_end()
