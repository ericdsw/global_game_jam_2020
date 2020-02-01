extends Area2D

func _ready() -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	queue_free()
