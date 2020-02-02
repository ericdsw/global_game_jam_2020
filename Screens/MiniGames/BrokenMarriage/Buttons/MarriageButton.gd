extends Button
class_name MarriageButton

signal displayed()

onready var animation_player := get_node("AnimationPlayer") as AnimationPlayer

func request_fade_out() -> void:
	animation_player.play("exit")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "enter":
		emit_signal("displayed")
