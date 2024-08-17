extends Node


enum Languages {
	English,
	Spanish
}

@onready var language_button = $"Title/Language Button"
@onready var player = $Player

@export var language: Languages

var game_started = false


func toggle_language():
	if language == Languages.English:
		language = Languages.Spanish
		language_button.icon = load("res://assets/sprites/spain.png")
	elif language == Languages.Spanish:
		language = Languages.English
		language_button.icon = load("res://assets/sprites/united_kingdom.png")

func _on_language_button_pressed():
	toggle_language()

func _on_title_game_start():
	game_started = true
	player.game_started = true

func _process(_delta):
	if Input.is_action_pressed("change_lang"):
		toggle_language()
