extends BaseMinigame

onready var portrait : Sprite = get_node("Portrait")
onready var reflection : Sprite = get_node("Portrait/Reflection")
onready var shadow : Sprite = get_node("Shadow")
onready var nail : Vector2 = get_node("Nail").global_position

var anchor : int
var virtual_nail : Vector2
var difference = 0
var clicking : bool = false
var leeway : float = 0.5

func _ready() -> void:
	_set_leeway(5)

func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion and clicking:
		if event.relative.x < 0:
			portrait.rotation_degrees += 1
		elif event.relative.x > 0:
			portrait.rotation_degrees -= 1

func _process(delta : float) -> void:
	
	reflection.modulate.a = clamp(abs(portrait.rotation_degrees), 0.0, 45.0) / 45.0 + 0.2
	shadow.rotation_degrees = portrait.rotation_degrees
	
	if Input.is_action_pressed("click"):
		clicking = true
	else:
		clicking = false
	
	if !clicking:
		if portrait.rotation_degrees > -leeway and portrait.rotation_degrees < leeway:
			print("NAISUUU")
			portrait.rotation_degrees = 0
			shadow.rotation_degrees = 0
			on_success()
			set_process(false)

func _set_leeway(_leeway : float = 0.5) -> void:
	leeway = _leeway
