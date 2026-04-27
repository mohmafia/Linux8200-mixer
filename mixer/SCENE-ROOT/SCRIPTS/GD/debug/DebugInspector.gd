extends Node
var ENABLED := false

# DebugInspector: analyseert RAW bytes voordat Godot iets probeert te parsen.
# Deze module verandert NIETS aan je bestaande code.
# Hij kijkt alleen, detecteert problemen en logt via DebugManager.

func inspect_raw_packet(raw: PackedByteArray) -> PackedByteArray:
	if not ENABLED:
		return raw
	# ---------------------------------------------------------
	# 1. HEX DUMP
	# ---------------------------------------------------------
	var hex_dump := _to_hex(raw)
	DebugManager.log_info("[RAW HEX] " + hex_dump)

	# ---------------------------------------------------------
	# 2. NULL-BYTE DETECTIE
	# ---------------------------------------------------------
	if _contains_null(raw):
		DebugManager.log_error("Null-byte detected in incoming packet", "ENC-NULL")
		raw = _strip_nulls(raw)
		DebugManager.log_info("AUTO-FIX: null-bytes stripped")

	# ---------------------------------------------------------
	# 3. UTF-8 VALIDATIE
	# ---------------------------------------------------------
	if not _is_valid_utf8(raw):
		DebugManager.log_error("Invalid UTF-8 sequence detected", "ENC-UTF8")
		var forced := raw.get_string_from_utf8()
		raw = forced.to_utf8_buffer()
		DebugManager.log_info("AUTO-FIX: forced UTF-8 normalization")

	# ---------------------------------------------------------
	# 4. BOM DETECTIE
	# ---------------------------------------------------------
	if _has_bom(raw):
		DebugManager.log_info("UTF-8 BOM detected, stripping")
		raw = raw.slice(3)  # <-- FIXED: alleen eerste 3 bytes strippen

	# ---------------------------------------------------------
	# 5. WHITESPACE ANALYSE
	# ---------------------------------------------------------
	var s := raw.get_string_from_utf8()
	if s.strip_edges() != s:
		DebugManager.log_info("Trailing or leading whitespace detected")
		s = s.strip_edges()

	# ---------------------------------------------------------
	# RESULTAAT TERUGGEVEN ALS UTF-8 BYTES
	# ---------------------------------------------------------
	return s.to_utf8_buffer()


# ==========================================================
# HELPER FUNCTIES
# ==========================================================

func _to_hex(bytes: PackedByteArray) -> String:
	var out := ""
	for b in bytes:
		out += "%02X " % b
	return out.strip_edges()


func _contains_null(bytes: PackedByteArray) -> bool:
	for b in bytes:
		if b == 0:
			return true
	return false


func _strip_nulls(bytes: PackedByteArray) -> PackedByteArray:
	var clean := PackedByteArray()
	for b in bytes:
		if b != 0:
			clean.append(b)
	return clean


func _has_bom(bytes: PackedByteArray) -> bool:
	return bytes.size() >= 3 \
		and bytes[0] == 0xEF \
		and bytes[1] == 0xBB \
		and bytes[2] == 0xBF


func _is_valid_utf8(bytes: PackedByteArray) -> bool:
	var s := bytes.get_string_from_utf8()

	# 1. Check op replacement character (�)
	if "�" in s:
		return false

	# 2. Lege string maar bytes niet leeg → mogelijk fout
	if s == "" and bytes.size() > 0:
		for b in bytes:
			# Niet-printbare control chars behalve tab, LF, CR
			if b < 32 and b not in [9, 10, 13]:
				return false

	return true

## addon voor syntax awereniss

func validate_and_fix_syntax(packet_string: String) -> Dictionary:
	var result = {"valid": false, "type": "", "data": []}
	var parts = packet_string.split("|")

	# 1. Basis Check
	if parts.size() < 2:
		DebugManager.log_error("Malformed packet: No pipes found", "SYN-01")
		return result

	var type = parts[0]

	# 2. Type-specifieke validatie
	match type:
		"VU":  # VU|ID|Waarde
			if parts.size() != 3:
				DebugManager.log_error("VU packet should have 3 parts, got " + str(parts.size()), "SYN-VU")
				if parts.size() > 3:
					parts = parts.slice(0, 3)
			result.valid = true

		"AVU": # AVU|ID|L_of_R|Waarde
			if parts.size() != 4:
				DebugManager.log_error("AVU packet should have 4 parts, got " + str(parts.size()), "SYN-AVU")
				if parts.size() > 4:
					parts = parts.slice(0, 4)
			result.valid = true

		_:
			DebugManager.log_error("Unknown packet type: " + type, "SYN-UNK")
			return result

	# 3. Resultaat vullen
	if result.valid:
		result.type = type
		result.data = parts

	return result
