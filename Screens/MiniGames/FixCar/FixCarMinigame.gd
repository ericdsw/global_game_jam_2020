extends BaseMinigame

onready var leg_player : AnimationPlayer = get_node("Leg/AnimationPlayer")
onready var lights_player : AnimationPlayer = get_node("Lights/AnimationPlayer")

var amount_of_clicks : int = 10
var click_counter : int = 0
var done : bool = false

func _input(event : InputEvent) -> void:
	if done: return
	
	if event.is_action_pressed("click"):
		click_counter += 1
		if !leg_player.is_playing():
			leg_player.play("kick")
		
		if click_counter >= amount_of_clicks:
			on_success()

func on_failure() -> void:
	lights_player.play("flash")
	done = true
	.on_failure()
