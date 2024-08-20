extends Node


enum Languages {
	English,
	Spanish
}

@onready var scene_1 = $"../Edibles/Scene 1"
@onready var scene_2 = $"../Edibles/Scene 2"
@onready var scene_3 = $"../Edibles/Scene 3"
@onready var scene_4 = $"../Edibles/Scene 4"
@onready var scene_5 = $"../Edibles/Scene 5"

@onready var pause_text = $"../Camera2D/Pause Stuff/Pause Text"
@onready var animation_player = $"../Camera2D/Pause Stuff/AnimationPlayer"

@onready var player = $"../Player"

@export var scene_number: int
@export var transitioning: bool
@export var scene_spawn_time: Array
@export var enemy_list: Array

@export var language: Languages

@export var game_started = false
@export var dead = false

var handlers = []
var timers = []

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

func _process(delta):
	if Input.is_action_just_pressed("pause") and game_started and not dead:
		pause_text.text = 'Juego Pausado' if language == Languages.Spanish else 'Game Paused'
		match get_tree().paused:
			true:
				get_tree().paused = false
				animation_player.play("move_back")
			false:
				get_tree().paused = true
				animation_player.play("pause_text_move")

	if scene_number == 3:
		for child in scene_4.get_children():
			child.set_meta("player_position", player.position)

func object_handler(idx):
	return func inner():
		var instance = enemy_list[scene_number][idx].instantiate()
		instance.set_meta("player_position", player.position)
		get_scene_from_number(scene_number).add_child(instance)
		timers[idx].start()

func _on_player_next_scene(number, _1, _2, _3, _4, _5):
	for child in get_children():
		remove_child(child)
	timers = []
	handlers = []
	get_scene_from_number(number-1).queue_free()
	if number == 5:
		return
	for i in len(enemy_list[number]):
		if i % 2 == 0:
			var instance = enemy_list[scene_number][i].instantiate()
			instance.set_meta("player_position", player.position)
			get_scene_from_number(scene_number).add_child(instance)
		var new_handler = object_handler(i)
		handlers.append(new_handler)
		var new_timer = Timer.new()
		new_timer.one_shot = true
		new_timer.wait_time = randf_range(
			scene_spawn_time[number][i].x,
			scene_spawn_time[number][i].y
		)
		new_timer.connect("timeout", handlers[len(handlers)-1])
		timers.append(new_timer)
		add_child(timers[len(timers)-1])
		timers[len(timers)-1].start()
