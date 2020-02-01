extends Control
class_name BaseOverlay

# Starting position. Since control nodes have their `rect_position` defined in the
# top left corner, we need to offset them by half their size in order to center them
const IN_POS := Vector2(-512.0, -300.0)

# Possible movement types, which can be used to define enter and exit directions
enum EnterTypes {
	Up, Down, Left, Right, None
}

# Direction that the overlay will use to enter
export (EnterTypes) var enter_type := EnterTypes.Left

# Direction that the overlay will use to exit
export (EnterTypes) var exit_type := EnterTypes.Left

onready var life_timer := get_node("LifeTimer") as Timer
onready var tween := get_node("Tween")

# Enter and exit directions. Note that an empty vector will apply no movement, and
# only the alpha animation will play
var _direction := Vector2()
var _exit_direction := Vector2()

signal peaked()
signal finished()

# ================================ Lifecycle ================================ #

func _ready() -> void:
	
	_decide_direction()
	
	modulate.a = 0.0
	
	# Move the overlay to the active position and fade in from transparent
	tween.interpolate_property(
		self, "rect_position", IN_POS + _direction * 1000.0, IN_POS, 0.4, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	tween.interpolate_property(
		self, "modulate:a", 0.0, 1.0, 0.4,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	tween.start()

# ================================= Private ================================= #

# Assigns the required vector enter and exit direction, depending on what is
# defined in the exported properties
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

# ================================ Callbacks ================================ #

# Connected via UI
func _on_Tween_tween_all_completed() -> void:
	# When alpha is maxed (1.0), the overlay just finished showing
	if modulate.a == 1.0:
		life_timer.start()
		emit_signal("peaked")
	# Otherwise, we can assume that the overlay just finished hiding
	else:
		emit_signal("finished")
		queue_free()

# Connected via UI
func _on_LifeTimer_timeout() -> void:
	# Move the overlay to the final position and fade to transparent
	tween.interpolate_property(
		self, "rect_position", IN_POS, IN_POS + _exit_direction * 1000.0, 0.4, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	tween.interpolate_property(
		self, "modulate:a", 1.0, 0.0, 0.4,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	tween.start()
