extends Node


enum Languages {
	English,
	Spanish
}

var spanish_flag = null
var uk_flag = null

@onready var game_manager = $"Game Manager"

@onready var language_button = $"Title/Language Button"
@onready var player = $Player
@onready var camera_2d = $Camera2D
@onready var hunger_meter = $"Camera2D/HUD/Hunger Meter"
@onready var player_icon = $"Camera2D/HUD/Player icon"
@onready var height_text = $"Camera2D/HUD/Height Text"
@onready var animation_player = $Camera2D/HUD/AnimationPlayer
@onready var hud = $Camera2D/HUD

@onready var death_text = $"Camera2D/HUD/Death/Death Text"
@onready var death_comment = $"Camera2D/HUD/Death/Death Comment"
@onready var death_animation_player = $Camera2D/HUD/Death/AnimationPlayer
@onready var roof = $"Background/Scene 3/Scene 3 Foreground/Roof"
@onready var roof_animation = $"Background/Scene 3/Scene 3 Foreground/Roof/Roof Animation"
@onready var break_particles = $"Background/Scene 3/Scene 3 Foreground/Roof/Break Particles"
@onready var scene_4_animated_sprite_2d = $"Background/Scene 4/AnimatedSprite2D"
@onready var scene_4_alien = $"Background/Scene 4/Alien"

@onready var left_boundary = $"Boundaries/Left Boundary"
@onready var right_boundary = $"Boundaries/Right Boundary"
@onready var bottom_boundary = $"Boundaries/Bottom Boundary"
@onready var top_boundary = $"Boundaries/Top Boundary"

@onready var scene_1_music = $"Music/Scene 1 Song"
@onready var scene_2_music = $"Music/Scene 2 Song"
@onready var scene_3_music = $"Music/Scene 3 Song"
@onready var scene_3_sound = $"Music/Scene 3 Sound"
@onready var scene_4_music = $"Music/Scene 4 Song"
@onready var scene_5_music = $"Music/Scene 5 Song"
@onready var scene_6_music = $"Music/Scene 6 Song"

@onready var language_manager = $"/root/LanguageManager"

@export var language: Languages
@export var death_phrases: Dictionary
@export var transition_speed = 2.

@export var debug: bool = true
var camera_move_time_held: float
var nop_iterations = 0

var game_started = false
var is_fullscreen = false

var transitioning = false
var transition_metadata = {
	"number": 0,
	"zoom": Vector2(0, 0),
	"position": Vector2(0, 0)
}
var roof_broken = false

var player_icons = []


func scene_song(scene_number: int):
	match scene_number:
		0:
			return scene_1_music
		1: 
			return scene_2_music
		2:
			return scene_3_music
		3:
			return scene_4_music
		4:
			return scene_5_music
		5:
			return scene_6_music

func _ready():
	scene_1_music.volume_db = 0
	scene_2_music.volume_db = -80
	scene_3_sound.volume_db = -80
	scene_3_music.volume_db = -80
	scene_4_music.volume_db = -80
	scene_5_music.volume_db = -80

	spanish_flag = load("res://assets/sprites/spain.png")
	uk_flag = load("res://assets/sprites/united_kingdom.png")
	
	if language_manager.get_meta("english"):
		language = Languages.English
		language_button.icon = uk_flag
	else:
		language = Languages.Spanish
		language_button.icon = spanish_flag

	player_icons.append(load("res://assets/sprites/player_icon_dead.png"))
	player_icons.append(load("res://assets/sprites/player_icon_bad.png"))
	player_icons.append(load("res://assets/sprites/player_icon_ok.png"))
	player_icons.append(load("res://assets/sprites/player_icon_perfect.png"))
	
	left_boundary.position = player.scene_data[0]["border_coordinates"][0]
	right_boundary.position = player.scene_data[0]["border_coordinates"][1]
	bottom_boundary.position = player.scene_data[0]["border_coordinates"][2]
	top_boundary.position = player.scene_data[0]["border_coordinates"][3]
	
	camera_2d.position = player.scene_data[0]["camera_coordinates"]
	var _zoom = player.scene_data[0]["camera_zoom"]
	camera_2d.zoom = Vector2(_zoom, _zoom)
	
	player.debug = debug


func toggle_language():
	if language == Languages.English:
		language = Languages.Spanish
		language_button.icon = spanish_flag
		language_manager.set_meta("english", false)
		game_manager.language = Languages.Spanish
	elif language == Languages.Spanish:
		language = Languages.English
		language_button.icon = uk_flag
		language_manager.set_meta("english", true)
		game_manager.language = Languages.English

