extends CanvasLayer


signal game_start

@onready var title_text = $"Title Text"
@onready var title_background = $"Title Background"
@onready var language_button = $"Language Button"
@onready var title = $"."

@export var title_movement_velocity = 1
@export var title_movement_height = 1

var base_title_position = 0
var time_elapsed = 0
var title_screen = true

func periodic_sigmoid(h: float, k: float, t: float) -> float:
	return h/(1+exp(-sin(k*t))) - h/2

func _ready():
	base_title_position = title_text.position.y
	title_background.modulate.a = 0.5

func _process(delta):
	if title_screen:
		time_elapsed += delta
		title_text.position.y = base_title_position +\
			periodic_sigmoid(
				title_movement_height,
				title_movement_velocity,
				time_elapsed
			)
	else:
		if not title_background.modulate.a == 0:
			title_background.modulate.a = max(title_background.modulate.a - delta/2, 0)
			return
		game_start.emit()
		title.queue_free()

func _input(event):
	if (event is InputEventKey and event.pressed)\
	or (event is InputEventJoypadButton and event.pressed)\
	or (Input.get_axis("move_left", "move_right") != 0)\
	or (Input.get_axis("left_joystick_down", "left_joystick_up") != 0)\
	or (Input.get_axis("left_joystick_left", "left_joystick_right") != 0)\
	or (Input.get_axis("right_joystick_down", "right_joystick_up") != 0)\
	or (Input.get_axis("right_joystick_left", "right_joystick_right") != 0):
		title_text.get_child(0).play('move')
		language_button.disabled = true
		language_button.get_child(0).play('move')
		title_screen = false
