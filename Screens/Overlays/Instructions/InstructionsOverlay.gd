extends BaseOverlay
class_name InstructionsOverlay

onready var label := get_node("Label")

func show_instruction(instruction_string: String) -> void:
	label.text = instruction_string
