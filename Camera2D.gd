extends Camera2D

onready var timer := get_node("Timer") as Timer

var _shake_intensity := 0.0

func _process(delta: float) -> void:
	randomize()
	offset = Vector2(
		rand_range(-1.0, 1.0) * _shake_intensity,
		rand_range(-1.0, 1.0) * _shake_intensity
	)

func shake(intensity : float, duration : float) -> void:
	_shake_intensity = intensity
	timer.stop()
	timer.start(duration)

func _on_Timer_timeout() -> void:
	_shake_intensity = 0.0