func _on_language_button_pressed():
	toggle_language()

func _on_title_game_start():
	game_started = true
	player.game_started = true
	animation_player.play("start")
	height_text.text = ("Height: " + player.scene_data[0]["height"] if language == Languages.English
					else "Altura: " + player.scene_data[0]["height"])

func _process(delta):
	if debug:
		if Input.is_action_pressed("zoom_out"):
			camera_move_time_held = 0
			camera_2d.zoom -= Vector2(0.5*delta, 0.5*delta)
		if Input.is_action_pressed("zoom_in"):
			camera_move_time_held = 0
			camera_2d.zoom += Vector2(0.5*delta, 0.5*delta)
		if Input.is_action_pressed("camera_up"):
			nop_iterations = 0
			camera_move_time_held += delta
			camera_2d.position -= Vector2(0, 100*delta + 20*camera_move_time_held)
		if Input.is_action_pressed("camera_down"):
			nop_iterations = 0
			camera_move_time_held += delta
			camera_2d.position += Vector2(0, 100*delta + 20*camera_move_time_held)
		else:
			nop_iterations += 1
			if nop_iterations >= 3:
				camera_move_time_held = 0
			else:
				camera_move_time_held += delta

	if Input.is_action_just_pressed("toggle_fullscreen"):
		is_fullscreen = not is_fullscreen
		if is_fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)  

	if not game_started\
	   and Input.is_action_just_pressed("change_lang")\
	   and language_button:
			toggle_language()

	if transitioning:
		if player.scale.y >= 20:
			get_tree().change_scene_to_file("res://scenes/credits.tscn")

		camera_2d.zoom = camera_2d.zoom.lerp(transition_metadata["zoom"], transition_speed*delta)
		camera_2d.position = camera_2d.position.lerp(transition_metadata["position"], transition_speed*delta)

		scene_song(transition_metadata["number"]).volume_db =\
			scene_song(transition_metadata["number"]).volume_db * (1 - 3*delta)

		scene_song(transition_metadata["number"]-1).volume_db =\
			scene_song(transition_metadata["number"]-1).volume_db\
			- delta*(80 + scene_song(transition_metadata["number"]-1).volume_db)

		if (camera_2d.zoom == transition_metadata["zoom"])\
		and (camera_2d.position == transition_metadata["position"]):
			transitioning = false

		if (transition_metadata["number"] == 2) and (player.scale.y >= 4) and not roof_broken:
			roof.play("destroy")
			break_particles.emitting = true
			roof_broken = true
			hud.add_child(load("res://scenes/crt_screen_shader.tscn").instantiate())

		if (transition_metadata["number"] == 3) and (player.scale.y >= 8):
			for child in hud.get_children():
				if child.name == "CRT Screen Shader":
					child.queue_free()

		if (transition_metadata["number"] == 4):
			scene_4_animated_sprite_2d.modulate.a =\
				scene_4_animated_sprite_2d.modulate.a * (1 - 10*delta)
			scene_4_alien.modulate.a =\
				scene_4_alien.modulate.a * (1 - 10*delta)

		if transition_metadata["number"] >= 3:
			player.gravity = 0

	hunger_meter.value = player.hunger
	player_icon.texture = player_icons[min(ceil(3*player.hunger/player.scene_data[player.current_scene]["max_hunger"]), 3)]

func _on_player_death():
	if language == Languages.English:
		death_text.text = "You Starved to Death"
		death_comment.text = death_phrases["english"]\
			[randi() % len(death_phrases["english"])]
	elif language == Languages.Spanish:
		death_text.text = "Te Moriste de Hambre"
		death_comment.text = death_phrases["spanish"]\
			[randi() % len(death_phrases["spanish"])]
	death_animation_player.play("death_message_show")


func _on_player_next_scene(
	number,
	camera_zoom,
	border_coordinates,
	camera_coordinates,
	height,
	max_hunger
):
	game_manager.scene_number = number
	left_boundary.position = border_coordinates[0]
	right_boundary.position = border_coordinates[1]
	bottom_boundary.position = border_coordinates[2]
	top_boundary.position = border_coordinates[3]
	height_text.text = ("Height: " + height if language == Languages.English
						else "Altura: " + height)
	scene_song(number).playing = true

	if number == 2:
		roof_animation.play("appear")

	transition_metadata["number"] = number
	transition_metadata["zoom"] = Vector2(camera_zoom, camera_zoom)
	transition_metadata["position"] = camera_coordinates
	transitioning = true
