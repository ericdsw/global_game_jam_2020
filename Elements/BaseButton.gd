extends Button

func _on_BaseButton_pressed() -> void:
	$AnimationPlayer.play("pressed")
