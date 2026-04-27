extends Window

var error_prefix = "ERR-COMP-WINDOW"

func _ready():
	# Dit signaal wordt afgevuurd als je op het kruisje klikt
	self.close_requested.connect(_on_close_requested)
	
	if OS.get_name() == "Windows":
		print("[%s] Window is klaar en luistert naar sluit-commando's." % error_prefix)

func _on_close_requested():
	# We sluiten het venster niet echt af (geen queue_free), 
	# maar we maken het onzichtbaar.
	self.hide()
	
	if OS.get_name() == "Windows":
		print("[%s] Window verborgen via kruisje." % error_prefix)
