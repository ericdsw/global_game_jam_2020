extends Node2D
class_name BaseMinigame

# How much time before the task auto fails
export (float) var duration := 1.0

# The instruction text to show in the transition overlay
export (String) var instructions := ""

# Use this variable to decide any custom logic based on difficulty
var _assigned_difficulty : int = 1

# Lifetime management variables
var _lifetime := 0.0
var _is_active := false

signal success(time_left)
signal failure()

# ================================ Lifecycle ================================ #

func _process(delta: float) -> void:
	if _is_active:
		_lifetime -= delta
		if _lifetime <= 0.0:
			on_failure()

# ================================= Public ================================== #

# Starts the minigame execution. Note that, rather than using `_ready` as our
# initialization method, we are using a custom `start` method that will be called
# by the game manager. This is because a minigame can be added to the tree before
# the player can interact with it (behind the instructions overlay, which will
# hide the change between minigames). Initialization logic should be defined here
# un subsequent subclasses.
func start(difficulty := 1) -> void:

	_assigned_difficulty = difficulty
	_lifetime = duration
	_is_active = true

# Call this method when a minigame is completed successfully, will emit the
# required signal and stop the deadline timer
func on_success() -> void:
	if _is_active:
		_is_active = false
		emit_signal("success", _lifetime)

# Call this methid if the minigame's fail condition is met. Note that this method
# will be automatically called when the deadline timer runs out, so subclasses
# are not required to call it directly
func on_failure() -> void:
	_is_active = false
	emit_signal("failure")

# ================================ Callbacks ================================ #

# Connected via UI
func _on_DeadlineTimer_timeout() -> void:
	on_failure()
