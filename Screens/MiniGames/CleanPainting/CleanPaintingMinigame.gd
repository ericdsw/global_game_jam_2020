extends BaseMinigame

onready var dirt_scene : PackedScene = load("res://Screens/MiniGames/CleanPainting/Dirt.tscn")
onready var painting : Sprite = get_node("Painting")
onready var click_area_scene : PackedScene = load("res://Screens/MiniGames/CleanPainting/MouseHitbox.tscn")

var _click_area : Area2D

func start(difficulty :=1) -> void:
	.start(difficulty)
	_spawn_dirt(3)

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

func _process(delta) -> void:
	
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
			add_child(_dirt)
			_choose_random_sprite_position(_dirt)
			

func _clean_dirt() -> void:
	
	print("clean")
