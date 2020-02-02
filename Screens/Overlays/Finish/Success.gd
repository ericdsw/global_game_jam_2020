extends BaseOverlay

func _start_disappearing_logic() -> void:
	emit_signal("finished")
	yield(get_tree().create_timer(0.4), "timeout")
	._start_disappearing_logic()

func _disappeared() -> void:
	queue_free()
