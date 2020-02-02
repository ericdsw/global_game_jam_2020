extends BaseMinigame

onready var pen_scene : PackedScene = load("res://Screens/MiniGames/PenPocket/Pen.tscn")

onready var pen_pos_1 : Vector2 = get_node("Pocket/PenPos1").global_position
onready var pen_pos_2 : Vector2 = get_node("Pocket/PenPos2").global_position
onready var pen_pos_3 : Vector2 = get_node("Pocket/PenPos3").global_position
onready var pen_pos_4 : Vector2 = get_node("Pocket/PenPos4").global_position

onready var ink : Sprite = get_node("Ink")

onready var pen_undone_y : float = get_node("PenUndoneY").global_position.y
onready var pen_done_y : float = get_node("PenDoneY").global_position.y

onready var finger_undone_y : float = get_node("FingerUndoneY").global_position.y
onready var finger_done_y : float = get_node("FingerDoneY").global_position.y

onready var finger : Position2D = get_node("Finger")
onready var finger_tween : Tween = get_node("FingerTween")
onready var thumbs_up : Sprite = get_node("ThumbsUp")
onready var thumbs_up_pos : Vector2 = get_node("ThumbsUpPosition").global_position
onready var thumbs_up_tween : Tween = get_node("ThumbsUpTween")

onready var pen_tex_1 : Texture = preload("res://Resources/PenPocket/PenT1.png")
onready var pen_tex_2 : Texture = preload("res://Resources/PenPocket/PenT2.png")
onready var pen_tex_3 : Texture = preload("res://Resources/PenPocket/PenT3.png")
onready var pen_tex_4 : Texture = preload("res://Resources/PenPocket/PenT4.png")
var pen_images_array : Array

var aligned_pen_array : Array
var misaligned_pen_array : Array
var aligned_finger_array : Array
var misaligned_finger_array : Array
var pen_array : Array
var counter_array : Array

var current_pen : int = -1
var units_per_second : int = 100
export var leeway : int = 5

enum State {PRESSING, MOVING, FAILED, WON}
var state : int = State.MOVING

func _ready():
	pen_images_array.append(pen_tex_1)
	pen_images_array.append(pen_tex_2)
	pen_images_array.append(pen_tex_3)
	pen_images_array.append(pen_tex_4)
	_configure_arrays()

func start(difficulty := 1) -> void:
	.start(difficulty)
	match difficulty:
		1: 
			_spawn_pens(1)
			leeway = 5
		2:
			_spawn_pens(2)
			_lifetime += 1.0
			leeway = 3.5
		_: 
			_spawn_pens(3)
			_lifetime += 2.0
			leeway = 2
	timer_clock.set_max_time(_lifetime)
	_put_finger_in_next_pen()

func on_failure() -> void:
	print("failure of pen pocket")
	.on_failure()
	$OofPlayer.play()
	
	get_tree().create_timer(0.7).connect("timeout", self, "_oof_done")

func _spawn_ink() -> void:
	ink.global_position = Vector2(pen_array[current_pen].global_position.x, $InkY.global_position.y)

func _oof_done():
	request_next()

func on_success() -> void:
	.on_success()
	
	thumbs_up_tween.interpolate_property(thumbs_up, "global_position", thumbs_up.global_position, thumbs_up_pos, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	thumbs_up_tween.start()

func _process(delta : float) -> void:
	
	if !_is_active: return
	
	if state == State.PRESSING:
		if Input.is_action_pressed("click"):
			pen_array[current_pen].global_position.y += units_per_second * delta
			finger.global_position.y += units_per_second * delta
		if Input.is_action_just_released("click"):
			if abs(pen_array[current_pen].global_position.y - pen_done_y) < leeway:
				pen_array[current_pen].global_position = aligned_pen_array[current_pen]
				finger.global_position = aligned_finger_array[current_pen]
				_put_finger_in_next_pen()
		
		if pen_array[current_pen].global_position.y > pen_done_y + leeway:
			state = State.FAILED
			_spawn_ink()
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
		state = State.WON
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
	pen_instance.texture = pen_images_array.pop_back()
	
	pen_instance.global_position = Vector2(misaligned_pen_array[_pos].x, pen_undone_y)
	$Pens.add_child(pen_instance)

func _spawn_done_pen_in_pos(_pos : int = 0) -> void:
	var pen_instance : Sprite = pen_scene.instance()
	pen_array.append(pen_instance)
	pen_instance.texture = pen_images_array.pop_back()
	
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

func _on_ThumbsUpTween_tween_completed(object, key):
	get_tree().create_timer(0.5).connect("timeout", self, "_thumbs_up_timeout")

func _thumbs_up_timeout() -> void:
	request_next()
