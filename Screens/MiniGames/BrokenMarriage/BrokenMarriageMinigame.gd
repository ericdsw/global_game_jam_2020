extends BaseMinigame

export (String, FILE) var marriage_button_path := ""

onready var couple_speech_pattern := get_node("CoupleSpeech") as AudioStreamPlayer 
onready var marriage_button_scene : PackedScene = load(marriage_button_path)

var speech_timer : bool = true
var wrong_options : Array = [
	"FIGHT EACH OTHER", 
	"DIVORCE", 
	"TAKE THE NINTENDO WII", 
	"DON'T LISTEN", 
	"IGNORE", 
	"RUN AWAY",
	"ABSCOND",
	"KAREN, TAKE THE KIDS",
	"CHANGE IDENDITY",
	"DO A BARREL ROLL",
	"TOPPLE THE MONARCHY",
	"ESTABLISH COMMUNISM",
	"DO A REACTION VIDEO",
	"ALEXA, PLAY DESPACITO",
	"BLAME THE KIDS"
]

var buttons := []
var possible_positions := []
signal all_buttons_displayed()

func _ready() -> void:
	for child in get_node("PossiblePositions").get_children():
		possible_positions.append(child.position)

func start(difficulty := 1) -> void:
	
	couple_speech_pattern.play()
	match difficulty:
		1 : _spawn_buttons(2)
		2 : _spawn_buttons(5)
		_ : _spawn_buttons(9)
	yield(self, "all_buttons_displayed")
	.start(difficulty)
		
func _choose_random_button_position(_button : Button) -> void:
	randomize()
	var _random_pos : int = randi() % possible_positions.size()
	var _used_pos : Vector2 = possible_positions[_random_pos]
	_button.rect_global_position = _used_pos
	possible_positions.remove(_random_pos)

func _spawn_buttons(_amount : int = 2) -> void:
	
	randomize()
	wrong_options.shuffle()
	
	_add_button("LOVE & CUDDLE", true)
	yield(get_tree().create_timer(0.05), "timeout")
	
	for i in range(0, _amount - 1):
		_add_button(wrong_options[i])
		yield(get_tree().create_timer(0.05), "timeout")
	
	emit_signal("all_buttons_displayed")

func _add_button(text : String, is_correct := false) -> void:
	var _button : MarriageButton = marriage_button_scene.instance()
	_button.text = text
	if is_correct:
		_button.connect("pressed", self, "_pressed_correct_button")
	else:
		_button.connect("pressed", self, "_pressed_wrong_button")
	add_child(_button)
	_choose_random_button_position(_button)
	buttons.append(_button)

func _fade_all() -> void:
	for button in buttons:
		button.request_fade_out()

func _pressed_correct_button() -> void:
	on_success()

func on_success() -> void:
	.on_success()
	couple_speech_pattern.stop()
	$Award/AnimationPlayer.play("success")
	_fade_all()
	$SuccessPlayer.play()

func _pressed_wrong_button() -> void:
	on_failure()

func on_failure() -> void:
	.on_failure()
	couple_speech_pattern.stop()
	$Award/AnimationPlayer.play("failure")
	_fade_all()
	$FailurePlayer.play()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	yield(get_tree().create_timer(1.2), "timeout")
	request_next()
