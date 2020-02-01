extends BaseMinigame

const CUBE_PATH := "res://Screens/Minigames/DragTheCubes/Elements/LetterCube.tscn"
const POSSIBLE_LETTERS := ["A", "B", "C", "D"]

var _cubes := []

var _correctly_ordered_letters := []
var _selected_letters := []
var _random_generator := RandomNumberGenerator.new()

var _original_cube_position : Vector2
var _current_cube : LetterCube
var _performing_swap := false
var _offset_to_cur_cube := Vector2()

# ================================ Lifecycle ================================ #

func _ready() -> void:
	_random_generator.randomize()
	_select_letters()

func _process(_delta: float) -> void:
	if _current_cube != null and !_performing_swap:
		_current_cube.global_position = get_global_mouse_position() - _offset_to_cur_cube
		var _areas = _current_cube.detection_area.get_overlapping_areas()
		
		for cube in _cubes:
			cube.modulate = Color.white
		
		var _closest_cube = null
		for area in _areas:
			if area.get_parent() != _current_cube:
				if _closest_cube == null:
					_closest_cube = area.get_parent()
				else:
					if _closest_cube.global_position.distance_to(_current_cube.global_position) > area.get_parent().global_position.distance_to(_current_cube.global_position):
						_closest_cube = area.get_parent()
		
		if _closest_cube != null:
			_closest_cube.modulate = Color.blue

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			var _cube = _find_cube_under_mouse()
			if _cube != null:
				_current_cube = _cube
				_original_cube_position = _cube.global_position
				_offset_to_cur_cube = get_global_mouse_position() - _cube.global_position
			else:
				print("No cube defined")
		else:
			if _current_cube != null:
				
				for cube in _cubes:
					cube.modulate = Color.white
				
				_check_change()
#				_current_cube = null
#				_offset_to_cur_cube = Vector2()


func start(difficulty := 1) -> void:
	.start(difficulty)
	
	var _cube_origin = - _selected_letters.size() / 2.0 * 100.0 + 50.0
	
	for i in range(_selected_letters.size()):
		var _cube = load(CUBE_PATH).instance()
		_cube.position = Vector2(_cube_origin + i * 100, 0)
		add_child(_cube)
		_cube.show_letter(_selected_letters[i])
		_cubes.append(_cube)

func _check_change() -> void:
	var areas := _current_cube.detection_area.get_overlapping_areas()
	if areas.empty():
		_current_cube.move_to(_original_cube_position)
	else:
		var _cube_to_swap = null
		for area in areas:
			if _cube_to_swap == null:
				_cube_to_swap = area.get_parent()
			else:
				var _cur_cube := area.get_parent() as LetterCube
				var _check_pos := _current_cube.global_position
				if _cur_cube.global_position.distance_to(_check_pos) < _cube_to_swap.global_position.distance_to(_check_pos):
					_cube_to_swap = _cur_cube
		
		_current_cube.move_to(_cube_to_swap.global_position)
		_cube_to_swap.move_to(_original_cube_position)
		_performing_swap = true
		
		yield(_current_cube, "finished_movement")
		_swap_cubes(
			_selected_letters.find(_current_cube.assigned_letter),
			_selected_letters.find(_cube_to_swap.assigned_letter)
		)
		
		for i in range(0, _correctly_ordered_letters.size()):
			if _correctly_ordered_letters[i] != _selected_letters[i]:
				on_failure()
				return
		on_success()

func _select_letters() -> void:

	_selected_letters = POSSIBLE_LETTERS.duplicate(true)
	_correctly_ordered_letters = POSSIBLE_LETTERS.duplicate(true)

	var _rand_change_pair_1 = _random_generator.randi_range(0, _selected_letters.size() - 1)
	var _rand_change_pair_2 = _random_generator.randi_range(0, _selected_letters.size() - 1)
	while _rand_change_pair_1 == _rand_change_pair_2:
		_rand_change_pair_2 = _random_generator.randi_range(0, _selected_letters.size() - 1)
	
	_swap_cubes(_rand_change_pair_1, _rand_change_pair_2)

func _swap_cubes(pos1, pos2) -> void:
	var _temporal = _selected_letters[pos1]
	_selected_letters[pos1] = _selected_letters[pos2]
	_selected_letters[pos2] = _temporal

func _find_cube_under_mouse() -> LetterCube:
	var mouse_pos = get_global_mouse_position()
	for cube in _cubes:
		if cube.contains_position(mouse_pos):
			return cube
	return null
