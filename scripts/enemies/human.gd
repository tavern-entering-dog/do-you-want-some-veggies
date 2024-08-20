extends Area2D


@onready var sprite_2d = $AnimatedSprite2D
@export var possible_textures: Array
@export var speed_limits: Array

var x_limits = Vector2(-1400, 1400)
var y_limits = Vector2(-2500, -1500)
var direction = 1
var speed = 1

func _ready():
	if not get_meta("is_initialized"):
		sprite_2d.sprite_frames = SpriteFrames.new()
		sprite_2d.sprite_frames.set_animation_loop("default", true)

		var texture_no = randi() % len(possible_textures)
		if typeof(possible_textures[texture_no]) == TYPE_ARRAY:
			for texture in possible_textures[texture_no]:
				sprite_2d.sprite_frames.add_frame("default", texture)
		else:
			sprite_2d.sprite_frames.add_frame("default", possible_textures[texture_no])
		direction = (randi() % 2) * 2 - 1
		sprite_2d.flip_h = true if direction == -1 else false
		position = Vector2(
			-(x_limits.x + 1) * direction,
			-535 if randf() > .5 else 70
		)
		speed = randf_range(speed_limits[0], speed_limits[1])
		set_meta("is_initialized", true)
		sprite_2d.play("default")


func _physics_process(delta):
	if not get_meta("grabbed"):
		position.x += -direction*speed*delta
		if x_limits.x > position.x or x_limits.y < position.x:
			queue_free()
