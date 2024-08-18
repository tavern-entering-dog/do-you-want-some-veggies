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

@export var language: Languages

@export var death_phrases: Dictionary

var game_started = false
var is_fullscreen = false

var player_icons = []

func _ready():
	spanish_flag = load("res://assets/sprites/spain.png")
	uk_flag = load("res://assets/sprites/united_kingdom.png")

	player_icons.append(load("res://assets/sprites/player_icon_dead.png"))
	player_icons.append(load("res://assets/sprites/player_icon_bad.png"))
	player_icons.append(load("res://assets/sprites/player_icon_ok.png"))	
	player_icons.append(load("res://assets/sprites/player_icon_perfect.png"))


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

func _process(_delta):
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

	hunger_meter.value = player.hunger
	player_icon.texture = player_icons[ceil(3*player.hunger/player.max_hunger)]

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
