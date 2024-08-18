extends Node


enum Languages {
	English,
	Spanish
}

var spanish_flag = null
var uk_flag = null

@onready var language_button = $"Title/Language Button"
@onready var player = $Player
@onready var camera_2d = $Camera2D
@onready var hunger_meter = $"Camera2D/HUD/Hunger Meter"
@onready var player_icon = $"Camera2D/HUD/Player icon"

@onready var death_text = $"Camera2D/HUD/Death/Death Text"
@onready var death_comment = $"Camera2D/HUD/Death/Death Comment"
@onready var death_animation_player = $Camera2D/HUD/Death/AnimationPlayer

@onready var left_boundary = $"Boundaries/Left Boundary"
@onready var right_boundary = $"Boundaries/Right Boundary"
@onready var bottom_boundary = $"Boundaries/Bottom Boundary"
@onready var top_boundary = $"Boundaries/Top Boundary"

@export var language: Languages
@export var death_phrases: Dictionary
@export var transition_speed = 2.

var game_started = false
var is_fullscreen = false

var transitioning = false
var transition_metadata = {
	"zoom": Vector2(0, 0),
	"position": Vector2(0, 0)
}

var player_icons = []


func _ready():
	spanish_flag = load("res://assets/sprites/spain.png")
	uk_flag = load("res://assets/sprites/united_kingdom.png")

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


func toggle_language():
	if language == Languages.English:
		language = Languages.Spanish
		language_button.icon = spanish_flag
	elif language == Languages.Spanish:
		language = Languages.English
		language_button.icon = uk_flag

func _on_language_button_pressed():
	toggle_language()

func _on_title_game_start():
	game_started = true
	player.game_started = true

func _process(delta):
	if Input.is_action_just_released("toggle_fullscreen"):
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
		camera_2d.zoom = camera_2d.zoom.lerp(transition_metadata["zoom"], transition_speed*delta)
		camera_2d.position = camera_2d.position.lerp(transition_metadata["position"], transition_speed*delta)
		
		if (camera_2d.zoom == transition_metadata["zoom"])\
		and (camera_2d.position == transition_metadata["position"]):
			transitioning = false

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
	camera_coordinates
):
	left_boundary.position = border_coordinates[0]
	right_boundary.position = border_coordinates[1]
	bottom_boundary.position = border_coordinates[2]
	top_boundary.position = border_coordinates[3]
	transition_metadata["zoom"] = Vector2(camera_zoom, camera_zoom)
	transition_metadata["position"] = camera_coordinates
	transitioning = true
