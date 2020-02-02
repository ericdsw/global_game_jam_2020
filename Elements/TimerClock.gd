extends Node2D

var _max_time := 0.0
var _playing_sound := false

onready var hand_sprite := get_node("HandSprite") as Sprite

func play_time_sound() -> void:
	_playing_sound = true
	$TickPlayer.play()

func stop_time_sound() -> void:
	_playing_sound = false
	$TickPlayer.stop()

func play_timeout_song() -> void:
	$RingPlayer.play()

func set_max_time(max_time : float) -> void:
	_max_time = max_time

func display_time(time: float) -> void:
	
	var _completion_percent = time / _max_time
	var _angle = clamp(-360.0 * _completion_percent, -360.0, 0.0)
	
	hand_sprite.rotation_degrees = _angle

func _on_AudioStreamPlayer_finished() -> void:
	if _playing_sound:
		$TickPlayer.play()
