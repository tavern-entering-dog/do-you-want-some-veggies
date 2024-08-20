extends CharacterBody2D


signal death
signal next_scene(
	number: int,
	camera_zoom: float,
	border_coordinates: Array,
	camera_coordinates: Vector2,
	height: int,
	max_hunger: int
)

@onready var animated_sprite_2d = $AnimatedSprite2D

@onready var left_arm = $"Left Arm"
@onready var right_arm = $"Right Arm"
@onready var eating_timer = $"Eating Timer"
@onready var death_timer = $"Death Timer"
@onready var revive_timer = $"Revive Timer"
@onready var eating_particles = $"Eating Particles"
@onready var animation_player = $AnimationPlayer

@onready var jump_sound = $"SFX/Jump Sound"
@onready var eating_sound = $"SFX/Eating Sound"
@onready var hurt_sound = $"SFX/Hurt Sound"
@onready var propulsion_sound = $"SFX/Propulsion Sound"
@onready var growing_sound = $"SFX/Growing Sound"

@onready var game_manager = $"../Game Manager"

var left_arm_position = Vector2(0, 0)
var right_arm_position = Vector2(0, 0)

@export var speed = 300.0
@export var jump_velocity = -450.0
@export var arm_down_speed = 1
@export var transition_speed = 2.

@export var hunger = 0
@export var debug = false

var game_started = false
var eating = false
var dead = false
var can_restart = false

var transitioning = false
var transition_metadata = {}

var time_elapsed = 0
var time_start = 0

@export var scene_data = [
	{
		"metabolism_speed": 0,
		"max_hunger": 100,
		"target_player_size": 1,
		"target_player_y_position": 70,
		"camera_zoom": 1,
		"camera_coordinates": Vector2(0, 0),
		"border_coordinates": [
			Vector2(-550, 0),
			Vector2(550, 0),
			Vector2(0, 253),
			Vector2(0, -325)
		],
		"height": "1m 62cm",
		"jump_velocity": jump_velocity,
		"speed": speed
	},
	{
		"metabolism_speed": 10,
		"max_hunger": 250,
		"target_player_size": 3,
		"target_player_y_position": -290,
		"camera_zoom": 0.5,
		"camera_coordinates": Vector2(25, -325),
		"border_coordinates": [
			Vector2(-1100, 0),
			Vector2(1100, 0),
			Vector2(0, 253),
			Vector2(0, -950)
		],
		"height": "6m 10cm",
		"jump_velocity": -1000.0,
		"speed": 600.0
	},
	{
		"metabolism_speed": 25,
		"max_hunger": 550,
		"target_player_size": 12,
		"target_player_y_position": -1750,
		"camera_zoom": 0.125,
		"camera_coordinates": Vector2(153, -1932),
		"border_coordinates": [
			Vector2(-4200, 0),
			Vector2(4500, 0),
			Vector2(0, 253),
			Vector2(0, -4500)
		],
		"height": "350m",
		"jump_velocity": -6000.0,
		"speed": 1000.0
	},
	{
		"metabolism_speed": 35,
		"max_hunger": 750,
		"target_player_size": 15,
		"target_player_y_position": -7750,
		"camera_zoom": 0.056,
		"camera_coordinates": Vector2(0, -10500),
		"border_coordinates": [
			Vector2(-9500, -10000),
			Vector2(9500, -10000),
			Vector2(0, -5600),
			Vector2(0, -16000)
		],
		"height": "89000m",
		"jump_velocity": -6000.0,
		"speed": 4000.0
	},
	{
		"metabolism_speed": 50,
		"max_hunger": 1250,
		"target_player_size": 17,
		"target_player_y_position": -9000,
		"camera_zoom": 0.07,
		"camera_coordinates": Vector2(0, -10500),
		"border_coordinates": [
			Vector2(-7000, 0),
			Vector2(7000, 0),
			Vector2(0, -6300),
			Vector2(0, -14500)
		],
		"height": "∞",
		"jump_velocity": -5500.0,
		"speed": 3750.0
	},
	{
		"metabolism_speed": 50,
		"max_hunger": 1250,
		"target_player_size": 25,
		"target_player_y_position": -9000,
		"camera_zoom": 0.1,
		"camera_coordinates": Vector2(0, -10500),
		"border_coordinates": [
			Vector2(-7000, 0),
			Vector2(7000, 0),
			Vector2(0, -6300),
			Vector2(0, -14500)
		],
		"height": "∞",
		"jump_velocity": -5500.0,
		"speed": 3750.0
	},
]
var current_scene = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func rumble(weak, strong, duration):
	#for device in Input.get_connected_joypads():
		#Input.start_joy_vibration(device, weak, strong, duration)

	pass # Apparently not working on Godot right now?

func _ready():
	left_arm_position = left_arm.position
	left_arm.rotation = 0
	right_arm_position = right_arm.position
	right_arm.rotation = 0
	eating_particles.process_material.scale_min = 1.75
	eating_particles.process_material.scale_max = 2.25

