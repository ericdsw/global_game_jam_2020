extends BaseOverlay
class_name InstructionsOverlay

onready var label := get_node("Label")

func show_instruction(instruction_string: String) -> void:
	label.text = instruction_string

func _start_display_logic() -> void:
	
	# Try to play th enter animaton if defined
	if enter_animation != "":
		if enter_exit_anim_p.has_animation(enter_animation):
			enter_exit_anim_p.play(enter_animation)
			return
		else:
			print("Enter animation not found on the animation player, using tween fallback...")

	# Move the overlay to the active position and fade in from transparent
	
	yield(get_tree().create_timer(0.1), "timeout")
	emit_signal("peaked")
	rect_position = IN_POS + _direction
	modulate.a = 1.0
	_fully_displayed()
	
#	tween.interpolate_property(
#		self, "rect_position", IN_POS + _direction * 1000.0, IN_POS, 0.2, 
#		Tween.TRANS_SINE, Tween.EASE_IN_OUT
#	)
#	tween.interpolate_property(
#		self, "modulate:a", 0.0, 1.0, 0.2,
#		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
#	)
#	tween.start()
