extends CharacterBody2D


signal death

@onready var animated_sprite_2d = $AnimatedSprite2D

@onready var left_arm = $"Left Arm"
@onready var right_arm = $"Right Arm"
@onready var eating_timer = $"Eating Timer"
@onready var death_timer = $"Death Timer"
@onready var eating_particles = $"Eating Particles"
@onready var animation_player = $AnimationPlayer

var left_arm_position = Vector2(0, 0)
var right_arm_position = Vector2(0, 0)

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var arm_down_speed = 1

@export var max_hunger = 100
@export var hunger = 100

var game_started = false
var eating = false
var dead = false
var can_restart = false

var time_elapsed = 0
var time_start = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func self_scale(ratio: float) -> void:
	scale *= ratio
	eating_particles.process_material.scale_min += ratio
	eating_particles.process_material.scale_max += ratio

func _ready():
	left_arm_position = left_arm.position
	right_arm_position = right_arm.position

func _physics_process(delta):
	if time_elapsed < .5:
		time_elapsed += delta
	elif game_started and not eating and not dead:
		var direction = Input.get_axis("move_left", "move_right")
		if direction:
			animated_sprite_2d.play("running")
			animation_player.stop()
			if direction < 0:
				animated_sprite_2d.flip_h = true
				left_arm.position = left_arm_position + Vector2(15, 0)
				right_arm.position = right_arm_position + Vector2(15, 0)
			elif direction > 0:
				animated_sprite_2d.flip_h = false
				left_arm.position = left_arm_position
				right_arm.position = right_arm_position
			velocity.x = direction * speed
		else:
			animated_sprite_2d.flip_h = false
			left_arm.position = left_arm_position
			right_arm.position = right_arm_position
			animated_sprite_2d.play("idle")
			if not animation_player.is_playing():
				animation_player.play("arms_idle", -1, 1, true)
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

		if hunger > 0:
			hunger -= delta * 10
		else:
			dead = true
			animation_player.stop()
			animated_sprite_2d.play("die")
			animation_player.play("arms_dying")
			death_timer.start()
	elif dead and can_restart:
		if Input.is_anything_pressed():
			get_tree().reload_current_scene()

	left_arm.rotation /= 1 + arm_down_speed*delta
	right_arm.rotation /= 1 + arm_down_speed*delta


func _on_head_area_entered(area):
	if area.has_meta("edible"):
		area.queue_free()
		hunger += area.get_meta("nutrients")
		eating = true
		animated_sprite_2d.play("eating")
		Engine.time_scale = 0.5
		eating_timer.start()
	else:
		for child in area.get_child(2).get_children():
			if child.get_meta("edible"):
				area.get_child(2).remove_child(child)
				if area.has_meta("nutrients"):
					hunger += area.get_meta("nutrients")
				eating = true
				animated_sprite_2d.play("eating")
				Engine.time_scale = 0.5
				eating_timer.start()

func _on_eating_timer_timeout():
	eating_particles.emitting = true
	eating = false
	Engine.time_scale = 1


func _on_death_timer_timeout():
	death.emit()
	can_restart = true
