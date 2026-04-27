extends Sprite2D

@export var base_position: Vector2 = Vector2(1556, 283)
@export var amplitude: float = 6.0      # hoe “heftig” de vibratie is (in pixels)
@export var speed: float = 40.0         # hoe snel hij trilt

var _time := 0.0

func _ready() -> void:
	position = base_position

func _process(delta: float) -> void:
	_time += delta * speed

	# willekeurige jitter rond de basispositie
	var offset_x = randf_range(-amplitude, amplitude)
	var offset_y = randf_range(-amplitude, amplitude)

	position = base_position + Vector2(offset_x, offset_y)
