extends BaseMinigame

onready var rest_timer : Timer = get_node("RestTimer")
onready var anim_player : AnimationPlayer = get_node("TV/AnimationPlayer")
onready var arm : Sprite = get_node("Arm")
onready var foot : Sprite = get_node("Foot")
onready var a_i_pos : Vector2 = get_node("ArmRest").global_position
onready var a_f_pos : Vector2 = get_node("ArmFinal").global_position
onready var f_i_pos : Vector2 = get_node("FootRest").global_position
onready var f_f_pos : Vector2 = get_node("FootFinal").global_position
onready var a_tween : Tween = get_node("ArmTween")
onready var f_tween : Tween = get_node("FootTween")

var amount_of_clicks : int = 5
var click_counter : int = 0
var done : bool = false

func _ready():
	_set_amount_of_clicks(1, 5)
	_set_rest_timeout(0.5)

func _input(event : InputEvent) -> void:
	if done: return
	
	if event.is_action_pressed("click"):
		_animate_arm_or_foot()
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

func _animate_arm_or_foot() -> void:
	randomize()
	if randi() % 10 + 1 < 5:
		a_tween.stop_all()
		arm.global_position = a_i_pos
		a_tween.interpolate_property(arm, "global_position", a_i_pos, a_f_pos, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		a_tween.start()
	else:
		f_tween.stop_all()
		foot.global_position = f_i_pos
		f_tween.interpolate_property(foot, "global_position", f_i_pos, f_f_pos, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		f_tween.start()

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
	done = true
	.on_success()

func on_failure() -> void:
	rest_timer.stop()
	done = true
	.on_failure()

func _on_ArmTween_tween_completed(object : Object, key : String) -> void:
	pass

func _on_FootTween_tween_completed(object : Object, key : String) -> void:
	pass