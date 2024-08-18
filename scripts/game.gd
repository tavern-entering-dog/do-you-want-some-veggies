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

@export var language: Languages

var game_started = false
var is_fullscreen = false

var hunger = 100

func _ready():
	spanish_flag = load("res://assets/sprites/spain.png")
	uk_flag = load("res://assets/sprites/united_kingdom.png")
	

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

	if player:
		hunger_meter.value = player.hunger
