extends Area2D


@onready var sprite_2d = $Sprite2D
@export var possible_textures: Array
@export var speed_limits: Array

var x_limits = Vector2(-5500, 5500)
var y_limits = Vector2(-1200, -800)
var direction = 1

func _ready():
	if not get_meta("is_initialized"):
		var texture_no = randi() % len(possible_textures)
		match texture_no:
			0, 1:
				set_meta("nutrients", 33)
			2, 3:
				set_meta("nutrients", 50)
		sprite_2d.texture = possible_textures[texture_no]
		direction = (randi() % 2) * 2 - 1
		sprite_2d.flip_h = true if direction == 1 else false
		position = Vector2(
			-(x_limits.x + 1) * direction,
			randf_range(y_limits.x, y_limits.y)
		)
		set_meta("is_initialized", true)


func _physics_process(delta):
	if not get_meta("grabbed"):
		position.x += -direction*randf_range(speed_limits[0], speed_limits[1])*delta
		if (direction == 1 and position.x > x_limits.y)\
		or (direction == -1 and position.x < x_limits.x):
			queue_free()
