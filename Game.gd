extends Node2D

var _instruction_res := load("res://Screens/Overlays/Instructions/InstructionsOverlay.tscn")
var _success_res := load("res://Screens/Overlays/Finish/Success.tscn")
var _failure_res := load("res://Screens/Overlays/Finish/Failure.tscn")

export (Array, String, FILE) var minigames := []

onready var overlay_node := get_node("OverlayNode")

var _current_minigame_offset := 0
var _cur_minigame : BaseMinigame

func _enqueue_next_minigame(_minigame: BaseMinigame) -> void:
	
	_minigame.connect("success", self, "_on_miningame_succeeded")
	_minigame.connect("failure", self, "_on_minigame_failure")
	_cur_minigame = _minigame
	
	var _instructions = _instruction_res.instance()
	overlay_node.add_child(_instructions)
	_instructions.show_instruction(_minigame.instructions)
	_instructions.connect("finished", self, "_on_instructions_finished")

	yield(_instructions, "peaked")
	add_child(_minigame)

func _start_game() -> void:
	if minigames.empty():
		print("No minigames defined")
	else:
		var _minigame := load(minigames[0]).instance() as BaseMinigame
		_enqueue_next_minigame(_minigame)

func _go_to_next_minigame() -> void:
	_current_minigame_offset += 1
	if _current_minigame_offset >= minigames.size():
		print("finished")
	else:
		_enqueue_next_minigame(load(minigames[_current_minigame_offset]).instance())

func _on_StartButton_pressed() -> void:
	_start_game()

func _on_Credits_pressed() -> void:
	pass # Replace with function body.

func _on_instructions_finished() -> void:
	_cur_minigame.start()

func _on_miningame_succeeded(_time_left: float) -> void:
	var _success_ins = _success_res.instance()
	overlay_node.add_child(_success_ins)
	yield(_success_ins, "finished")
	_go_to_next_minigame()

func _on_minigame_failure() -> void:
	var _failure_ins = _failure_res.instance()
	overlay_node.add_child(_failure_ins)
	yield(_failure_ins, "finished")
	_go_to_next_minigame()
