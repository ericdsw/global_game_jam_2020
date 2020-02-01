extends Node2D
class_name BaseMinigame

export (float) var duration := 1.0
export (String) var instructions := ""

onready var deadline_timer := get_node("DeadlineTimer") as Timer

signal success(time_left)
signal failure()

func start(difficulty := 1.0) -> void:
	deadline_timer.wait_time = duration
	deadline_timer.start()

func on_success() -> void:
	deadline_timer.stop()
	emit_signal("success", deadline_timer.time_left)

func on_failure() -> void:
	deadline_timer.stop()
	emit_signal("failure")

func _on_DeadlineTimer_timeout() -> void:
	on_failure()
