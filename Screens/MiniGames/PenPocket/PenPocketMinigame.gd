extends BaseMinigame

onready var pen_scene : PackedScene = load("res://Screens/MiniGames/PenPocket/Pen.tscn")

onready var pen_pos_1 : Vector2 = get_node("Pocket/PenPos1").global_position
onready var pen_pos_2 : Vector2 = get_node("Pocket/PenPos2").global_position
onready var pen_pos_3 : Vector2 = get_node("Pocket/PenPos3").global_position
onready var pen_pos_4 : Vector2 = get_node("Pocket/PenPos4").global_position

onready var pen_undone_y : float = get_node("PenUndoneY").global_position.y
onready var pen_done_y : float = get_node("PenDoneY").global_position.y

onready var finger_undone_y : float = get_node("FingerUndoneY").global_position.y
onready var finger_done_y : float = get_node("FingerDoneY").global_position.y

onready var finger : Position2D = get_node("Finger")
onready var finger_tween : Tween = get_node("FingerTween")

var aligned_pen_array : Array
var misaligned_pen_array : Array
var aligned_finger_array : Array
var misaligned_finger_array : Array
var pen_array : Array
var counter_array : Array

var current_pen : int = -1
var units_per_second : int = 100
export var leeway : int = 5

enum State {PRESSING, MOVING, FAILED}
var state : int = State.MOVING

func _ready():
	_configure_arrays()
	_spawn_pens(3)
	_put_finger_in_next_pen()

func _process(delta : float) -> void:
	if state == State.PRESSING:
		if Input.is_action_pressed("click"):
			pen_array[current_pen].global_position.y += units_per_second * delta
			finger.global_position.y += units_per_second * delta
		if Input.is_action_just_released("click"):
			if abs(pen_array[current_pen].global_position.y - pen_done_y) <= 5:
				pen_array[current_pen].global_position = aligned_pen_array[current_pen]
				finger.global_position = aligned_finger_array[current_pen]
				_put_finger_in_next_pen()
		
		if pen_array[current_pen].global_position.y > pen_done_y + 5:
			state = State.FAILED
			on_failure()

func _spawn_pens(_undone_amount : int = 1) -> void:
	randomize()
	for i in range(4):
		if randi() % 10 + 1 < 5:
			if counter_array.count(true) >= _undone_amount:
				break
			else:
				counter_array[i] = true
	
	while counter_array.count(true) < _undone_amount:
		counter_array[counter_array.find(false)] = true
	
	for i in counter_array.size():
		if counter_array[i] == true:
			_spawn_undone_pen_in_pos(i)
		else:
			_spawn_done_pen_in_pos(i)

func _put_finger_in_next_pen() -> void:
	
	if current_pen < counter_array.size() - 1:
		current_pen += 1
	else:
		on_success()
		return
	
	if counter_array[current_pen] == false:
		_put_finger_in_next_pen()
	else:
		if current_pen >= counter_array.size():
			return
		
		var i_pos = finger.global_position
		var f_pos = misaligned_finger_array[current_pen]
		
		state = State.MOVING
		finger_tween.interpolate_property(finger, "global_position", i_pos, f_pos, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		finger_tween.start()

func _spawn_undone_pen_in_pos(_pos : int = 0) -> void:
	var pen_instance : Sprite = pen_scene.instance()
	pen_array.append(pen_instance)
	
	pen_instance.global_position = Vector2(misaligned_pen_array[_pos].x, pen_undone_y)
	$Pens.add_child(pen_instance)

func _spawn_done_pen_in_pos(_pos : int = 0) -> void:
	var pen_instance : Sprite = pen_scene.instance()
	pen_array.append(pen_instance)
	
	pen_instance.global_position = Vector2(aligned_pen_array[_pos].x, pen_done_y)
	$Pens.add_child(pen_instance)

func _configure_arrays() -> void:
	aligned_pen_array.append(Vector2(pen_pos_1.x, pen_done_y))
	aligned_pen_array.append(Vector2(pen_pos_2.x, pen_done_y))
	aligned_pen_array.append(Vector2(pen_pos_3.x, pen_done_y))
	aligned_pen_array.append(Vector2(pen_pos_4.x, pen_done_y))
	
	misaligned_pen_array.append(Vector2(pen_pos_1.x, pen_undone_y))
	misaligned_pen_array.append(Vector2(pen_pos_2.x, pen_undone_y))
	misaligned_pen_array.append(Vector2(pen_pos_3.x, pen_undone_y))
	misaligned_pen_array.append(Vector2(pen_pos_4.x, pen_undone_y))
	
	aligned_finger_array.append(Vector2(pen_pos_1.x, finger_done_y))
	aligned_finger_array.append(Vector2(pen_pos_2.x, finger_done_y))
	aligned_finger_array.append(Vector2(pen_pos_3.x, finger_done_y))
	aligned_finger_array.append(Vector2(pen_pos_4.x, finger_done_y))
	
	misaligned_finger_array.append(Vector2(pen_pos_1.x, finger_undone_y))
	misaligned_finger_array.append(Vector2(pen_pos_2.x, finger_undone_y))
	misaligned_finger_array.append(Vector2(pen_pos_3.x, finger_undone_y))
	misaligned_finger_array.append(Vector2(pen_pos_4.x, finger_undone_y))
	
	for i in range(4):
		counter_array.append(false)

# connected via UI.
func _on_FingerTween_tween_completed(object : Object, key : String) -> void:
	state = State.PRESSING