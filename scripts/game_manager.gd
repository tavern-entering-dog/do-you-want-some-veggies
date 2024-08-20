extends Node


@onready var scene_1 = $"../Edibles/Scene 1"
@onready var scene_2 = $"../Edibles/Scene 2"
@onready var scene_3 = $"../Edibles/Scene 3"
@onready var scene_4 = $"../Edibles/Scene 4"
@onready var scene_5 = $"../Edibles/Scene 5"

@export var scene_number: int
@export var transitioning: bool
@export var scene_spawn_probability: Array
@export var enemy_list: Array

func get_scene_from_number(number):
	match number:
		0:
			return scene_1
		1:
			return scene_2
		2:
			return scene_3
		3:
			return scene_4
		4:
			return scene_5

func _physics_process(delta):
	var x = randf()
	if x < scene_spawn_probability[scene_number] and not transitioning:
		get_scene_from_number(scene_number).add_child(
			enemy_list[scene_number].instantiate()
		)
