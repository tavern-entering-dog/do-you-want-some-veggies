extends Node


enum Languages {
	English,
	Spanish
}

@onready var language_button = $"Title/Language Button"

@export var language: Languages


func _on_language_button_pressed():
	if language == Languages.English:
		language = Languages.Spanish
		language_button.icon = load("res://assets/sprites/spain.png")
	elif language == Languages.Spanish:
		language = Languages.English
		language_button.icon = load("res://assets/sprites/united_kingdom.png")


func _on_title_game_start():
	pass # Replace with function body.
