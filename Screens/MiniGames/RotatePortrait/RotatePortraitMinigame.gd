extends BaseMinigame

onready var portrait : Sprite = get_node("Portrait")
onready var nail : Vector2 = get_node("Nail").global_position

var anchor : int
var virtual_nail : Vector2
var difference = 0
var clicking : bool = false
var leeway : float = 0.5

func _ready() -> void:
	_set_leeway(5)

#func _input(event: InputEvent) -> void:
#
#	if event.is_action_pressed("click"):
#		anchor = get_global_mouse_position().x
#
#	if anchor != null:
#		if event is InputEventMouseMotion:
#			if Input.is_action_pressed("click"):
#				difference += (anchor - get_global_mouse_position().x) * get_process_delta_time()
#				print(difference)
#				portrait.rotation_degrees = difference

func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion and clicking:
		if event.relative.x < 0:
			portrait.rotation_degrees += 1
		elif event.relative.x > 0:
			portrait.rotation_degrees -= 1

func _process(delta : float) -> void:
	if Input.is_action_pressed("click"):
		clicking = true
	else:
		clicking = false
	
	if !clicking:
		if portrait.rotation_degrees > -leeway and portrait.rotation_degrees < leeway:
			print("NAISUUU")
			portrait.rotation_degrees = 0
			on_success()
			set_process(false)

func _set_leeway(_leeway : float = 0.5) -> void:
	leeway = _leeway
