extends Area2D


@onready var sprite_2d = $AnimatedSprite2D
@onready var dying_animation_timer = $"Dying Animation Timer"

@export var speed_limits: Array
var speed = 0

var x_limits = Vector2(-12000, 12000)
var y_limits = Vector2(-17500, -3500)
var direction = 1
var dying = false

func _ready():
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
	if not dying:
		direction = (get_meta("player_position") - position).angle()
		rotation = direction
		if not get_meta("grabbed"):
			position += speed*delta*Vector2(cos(direction), sin(direction))
			if not ((x_limits.x <= position.x) and (position.x <= x_limits.y))\
			or not ((y_limits.x <= position.y) and (position.y <= y_limits.y)):
				queue_free()

func _on_area_entered(area):
	if area.name == "Collision Detection Area" and not get_meta("grabbed"):
		dying = true
		set_meta("edible", false)
		sprite_2d.play("explosion")
		dying_animation_timer.start()

func _on_dying_animation_timer_timeout():
	queue_free()
