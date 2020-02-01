extends Control
class_name BaseOverlay

# Starting position. Since control nodes have their `rect_position` defined in the
# top left corner, we need to offset them by half their size in order to center them.
# Note: changing the game's screen size will need an adjustment to this value
const IN_POS := Vector2(-512.0, -300.0)

# Possible movement types, which can be used to define enter and exit directions
enum EnterTypes {
	Up, Down, Left, Right, None
}

# Direction that the overlay will use to enter
export (EnterTypes) var enter_type := EnterTypes.Left

# Direction that the overlay will use to exit
export (EnterTypes) var exit_type := EnterTypes.Left

# These custom animations will overwrite the enter types if defined, but must be
# first added to the AnimationPlayer
export (String) var enter_animation := ""
export (String) var exit_animation := ""

# If true, this will overwrite the lifetime, and the overlay will be visible
# Until manually hidden
export (bool) var keep_alive := false

onready var life_timer := get_node("LifeTimer") as Timer
onready var tween := get_node("Tween")
onready var enter_exit_anim_p := get_node("AnimationPlayer") as AnimationPlayer

# Enter and exit directions. Note that an empty vector will apply no movement, and
# only the alpha animation will play
var _direction := Vector2()
var _exit_direction := Vector2()

signal peaked()
signal finished()

# ================================ Lifecycle ================================ #

func _ready() -> void:
	modulate.a = 0.0
	_decide_direction()
	_start_display_logic()

# ================================= Public ================================== #

# Call this method to manually hide the overlay
func request_hide() -> void:
	life_timer.stop()
	_start_disappearing_logic()

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

func _start_display_logic() -> void:
	
	# Try to play th enter animaton if defined
	if enter_animation != "":
		if enter_exit_anim_p.has_animation(enter_animation):
			enter_exit_anim_p.play(enter_animation)
			return
		else:
			print("Enter animation not found on the animation player, using tween fallback...")

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

func _start_disappearing_logic() -> void:
	
	# Try to play the exit animation if defined
	if exit_animation != "":
		if  enter_exit_anim_p.has_animation(exit_animation):
			enter_exit_anim_p.play(exit_animation)
			return
		else:
			print("Exit animation not found on the animation player, using tween fallback...")
	
	tween.interpolate_property(
		self, "rect_position", IN_POS, IN_POS + _exit_direction * 1000.0, 0.4, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	tween.interpolate_property(
		self, "modulate:a", 1.0, 0.0, 0.4,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	tween.start()

# Called when the overlay fully entered the screen
func _fully_displayed() -> void:
	if !keep_alive:
		life_timer.start()
	emit_signal("peaked")

# Called when the overlay fully finishes hiding
func _disappeared() -> void:
	emit_signal("finished")
	queue_free()

# ================================ Callbacks ================================ #

# Connected via UI
func _on_Tween_tween_all_completed() -> void:
	# When alpha is maxed (1.0), the overlay just finished showing
	if modulate.a == 1.0:
		_fully_displayed()
	# Otherwise, we can assume that the overlay just finished hiding
	else:
		_disappeared()

# Connected via UI
func _on_LifeTimer_timeout() -> void:
	_start_disappearing_logic()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == enter_animation:
		_fully_displayed()
	elif anim_name == exit_animation:
		_disappeared()
