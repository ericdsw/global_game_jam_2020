extends BaseMinigame

onready var rest_timer : Timer = get_node("RestTimer")
onready var anim_player : AnimationPlayer = get_node("TV/AnimationPlayer")

var amount_of_clicks : int = 5
var click_counter : int = 0

func _ready():
	_set_amount_of_clicks(1, 5)
	_set_rest_timeout(0.5)

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("click"):
		click_counter += 1
		
		if click_counter < amount_of_clicks:
			anim_player.stop()
			anim_player.play("bad_hit")
		elif click_counter == amount_of_clicks:
			rest_timer.start()
			anim_player.stop()
			anim_player.play("good_hit")
		elif click_counter > amount_of_clicks and !rest_timer.is_stopped():
			on_failure()

# Sets the minimum and maximum amount of clicks possible needed to get clean image.
func _set_amount_of_clicks(_min : int = 1, _max : int = 5) -> void:
	randomize()
	amount_of_clicks = randi() % _max + _min

# Sets the time the player has to NOT click in order to succeed.
# Probably a smaller time is easier.
# Should the game timer wait for this timer?
func _set_rest_timeout(_timeout : float = 0.5) -> void:
	rest_timer.wait_time = _timeout

# Connected via UI
func _on_RestTimer_timeout() -> void:
	on_success()

func on_success() -> void:
	rest_timer.stop()
	.on_success()

func on_failure() -> void:
	rest_timer.stop()
	.on_failure()
