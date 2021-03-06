# The game's main execution loop will be handled by this node
extends Node2D

# These are the most commonly used overlays, so preloading them before any
# logic is defined can improve code readability
var _instruction_res := preload("res://Screens/Overlays/Instructions/InstructionsOverlay.tscn")
var _success_res := preload("res://Screens/Overlays/Finish/Success.tscn")
var _failure_res := preload("res://Screens/Overlays/Finish/Failure.tscn")
var _score_res := preload("res://Screens/Overlays/Finish/GameOverOverlay.tscn")

# Paths to all possible minigame scenes should be defined here.
export (Array, String, FILE) var minigames := []

# UI references
onready var overlay_node := get_node("OverlayNode") as Node2D
onready var main_menu_wrapper := get_node("MainMenuWrapper") as Control
onready var life_container := get_node("ContainerZFixer/LifeContainer") as LifeContainer
onready var camera := get_node("Camera2D") as Camera2D

# The current active minigame offset. This offset will be used to decide which
# scene path inside the `minigames` array should be used to instance the next 
# minigame
var _current_minigame_offset := 0 

# The current score
var _score := 0

# How many lives the player has
var _lives := 3

# The current active minigame instance
var _cur_minigame : BaseMinigame

var _reserved_minigames := []

# Forgive me lord
var _enqueued_success = false

func _ready() -> void:
	life_container.hide()

# ================================= Private ================================= #

# If there is at least one minigame defined in the "minigames" array, start the
# game, otherwise just show an error to the console.
func _start_game() -> void:
	if minigames.empty():
		# Fallback error when no minigames are defined. This should tecnhically
		# never happen.
		print("No minigames defined")
	else:
		
		_inject_new_minigame_set()
		# Reset the score
		_score = 0

		# Enqueue the first minigame without calling `_go_to_next_offset()` to
		# start the game.
		var _first_minigame := load(_reserved_minigames[0]).instance() as BaseMinigame
		_enqueue_minigame(_first_minigame)

# Moves the current active minigame offset to the next position if there are any
# non-executed minigames left, and enqueues the required instance as the `_cur_minigame`
func _go_to_next_minigame() -> void:
	_current_minigame_offset += 1
	if _current_minigame_offset >= _reserved_minigames.size():
		_inject_new_minigame_set()
	
	var _minigame_scene := load(_reserved_minigames[_current_minigame_offset]) as PackedScene
	var _minigame := _minigame_scene.instance() as BaseMinigame
	_enqueue_minigame(_minigame)

# Before displaying the minigame, their instructions will need to be briefly displayed (Note
# that instructions are subclasses of BaseOverlay). While the instructions cover the rest
# of the game, the switch between the old minigame and the new minigame should be made.
# After the transition finishes, the new minigame is started.
func _enqueue_minigame(_minigame: BaseMinigame) -> void:
	
	if _lives <= 0:
		_game_finished()
		return
	
	# Perform the required minigame connections
	_minigame.connect("success", self, "_on_miningame_succeeded")
	_minigame.connect("failure", self, "_on_minigame_failure")
	_minigame.connect("request_next", self, "_on_minigame_request_next")
	_minigame.connect("request_shake", self, "_on_minigame_requested_shake")
	
	# Show the minigame's required instruction screen
	var _instructions = _instruction_res.instance()
	overlay_node.add_child(_instructions)
#	if _minigame.instructions == "":
#		_instructions.show_instruction("Fix it!")
#	else:
#		_instructions.show_instruction(_minigame.instructions)
	_instructions.show_instruction("Quick Fix!")
	_instructions.connect("finished", self, "_on_instructions_finished")

	# Wait for the instruction screen's "peaked" signal before adding the minigame to
	# the tree and freeing the old one. Note that the code defined after the `yield`
	# statement will wait for the "peaked" signal before continuing execution. this
	# is known as "coroutines".
	yield(_instructions, "peaked")
	life_container.show()
	if _cur_minigame != null:
		_cur_minigame.queue_free()
	_cur_minigame = _minigame
	add_child(_minigame)

	# Always hide the main menu when an instructions overlay peaks
	_hide_main_menu()

