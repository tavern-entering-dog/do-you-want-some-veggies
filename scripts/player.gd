extends CharacterBody2D


@onready var animated_sprite_2d = $AnimatedSprite2D

@onready var left_arm = $"Left Arm"
@onready var right_arm = $"Right Arm"

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var arm_down_speed = 1

var game_started = false
var eating = false
var dead = false

var time_elapsed = 0
var time_start = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	#if not is_on_floor():
		#velocity.y += gravity * delta

	if time_elapsed < .5:
		time_elapsed += delta
	elif game_started and not eating and not dead:
		var direction = Input.get_axis("move_left", "move_right")
		if direction:
			animated_sprite_2d.play("running")
			if direction < 0:
				animated_sprite_2d.flip_h = true
			elif direction > 0:
				animated_sprite_2d.flip_h = false
			velocity.x = direction * speed
		else:
			animated_sprite_2d.flip_h = false
			animated_sprite_2d.play("idle")
			velocity.x = move_toward(velocity.x, 0, speed)

		move_and_slide()
		
		if Input.is_action_pressed("left_click"):
			var mouse_distance_vector = get_global_mouse_position()\
				- left_arm.position
			left_arm.rotation = mouse_distance_vector.angle() - PI/2
		if Input.is_action_pressed("right_click"):
			var mouse_distance_vector = get_global_mouse_position()\
				- right_arm.position
			right_arm.rotation = mouse_distance_vector.angle() - PI/2

		var left_joystick = Vector2(Input.get_axis("left_joystick_left", "left_joystick_right"),
									Input.get_axis("left_joystick_up", "left_joystick_down"))
		var right_joystick = Vector2(Input.get_axis("right_joystick_left", "right_joystick_right"),
									 Input.get_axis("right_joystick_up", "right_joystick_down"))

		if left_joystick != Vector2.ZERO:
			left_arm.rotation = left_joystick.angle() - PI/2
		if right_joystick != Vector2.ZERO:
			right_arm.rotation = right_joystick.angle() - PI/2

		if left_arm.rotation < -PI:
			left_arm.rotation += 2*PI
		if right_arm.rotation < -PI:
			right_arm.rotation += 2*PI

		left_arm.rotation /= 1 + arm_down_speed*delta
		right_arm.rotation /= 1 + arm_down_speed*delta


func _on_head_area_entered(area):
	if area.get_meta("edible"):
		area.queue_free()
	else:
		for child in area.get_child(2).get_children():
			if child.get_meta("edible"):
				area.get_child(2).remove_child(child)
