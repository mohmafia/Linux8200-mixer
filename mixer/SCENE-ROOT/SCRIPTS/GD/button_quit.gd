extends Button

func _on_exit_button_pressed():
	# Dit stuurt een officieel verzoek naar het OS/Systeem
	# # Als je de backend ook netjes wilt afsluiten:
	# (Go sluit zichzelf al na 5 sec stilte, maar dit is netter)
	if has_node("/root/BackendManager"):
		get_node("/root/BackendManager").socket.put_packet("quit".to_utf8_buffer())
	
	get_tree().quit()
