extends BaseMinigame

onready var portrait : Sprite = get_node("Portrait")
onready var reflection : Sprite = get_node("Portrait/Reflection")
onready var shadow : Sprite = get_node("Shadow")
onready var nail : Vector2 = get_node("Nail").global_position
onready var animation_player := get_node("AnimationPlayer") as AnimationPlayer

var anchor : int
var virtual_nail : Vector2
var difference = 0
var clicking : bool = false
var leeway : float = 0.5

func _ready() -> void:
	randomize()
	var _possible_values = [-30, 30]
	var _rand_starting_rotation = _possible_values[randi() % 2]
	portrait.rotation_degrees = _rand_starting_rotation
	shadow.rotation_degrees = _rand_starting_rotation

func _input(event : InputEvent) -> void:
	
	if _is_active:
	
		if event is InputEventMouseMotion and clicking:
			if event.relative.x < 0:
				portrait.rotation_degrees += 1
			elif event.relative.x > 0:
				portrait.rotation_degrees -= 1

func _process(_delta : float) -> void:
	
	if !_is_active:
		return
	
	reflection.modulate.a = clamp(abs(portrait.rotation_degrees), 0.0, 45.0) / 45.0 + 0.2
	shadow.rotation_degrees = portrait.rotation_degrees
	
	if Input.is_action_pressed("click"):
		clicking = true
	else:
		clicking = false
	
	if !clicking:
		if portrait.rotation_degrees > -leeway and portrait.rotation_degrees < leeway:
			portrait.rotation_degrees = 0
			shadow.rotation_degrees = 0
			on_success()
			set_process(false)

func start(difficulty := 1) -> void:
	.start(difficulty)
	match difficulty:
		1: 
			_set_leeway(5)
		2: 
			_set_leeway(3)
			_lifetime += 0.5
		_: 
			_set_leeway(2)
			_lifetime += 1.0
	
	timer_clock.set_max_time(_lifetime)
	

func _set_leeway(_leeway : float = 0.5) -> void:
	leeway = _leeway

# @Overwrite
func on_failure() -> void:
	.on_failure()
	animation_player.play("falling")

func on_success() -> void:
	.on_success()
	animation_player.play("win")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "falling":
		request_shake(5.0, 0.4)
		request_next()
	elif anim_name == "win":
		request_next()
