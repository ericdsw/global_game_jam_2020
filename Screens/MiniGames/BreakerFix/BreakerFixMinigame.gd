extends BaseMinigame

export (String, FILE) var breaker_path := ""
export (String, FILE) var breaker_click_area_path := ""

const BREAKER_P := "res://Screens/Minigames/BreakerFix/Elements/Breaker.tscn"
const C_AREA := "res://Screens/Minigames/BreakerFix/Elements/BreakerClickArea.tscn"

const EASY_PARAMS := {
	"amount": 8,
	"damaged": 2
}

const MEDIUM_AMOUNT := {
	"amount": 12,
	"damaged": 4
}

const HARD_AMOUNT := {
	"amount": 16,
	"damaged": 6
}

onready var left_container := get_node("LeftBreakerContainer") as VBoxContainer
onready var right_container := get_node("RightBreakerContainer") as VBoxContainer
onready var electricity_grid := get_node("ElectricityGrid") as AudioStreamPlayer

var _cur_amount := 0
var _cur_damaged := 0

var _breakers := []


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var _area = load(breaker_click_area_path).instance()
		add_child(_area)
		_area.global_position = get_global_mouse_position()

# @Overwrite
func start(difficulty := 1) -> void:
	.start(difficulty)
	electricity_grid.play()
	match difficulty:
		1:
			_cur_amount = EASY_PARAMS["amount"]
			_cur_damaged = EASY_PARAMS["damaged"]
		2:
			_cur_amount = MEDIUM_AMOUNT["amount"]
			_cur_damaged = MEDIUM_AMOUNT["damaged"]
		_:
			_cur_amount = HARD_AMOUNT["amount"]
			_cur_damaged = HARD_AMOUNT["damaged"]
	
	var _y_pos = (_cur_amount / 4.0) * 35
	
	for i in range(_cur_amount):
		
		var _breaker = load(breaker_path).instance()
		
		# Calculate X position and orientation
		if i <= _cur_amount / 2.0 - 1:
			left_container.add_child(_breaker)
		else:
			right_container.add_child(_breaker)
		
		_breakers.append(_breaker)
		_breaker.connect("changed", self, "_on_breaker_changed")
	
	randomize()
	var _duplicate_breakers := _breakers.duplicate(true)
	_duplicate_breakers.shuffle()
	
	for i in range(_cur_damaged):
		_duplicate_breakers[i].set_incorrect()

func _on_breaker_changed(_is_correct: bool) -> void:
	
	var _damaged_breakers := 0
	for breaker in _breakers:
		if !breaker._correct:
			_damaged_breakers += 1

	if _damaged_breakers <= 0:
		electricity_grid.stop()
		on_success()
	
