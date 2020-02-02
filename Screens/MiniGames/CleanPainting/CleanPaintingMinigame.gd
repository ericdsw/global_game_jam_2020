extends BaseMinigame

onready var dirt_scene : PackedScene = load("res://Screens/MiniGames/CleanPainting/Dirt.tscn")
onready var painting : Sprite = get_node("Painting")
onready var click_area_scene : PackedScene = load("res://Screens/MiniGames/CleanPainting/MouseHitbox.tscn")
onready var clean_sound_play : AudioStreamPlayer = get_node("CleaningSound")
var _click_area : Area2D

onready var artwork_1 : Texture = preload("res://Resources/CleanPainting/Artwork1.png")
onready var artwork_2 : Texture = preload("res://Resources/CleanPainting/Artwork2.png")
onready var artwork_3 : Texture = preload("res://Resources/CleanPainting/Artwork3.png")

onready var sparkle : AudioStreamPlayer = get_node("SparkleSound")
onready var rip : AudioStreamPlayer = get_node("RipSound")

export var dirt_amount : int 

var cleaned_dirt : int = 0

func _ready() -> void:
	randomize()
	var temp_array : Array = [artwork_1, artwork_2, artwork_3]
	temp_array.shuffle()
	$Painting.texture = temp_array[1]

func start(difficulty := 1) -> void:
	.start(difficulty)
	dirt_amount = 1 + difficulty
	_spawn_dirt(dirt_amount)
	timer_clock.set_max_time(_lifetime)

func _input(_event : InputEvent) -> void:
	if _event.is_action("click") and !_event.is_echo():
		if _event.is_pressed():
			_click_area = click_area_scene.instance()
			_click_area.global_position = get_global_mouse_position()
			add_child(_click_area)
			clean_sound_play.play()
		else:
			if _click_area != null:
				clean_sound_play.stop()
				_click_area.queue_free()
				_click_area = null
	pass
 
func _choose_random_sprite_position(_dirt : Sprite) -> void:
	randomize()
	var random_x : float = rand_range($TopLeft.global_position.x, $BotRight.global_position.x)
	var random_y : float = rand_range($TopLeft.global_position.y, $BotRight.global_position.y)
	
	_dirt.global_position = Vector2(random_x, random_y)
	
func _spawn_dirt(_amount : int = 1) -> void:
		for i in range (0, _amount):
			var _dirt : Sprite = dirt_scene.instance()
			_dirt.connect("ruined_painting", self, "on_failure")
			_dirt.connect("cleaned", self, "_cleaned_one_dirt")
			_dirt.connect("ruined_painting", self, "_play_rip_sound", [], 4)
			add_child(_dirt)
			_choose_random_sprite_position(_dirt)
		
		_calculate_game_duration(_amount)

func _calculate_game_duration(_amount : int = 1):
	_lifetime = _amount * 2.5

func _clean_dirt() -> void:
	print("clean")

func _cleaned_one_dirt() -> void:
	
	sparkle.play()
	cleaned_dirt += 1
	
	if cleaned_dirt >= dirt_amount:
		on_success()

func _play_rip_sound() -> void:
	rip.play()
