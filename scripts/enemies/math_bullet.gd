extends Area2D


@onready var sprite_2d = $Sprite2D
@export var possible_textures: Array
@export var speed_limits: Array
var speed = 0

var x_limits = Vector2(-12000, 12000)
var y_limits = Vector2(-17500, -3500)
var direction = 1

func _ready():
	if not get_meta("is_initialized"):
		var texture_no = randi() % len(possible_textures)
		match texture_no:
			0, 2:
				set_meta("nutrients", 75)
			4:
				set_meta("nutrients", 83.3)
			3:
				set_meta("nutrients", 91.6)
			1, 5:
				set_meta("nutrients", 100)
		sprite_2d.texture = possible_textures[texture_no]
		speed = randf_range(speed_limits[0], speed_limits[1])
		match randi() % 4:
			0:
				position = Vector2(x_limits.x, randf_range(y_limits.x, y_limits.y))
			1:
				position = Vector2(x_limits.y, randf_range(y_limits.x, y_limits.y))
			2:
				position = Vector2(randf_range(x_limits.x, x_limits.y), y_limits.x)
			3:
				position = Vector2(randf_range(x_limits.x, x_limits.y), y_limits.y)


func _physics_process(delta):
	if not get_meta("is_initialized"):
		direction = (get_meta("player_position") - position).angle()
		rotation = direction
		if abs(direction) > PI/2:
			sprite_2d.flip_v = true
		set_meta("is_initialized", true)
	if not get_meta("grabbed"):
		position += speed*delta*Vector2(cos(direction), sin(direction))
		if not ((x_limits.x <= position.x) and (position.x <= x_limits.y))\
		or not ((y_limits.x <= position.y) and (position.y <= y_limits.y)):
			queue_free()
