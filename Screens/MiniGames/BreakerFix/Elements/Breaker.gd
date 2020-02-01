extends Control

onready var animation_player := get_node("AnimationPlayer") as AnimationPlayer

var _correct := true

signal changed(correct)

func set_correct() -> void:
	_correct = true
	animation_player.play("correct")
	emit_signal("changed", _correct)

func set_incorrect() -> void:
	_correct = false
	animation_player.playback_speed = rand_range(0.9, 1.2)
	animation_player.play("incorrect")
	emit_signal("changed", _correct)

func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("BreakerClickArea"):
		if !_correct:
			set_correct()
		else:
			set_incorrect()
