extends Button
class_name MarriageButton

signal displayed()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "enter":
		emit_signal("displayed")
