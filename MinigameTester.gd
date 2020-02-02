extends Node2D

export (String, FILE) var minigame_to_test := ""
export (int) var target_difficulty := 1

var _success_res := preload("res://Screens/Overlays/Finish/Success.tscn")
var _failure_res := preload("res://Screens/Overlays/Finish/Failure.tscn")
var _instruction_res := preload("res://Screens/Overlays/Instructions/InstructionsOverlay.tscn")

var _cur_minigame

onready var timer := get_node("Timer") as Timer
onready var overlay_node := get_node("OverlayNode") as Node2D

func _ready() -> void:
	
	var _minigame = load(minigame_to_test).instance()
	_minigame.connect("success", self, "_on_success")
	_minigame.connect("failure", self, "_on_failure")
	_minigame.connect("request_next", self, "_on_next_requested")
	_minigame.connect("request_shake", self, "_on_minigame_requested_shake")
	
	_cur_minigame = _minigame
	
	var _instructions = _instruction_res.instance()
	overlay_node.add_child(_instructions)
	if _minigame.instructions == "":
		_instructions.show_instruction("Fix it!")
	else:
		_instructions.show_instruction(_minigame.instructions)
	
	yield(_instructions, "peaked")
	add_child(_minigame)
	
	yield(_instructions, "finished")
	_minigame.start(target_difficulty)

func _on_success(time_left: float) -> void:
	if !_cur_minigame.no_overlay_for_success:
		var _success_ins = _success_res.instance()
		overlay_node.add_child(_success_ins)

func _on_failure() -> void:
	if !_cur_minigame.no_overlay_for_fail:
		var _failure_ins = _failure_res.instance()
		overlay_node.add_child(_failure_ins)

func _on_next_requested() -> void:
	print("requested next")

func _on_minigame_requested_shake(intensity: float, duration: float) -> void:
	get_node("Camera2D").shake(intensity, duration)
