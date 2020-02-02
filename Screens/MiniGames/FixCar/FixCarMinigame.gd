extends BaseMinigame

onready var leg_kick := get_node("KickCar") as AudioStreamPlayer
onready var car_engine_start := get_node("CarEngine") as AudioStreamPlayer
onready var police_sirens := get_node("PoliceSirens") as AudioStreamPlayer
onready var leg_player : AnimationPlayer = get_node("Leg/AnimationPlayer")
onready var lights_player : AnimationPlayer = get_node("Lights/AnimationPlayer")
onready var end_timer : Timer = get_node("EndTimer")
onready var car_animator : AnimationPlayer = get_node("CarAnimationPlayer")

var amount_of_clicks : int = 5
var click_counter : int = 0
var done : bool = false

func _input(event : InputEvent) -> void:
	
	if done or !_is_active : return
	
	if event.is_action_pressed("click"):
		leg_kick.play()
		click_counter += 1
		if !leg_player.is_playing():
			leg_player.play("kick")
		
		if click_counter >= amount_of_clicks:
			car_engine_start.play()
			on_success()


func on_success() -> void:
	.on_success()
	car_engine_start.play()
	car_animator.play("start")
	end_timer.start()

# @Overwrite
func on_failure() -> void:
	police_sirens.play()
	lights_player.play("flash")
	done = true
	end_timer.start()
	.on_failure()

func _on_EndTimer_timeout() -> void:
	request_next()