func _physics_process(delta):
	if debug:
		if Input.is_action_just_pressed("debug_eat"):
			hunger += 25
			eating = true
			if not animated_sprite_2d.animation == 'hurt':
				animated_sprite_2d.play("eating")
			Engine.time_scale = 0.5
			eating_timer.start()

	if time_elapsed < .5:
		time_elapsed += delta
	elif game_started and not eating and not dead and not transitioning:
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
			if not animated_sprite_2d.animation == 'hurt':
				animated_sprite_2d.play("idle")
			if not animation_player.is_playing():
				animation_player.play("arms_idle", -1, 1, true)
			if current_scene < 3:
				velocity.x = move_toward(velocity.x, 0, speed)

		if Input.is_action_pressed("left_click"):
			var mouse_distance_vector = get_global_mouse_position()\
				- left_arm.position
			left_arm.rotation = mouse_distance_vector.angle() - PI/2
		if Input.is_action_pressed("right_click"):
			var mouse_distance_vector = get_global_mouse_position()\
				- right_arm.position
			right_arm.rotation = mouse_distance_vector.angle() - PI/2

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y += jump_velocity
			jump_sound.play()
		elif Input.is_action_pressed("jump") and current_scene >= 3:
			velocity.y += jump_velocity*delta*2
			if not propulsion_sound.playing:
				propulsion_sound.play()
		if Input.is_action_just_pressed("descend") and is_on_floor():
			velocity.y -= jump_velocity
		elif Input.is_action_pressed("descend") and current_scene >= 3:
			velocity.y -= jump_velocity*delta*2

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

		if hunger >= 0:
			hunger -= delta * scene_data[current_scene]["metabolism_speed"]
		else:
			hurt_sound.play()
			dead = true
			game_manager.dead = true
			eating = false
			Engine.time_scale = 1
			animation_player.stop()
			animated_sprite_2d.play("die")
			animation_player.play("arms_dying")
			death_timer.start()
	elif dead and can_restart:
		if Input.is_anything_pressed():
			get_tree().reload_current_scene()
	elif transitioning:
		position = position.lerp(Vector2(
			position.x,
			transition_metadata["y_position"]
		), transition_speed*delta)
		var _size = transition_metadata["size"]
		scale = scale.lerp(Vector2(_size, _size), transition_speed*delta)
		left_arm.player_size = scale.y
		right_arm.player_size = scale.y
		if (abs(position.y - transition_metadata["y_position"]) < abs(transition_metadata["y_position"]/100.))\
		and (abs(scale.x - transition_metadata["size"]) < abs(transition_metadata["size"]/100.)):
			transitioning = false
			#for device in Input.get_connected_joypads():
				#Input.stop_joy_vibration(device)
			game_manager.transitioning = false
			
	elif (eating and current_scene < 3 and is_on_floor()) or (dead and current_scene < 3):
		velocity.x = 0

	if not transitioning:
		left_arm.rotation /= 1 + arm_down_speed*delta
		right_arm.rotation /= 1 + arm_down_speed*delta

		if not is_on_floor():
			velocity.y += gravity * delta
			if game_started and velocity.y != 0 and not dead and not eating:
				if velocity.y < 0:
					animated_sprite_2d.play("jumping")
				elif velocity.y > 0:
					animated_sprite_2d.play("descending")
		move_and_slide()

func eat(area):
	if area.has_meta("nutrients"):
		hunger += area.get_meta("nutrients")
	eating = true
	left_arm.eating = true
	right_arm.eating = true
	animated_sprite_2d.play("eating")
	eating_sound.play()
	Engine.time_scale = 0.75
	eating_timer.start()

func _on_head_area_entered(area):
	if area == $"Collision Detection Area":
		return
	if area.has_meta("edible") and area.get_meta("edible"):
		return
	else:
		for child in area.get_child(2).get_children():
			if child.has_meta("edible") and child.get_meta("edible"):
				eat(child)
				area.get_child(2).remove_child(child)

func _on_eating_timer_timeout():
	eating_particles.emitting = true
	eating = false
	left_arm.eating = false
	right_arm.eating = false
	Engine.time_scale = 1
	if hunger >= scene_data[current_scene]["max_hunger"]:
		current_scene += 1
		next_scene.emit(current_scene,
			scene_data[current_scene]["camera_zoom"],
			scene_data[current_scene]["border_coordinates"],
			scene_data[current_scene]["camera_coordinates"],
			scene_data[current_scene]["height"],
			scene_data[current_scene]["max_hunger"]
		)
		speed = scene_data[current_scene]["speed"]
		jump_velocity = scene_data[current_scene]["jump_velocity"]
		growing_sound.play()
		rumble(current_scene/6., current_scene/6., 0)
		transitioning = true
		game_manager.transitioning = true
		transition_metadata["y_position"] = scene_data[current_scene]["target_player_y_position"]
		transition_metadata["size"] = scene_data[current_scene]["target_player_size"]
		gravity *= transition_metadata["size"]
		eating_particles.emitting = false
		eating_particles.process_material.scale_min += transition_metadata["size"]
		eating_particles.process_material.scale_max += transition_metadata["size"]


func _on_death_timer_timeout():
	death.emit()
	revive_timer.start()

func _on_revive_timer_timeout():
	can_restart = true

func _on_collision_detection_area_area_entered(area):
	if dead or transitioning:
		return
	if area.get_parent().name == 'Hand':
		return
	var subtracted_hunger = area.get_meta("damage", 0)
	if subtracted_hunger == 0:
		return
	hunger -= subtracted_hunger
	animated_sprite_2d.play("hurt")
	hurt_sound.play()

func _on_collision_detection_area_area_exited(area):
	if dead or transitioning or eating:
		return
