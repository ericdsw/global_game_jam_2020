extends Node2D
class_name BaseMinigame

export (float) var duration := 1.0
export (String) var instructions := ""

onready var deadline_timer := get_node("DeadlineTimer") as Timer

# Use this variable to decide any custom logic based on difficulty
var _assigned_difficulty : int = 1

signal success(time_left)
signal failure()

# ================================= Public ================================== #

# Starts the minigame execution. Note that, rather than using `_ready` as our
# initialization method, we are using a custom `start` method that will be called
# by the game manager. This is because a minigame can be added to the tree before
# the player can interact with it (behind the instructions overlay, which will
# hide the change between minigames). Initialization logic should be defined here
# un subsequent subclasses.
func start(difficulty := 1) -> void:

	_assigned_difficulty = difficulty

	deadline_timer.wait_time = duration
	deadline_timer.start()

# Call this method when a minigame is completed successfully, will emit the
# required signal and stop the deadline timer
func on_success() -> void:
	deadline_timer.stop()
	emit_signal("success", deadline_timer.time_left)

# Call this methid if the minigame's fail condition is met. Note that this method
# will be automatically called when the deadline timer runs out, so subclasses
# are not required to call it directly
func on_failure() -> void:
	deadline_timer.stop()
	emit_signal("failure")

# ================================ Callbacks ================================ #

func _on_DeadlineTimer_timeout() -> void:
	on_failure()
