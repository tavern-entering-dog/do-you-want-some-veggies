extends Sprite2D


@export var wiggleness = 100

var base_position: Vector2 = Vector2(0, 0)
var time_elapsed: float = 0

func _ready():
	base_position = position

func _process(delta):
	time_elapsed += delta
	if time_elapsed >= 2*PI:
		time_elapsed = 0
	position.x = base_position.x + wiggleness*sin(time_elapsed)
