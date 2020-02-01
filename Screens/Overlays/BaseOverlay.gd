extends Control
class_name BaseOverlay

const IN_POS := Vector2(-512.0, -300.0)

enum EnterTypes {
	Up, Down, Left, Right, None
}

export (EnterTypes) var enter_type = EnterTypes.Left
export (EnterTypes) var exit_type = EnterTypes.Left

onready var life_timer := get_node("LifeTimer") as Timer
onready var tween := get_node("Tween")

var _direction := Vector2()
var _exit_direction := Vector2()

signal finished()
signal peaked()

func _ready() -> void:
	
	_decide_direction()
	
	modulate.a = 0.0
	
	tween.interpolate_property(
		self, "rect_position", IN_POS + _direction * 1000.0, IN_POS, 0.4, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	tween.interpolate_property(
		self, "modulate:a", 0.0, 1.0, 0.4,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	tween.start()

func _decide_direction() -> void:
	
	# Decide enter types
	match enter_type:
		EnterTypes.Up: _direction = Vector2(0, -1)
		EnterTypes.Down: _direction = Vector2(0, 1)
		EnterTypes.Left: _direction = Vector2(-1, 0)
		EnterTypes.Right: _direction = Vector2(1, 0)
		_: _direction = Vector2()
	
	# Decide exit types
	match exit_type:
		EnterTypes.Up: _exit_direction = Vector2(0, -1)
		EnterTypes.Down: _exit_direction = Vector2(0, 1)
		EnterTypes.Left: _exit_direction = Vector2(-1, 0)
		EnterTypes.Right: _exit_direction = Vector2(1, 0)
		_: _exit_direction = Vector2()

func _on_Tween_tween_all_completed() -> void:
	if modulate.a == 1.0:
		life_timer.start()
		emit_signal("peaked")
	else:
		emit_signal("finished")
		queue_free()

func _on_LifeTimer_timeout() -> void:
	tween.interpolate_property(
		self, "rect_position", IN_POS, IN_POS + _exit_direction * 1000.0, 0.4, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	tween.interpolate_property(
		self, "modulate:a", 1.0, 0.0, 0.4,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	tween.start()
