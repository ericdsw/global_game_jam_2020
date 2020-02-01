extends Node2D

var _max_time := 0.0

onready var hand_sprite := get_node("HandSprite") as Sprite

func set_max_time(max_time : float) -> void:
	_max_time = max_time

func display_time(time: float) -> void:
	
	var _completion_percent = time / _max_time
	var _angle = -360.0 * _completion_percent
	
	hand_sprite.rotation_degrees = _angle
