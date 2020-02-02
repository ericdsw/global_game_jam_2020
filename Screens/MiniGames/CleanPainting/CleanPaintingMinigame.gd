extends BaseMinigame

onready var dirt_scene : PackedScene = load("res://Screens/MiniGames/CleanPainting/Dirt.tscn")
onready var painting : Sprite = get_node("Painting")
onready var click_area_scene : PackedScene = load("res://Screens/MiniGames/CleanPainting/MouseHitbox.tscn")

var _click_area : Area2D

export var dirt_amount : int = 3

var cleaned_dirt : int = 0

func start(difficulty :=1) -> void:
	.start(difficulty)
	_spawn_dirt(dirt_amount)
	timer_clock.set_max_time(_lifetime)

func _input(_event : InputEvent) -> void:
	if _event.is_action("click") and !_event.is_echo():
		if _event.is_pressed():
			_click_area = click_area_scene.instance()
			_click_area.global_position = get_global_mouse_position()
			add_child(_click_area)
		else:
			if _click_area != null:
				_click_area.queue_free()
				_click_area = null
	pass
 
func _choose_random_sprite_position(_dirt : Sprite) -> void:
	randomize()
	var view_painting : Vector2 = Vector2(painting.texture.get_width(), painting.texture.get_height())
	var view_dirt : Vector2 = Vector2(_dirt.texture.get_width(), _dirt.texture.get_height())
	_dirt.global_position = Vector2(
		rand_range(-view_painting.x /2.0, view_painting.x /2.0 -view_dirt.x),
		rand_range(-view_painting.y /2.0, view_painting.y /2.0 -view_dirt.y))
	
func _spawn_dirt(_amount : int = 1) -> void:
		for i in range (0, _amount):
			var _dirt : Sprite = dirt_scene.instance()
			_dirt.connect("ruined_painting", self, "on_failure")
			_dirt.connect("cleaned", self, "_cleaned_one_dirt")
			add_child(_dirt)
			_choose_random_sprite_position(_dirt)
		
		_calculate_game_duration(_amount)

func _calculate_game_duration(_amount : int = 1):
	_lifetime = _amount * 2.5

func _clean_dirt() -> void:
	print("clean")

func _cleaned_one_dirt() -> void:
	
	print("cleaned a dirty thing")
	cleaned_dirt += 1
	
	if cleaned_dirt >= dirt_amount:
		on_success()