# Called when all defined minigames are finished
func _game_finished() -> void:
	_show_game_over()

func _show_main_menu() -> void:
	main_menu_wrapper.show()

func _hide_main_menu() -> void:
	main_menu_wrapper.hide()

func _calculate_score(time_left: float) -> void:
	_score += int(floor(time_left * 10))

func _show_game_over() -> void:
	var _game_over_inst := _score_res.instance() as BaseOverlay
	overlay_node.add_child(_game_over_inst)
	_game_over_inst.show_score(_score)
	_game_over_inst.connect("retry_requested", self, "_on_retry_requested")
	$GameOverSoundPlayer.play()

func _inject_new_minigame_set() -> void:
	if _reserved_minigames.empty():
		_reserved_minigames = [
			"res://Screens/MiniGames/DragTheCubes/DragTheCubes.tscn"
		]
		var _duplicate_minigames := minigames.duplicate()
		randomize()
		_duplicate_minigames.shuffle()
		for minigame in _duplicate_minigames:
			if minigame != "res://Screens/MiniGames/DragTheCubes/DragTheCubes.tscn":
				_reserved_minigames.append(minigame)
	else:
		var _duplicate_minigames := minigames.duplicate()
		randomize()
		_duplicate_minigames.shuffle()
		for minigame in _duplicate_minigames:
			_reserved_minigames.append(minigame)

func _substract_life() -> void:
	_lives -= 1
	life_container.display_available_lives(_lives)

# ================================ Callbacks ================================ #

# Connected via UI
func _on_StartButton_pressed() -> void:
	_start_game()

# Connected via UI
func _on_Credits_pressed() -> void:
	pass # Replace with function body.

func _on_instructions_finished() -> void:
	var _difficulty := int(floor(_current_minigame_offset / 8)) + 1
	_cur_minigame.start(_difficulty)

# Show the success screen
func _on_miningame_succeeded(_time_left: float) -> void:

	# Calculate what will be added to the score depending on the time left
	_calculate_score(_time_left)
	
	if !_cur_minigame.no_overlay_for_success:
		_enqueued_success = true
		var _success_ins = _success_res.instance()
		overlay_node.add_child(_success_ins)
		yield(_success_ins, "finished")
		_go_to_next_minigame()

# Show the failure screen
func _on_minigame_failure() -> void:
	
	_substract_life()
	
	if !_cur_minigame.no_overlay_for_fail:
		_enqueued_success = false
		var _failure_ins = _failure_res.instance()
		overlay_node.add_child(_failure_ins)
		yield(_failure_ins, "finished")
		_go_to_next_minigame()

func _on_retry_requested() -> void:
	
	_lives = 3
	_score = 0
	_current_minigame_offset = 0
	
	_reserved_minigames.clear()
	_inject_new_minigame_set()
	
	life_container.display_available_lives(_lives)
	var _first_minigame := load(_reserved_minigames[0]).instance() as BaseMinigame
	_enqueue_minigame(_first_minigame)

func _on_minigame_request_next(_data := {}) -> void:
	if _enqueued_success:
		var _success_ins = _success_res.instance()
		overlay_node.add_child(_success_ins)
		yield(_success_ins, "finished")
		_go_to_next_minigame()
	else:
		var _failure_ins = _failure_res.instance()
		overlay_node.add_child(_failure_ins)
		yield(_failure_ins, "finished")
		_go_to_next_minigame()

func _on_minigame_requested_shake(intensity: float, duration: float) -> void:
	get_node("Camera2D").shake(intensity, duration)

func _on_AudioStreamPlayer_finished() -> void:
	$BGMPlayer.play()
