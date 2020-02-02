extends Button

func _on_BaseButton_pressed() -> void:
	$AnimationPlayer.play("pressed")
	$ClickButton.play()


func _on_BaseButton_mouse_entered():
	$ButtonHover.play()
	pass # Replace with function body.
