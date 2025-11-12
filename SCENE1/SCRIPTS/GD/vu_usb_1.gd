extends Control

@onready var led_green := $DEVICE1_led_green
@onready var led_green2 := $DEVICE1_led_green2
@onready var led_yellow := $DEVICE1_led_yellow
@onready var led_red1 := $DEVICE1_led_red1
@onready var led_red2 := $DEVICE1_led_red2
@onready var clip_label := $DEVICE1_clip


var update_interval := 0.11
var time_accumulator := 0.0

var fader_volume := 1.0
var gain := 1.4

func set_fader_volume(value: float):
	fader_volume = value

func _process(delta):
	time_accumulator += delta
	if time_accumulator >= update_interval:
		var adjusted_volume := randf() * fader_volume * gain
		simulate_vu(adjusted_volume)
		time_accumulator = 0.0

func simulate_vu(volume: float):
	if volume > 0.1:
		led_green.modulate = Color(1, 1, 1)
	else:
		led_green.modulate = Color(0.6, 0.6, 0.6)

	if volume > 0.3:
		led_green2.modulate = Color(1, 1, 1)
	else:
		led_green2.modulate = Color(0.6, 0.6, 0.6)

	if volume > 0.5:
		led_yellow.modulate = Color(1, 1, 0)
	else:
		led_yellow.modulate = Color(0.6, 0.6, 0)

	if volume > 0.7:
		led_red1.modulate = Color(1, 0, 0)
	else:
		led_red1.modulate = Color(0.6, 0, 0)

	if volume > 0.9:
		led_red2.modulate = Color(1, 0, 0)
	else:
		led_red2.modulate = Color(0.6, 0, 0)

	clip_label.visible = volume > 0.95
