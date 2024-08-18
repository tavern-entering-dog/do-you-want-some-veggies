extends Node2D


enum OrientationType {
	Left,
	Right
}

@export var orientation: OrientationType = OrientationType.Right

@onready var sprite_2d = $Sprite2D
@onready var hand = $Hand

func _ready():
	sprite_2d.flip_h = true if orientation == OrientationType.Left else false

func _on_area_entered(area):
	if area.has_meta('arm') or area.get_parent().get_parent().has_meta('arm'):
		return
	if area.has_meta('edible'):
		hand.call_deferred("add_child", area.duplicate())
		area.queue_free()
