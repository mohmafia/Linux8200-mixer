extends Line2D

var time_elapsed = 0.0
var bpm = 130  
var base_amplitude = 50.0  
var speed = 0.1  
var points_count = 190  
var sprite_width = 360  # Breedte van je sprite
var sprite_height = 200  
var zoom_factor = 5.5  # Pas deze waarde aan voor zoom-effect

func _ready():
	width = 3.0  
	default_color = Color(1, 1, 1)  
	points.resize(points_count)  

func _process(delta):
	time_elapsed += delta
	var new_points = PackedVector2Array()  

	for i in range(points_count):
		var x = (i / float(points_count)) * sprite_width * zoom_factor  
		x = clamp(x, 0, sprite_width)  # **Fix: Zorg ervoor dat x niet buiten de sprite gaat**

		var frequency = speed + randf_range(-1.05, 1.05)  
		var amplitude = base_amplitude + randf_range(-10.0, 10.0)  

		var y = sin(time_elapsed * bpm * frequency + i * 0.1) * amplitude
		y *= abs(sin(time_elapsed * bpm * 0.0523)) + 0.5  
		y += sprite_height / 2  

		new_points.append(Vector2(x, y))

	self.points = new_points  
