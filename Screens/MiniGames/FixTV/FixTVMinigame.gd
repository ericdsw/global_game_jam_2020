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
onready var arm_sound_play : AudioStreamPlayer = get_node("ArmSound")
onready var foot_sound_play : AudioStreamPlayer = get_node("FootSound")
onready var win_sound_play : AudioStreamPlayer = get_node("WinSound")

var amount_of_clicks : int = 5
var click_counter : int = 0
var done : bool = false

func _input(event : InputEvent) -> void:
	if done: return
	
	if event.is_action_pressed("click"):
		_animate_arm_or_foot()
		click_counter += 1
		
		if click_counter < amount_of_clicks:
			anim_player.stop()
			var t_a : Array = ["bad_hit_1", "bad_hit_2"]
			t_a.shuffle()
			anim_player.play(t_a[0])
		elif click_counter == amount_of_clicks:
			rest_timer.start()
			anim_player.stop()
			anim_player.play("good_hit")
		elif click_counter > amount_of_clicks and !rest_timer.is_stopped():
			on_failure()

func start(difficulty := 1) -> void:
	.start(difficulty)
	
	match difficulty:
		1:
			_set_amount_of_clicks(1, 5)
			_set_rest_timeout(0.5)
		2:
			_set_amount_of_clicks(3, 8)
			_set_rest_timeout(1.0)
			_lifetime += 1.0
		_:
			_set_amount_of_clicks(5, 10)
			_set_rest_timeout(1.2)
			_lifetime += 2.0
	
	timer_clock.set_max_time(_lifetime)

# Sets the minimum and maximum amount of clicks possible needed to get clean image.
func _set_amount_of_clicks(_min : int = 1, _max : int = 5) -> void:
	randomize()
	amount_of_clicks = randi() % _max + _min

func _animate_arm_or_foot() -> void:
	randomize()
	
	if _assigned_difficulty == 1:
		a_tween.stop_all()
		arm_sound_play.stop()
		arm.global_position = a_i_pos
		a_tween.interpolate_property(
			arm, "global_position", a_i_pos, a_f_pos, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN
		)
		a_tween.start()
		arm_sound_play.play()
	elif _assigned_difficulty == 2:
		f_tween.stop_all()
		foot_sound_play.stop()
		foot.global_position = f_i_pos
		f_tween.interpolate_property(
			foot, "global_position", f_i_pos, f_f_pos, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN
		)
		f_tween.start()
		foot_sound_play.play()
	else:
		if randi() % 10 + 1 < 5:
			a_tween.stop_all()
			arm_sound_play.stop()
			arm.global_position = a_i_pos
			a_tween.interpolate_property(
				arm, "global_position", a_i_pos, a_f_pos, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN
			)
			a_tween.start()
			arm_sound_play.play()
		else:
			f_tween.stop_all()
			foot_sound_play.stop()
			foot.global_position = f_i_pos
			f_tween.interpolate_property(
				foot, "global_position", f_i_pos, f_f_pos, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN
			)
			f_tween.start()
			foot_sound_play.play()

# Sets the time the player has to NOT click in order to succeed.
# Probably a smaller time is easier.
# Should the game timer wait for this timer?
func _set_rest_timeout(_timeout : float = 0.5) -> void:
	rest_timer.wait_time = _timeout

# Connected via UI
func _on_RestTimer_timeout() -> void:
	anim_player.play("clean")
	on_success()

# @Overwrite
func on_success() -> void:
	rest_timer.stop()
	win_sound_play.play()
	done = true
	.on_success()

	yield(get_tree().create_timer(1.0), "timeout")
	request_next()

# @Overwrite
func on_failure() -> void:
	rest_timer.stop()
	done = true
	.on_failure()

func _on_ArmTween_tween_completed(_object : Object, _key : String) -> void:
	request_shake(3.0, 0.1)

func _on_FootTween_tween_completed(_object : Object, _key : String) -> void:
	request_shake(3.0 , 0.1)

func _on_AnimationPlayer_animation_finished(anim_name : String) -> void:
	if anim_name == "bad_hit_1" or anim_name == "bad_hit_2":
		anim_player.play("idle")
