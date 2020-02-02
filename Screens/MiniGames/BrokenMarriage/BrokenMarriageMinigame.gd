extends BaseMinigame

onready var marriage_button_scene : PackedScene = load("res://Screens/Minigames/BrokenMarriage/Buttons/MarriageButton.tscn")
var wrong_options : Array = [
	"FIGHT EACH OTHER", 
	"DIVORCE", 
	"TAKE THE NINTENDO WII", 
	"DON'T LISTEN", 
	"IGNORE", 
	"RUN AWAY",
	"ABSCOND"
]

func start(difficulty := 1) -> void:
	.start(difficulty)
	_spawn_buttons(5)

func _choose_random_button_position(_button : Button) -> void:
	randomize()
	var viewport : Vector2 = get_viewport_rect().size
	var fix_marriage_button_size = _button.rect_size 
	_button.rect_global_position = Vector2(
		rand_range(-viewport.x / 2.0, viewport.x / 2.0 - fix_marriage_button_size.x), 
		rand_range(-viewport.y / 2.0, 0.0) #viewport.y / 2.0 - fix_marriage_button_size.y)
	)

func _spawn_buttons(_amount : int = 2) -> void:
	for i in range(0, _amount):
		var _button : Button = marriage_button_scene.instance()
		add_child(_button)
		_choose_random_button_position(_button)
		
		if i == 0:
			_button.connect("pressed", self, "_pressed_correct_button")
			_button.text = "FIX MARRIAGE"
		else:
			_button.connect("pressed", self, "_pressed_wrong_button")
			wrong_options.shuffle()
			if i > wrong_options.size():
				_button.text = wrong_options.back()
			else:
				_button.text = wrong_options[i - 1]

func _pressed_correct_button() -> void:
	on_success()

func _pressed_wrong_button() -> void:
	on_failure()
