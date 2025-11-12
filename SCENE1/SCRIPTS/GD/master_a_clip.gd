extends Control


@onready var led_clip := $clip_master_a



var update_interval := 0.11
var time_accumulator := 0.0

var fader_volume := 1.0
var gain := 1.9

func set_fader_volume(value: float):
	fader_volume = value

func _process(delta):
	time_accumulator += delta
	if time_accumulator >= update_interval:
		var adjusted_volume := randf() * fader_volume * gain
		simulate_vu(adjusted_volume)
		time_accumulator = 0.0

func set_gain(value: float):
	gain = value
	simulate_vu(randf() * fader_volume * gain)

func simulate_vu(volume: float):

	if volume > 1.0:
		led_clip.modulate = Color(1, 0, 0)
	else:
		led_clip.modulate = Color(0.6, 0, 0)
