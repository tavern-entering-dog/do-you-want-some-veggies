extends Node2D


enum OrientationType {
	Left,
	Right
}

@export var orientation: OrientationType = OrientationType.Right
@export var eating = false
@export var player_size = 1

@onready var sprite_2d = $Sprite2D
@onready var hand = $Hand

func _ready():
	sprite_2d.flip_h = true if orientation == OrientationType.Left else false

func _on_area_entered(area):
	if area.has_meta('arm')\
	or area.get_parent().get_parent().has_meta('arm')\
	or len(hand.get_children()) != 0\
	or eating:
		return
	if area.has_meta('edible'):
		var previous_scale = area.scale
		var new_child = area.duplicate()
		new_child.scale *= Vector2(1/(player_size*1.25), 1/(player_size*1.25))
		new_child.position = Vector2(0, 0)
		new_child.z_index = 0
		new_child.set_meta("grabbed", true)
		hand.call_deferred("add_child", new_child)
		area.queue_free()
