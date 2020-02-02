extends BaseMinigame

onready var couple_speech_pattern := get_node("CoupleSpeech") as AudioStreamPlayer 
onready var marriage_button_scene : PackedScene = load("res://Screens/Minigames/BrokenMarriage/Buttons/MarriageButton.tscn")
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
	"ALEXA, PLAY DESPACITO"
]

var possible_positions := []
signal all_buttons_displayed()

func _ready() -> void:
	for child in get_node("PossiblePositions").get_children():
		possible_positions.append(child.position)

func start(difficulty := 1) -> void:
	
	couple_speech_pattern.play()
	match difficulty:
		1 : _spawn_buttons(5)
		2 : _spawn_buttons(7)
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
	
	_add_button("FIX MARRIAGE", true)
	yield(get_tree().create_timer(0.05), "timeout")
	
	for i in range(0, _amount - 1):
		_add_button(wrong_options[i])
		yield(get_tree().create_timer(0.05), "timeout")
	
	emit_signal("all_buttons_displayed")

func _add_button(text : String, is_correct := false) -> MarriageButton:
	var _button : MarriageButton = marriage_button_scene.instance()
	_button.text = text
	if is_correct:
		_button.connect("pressed", self, "_pressed_correct_button")
	else:
		_button.connect("pressed", self, "_pressed_wrong_button")
	add_child(_button)
	_choose_random_button_position(_button)
	return _button

func _pressed_correct_button() -> void:
	couple_speech_pattern.stop()
	on_success()

func _pressed_wrong_button() -> void:
	couple_speech_pattern.stop()
	on_failure()
