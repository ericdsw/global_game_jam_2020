extends Node2D
class_name LetterCube

const PATH := "res://Resources/DragTheCubes/%sT.png"
const BG_PATH := "res://Resources/DragTheCubes/Cube%sT.png"

onready var background_sprite := get_node("BackgroundSprite") as Sprite
onready var letter_sprite := get_node("LetterSprite") as Sprite
onready var letter_label := get_node("Label") as Label
onready var detection_area := get_node("DetectionArea") as Area2D
onready var tween := get_node("Tween") as Tween

var assigned_letter := ""
var cube_size := 300.0

signal finished_movement()

func get_cube_size() -> Vector2:
	return background_sprite.texture.get_size()

func show_letter(letter: String) -> void:
	
	assigned_letter = letter
	letter_label.text = letter
	
	background_sprite.texture = load(BG_PATH % letter)
	letter_sprite.texture = load(PATH % letter)
	
	letter_sprite.position = _offset_for_letter(letter)

func contains_position(pos: Vector2) -> bool:
	var rect := Rect2(
		global_position - get_cube_size() / 2.0,
		get_cube_size()
	)
	return rect.has_point(pos)

func move_to(pos: Vector2) -> void:
	tween.interpolate_property(
		self, "position", position, pos, 0.2,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	tween.start()

func random_flip() -> void:
	randomize()
	var _random_number = randi() % 10 + 1
	
	if _random_number <= 40:
		letter_sprite.rotation_degrees = 90
	elif _random_number <= 80:
		letter_sprite.rotation_degrees = 270
	else:
		letter_sprite.rotation_degrees = 180

func _offset_for_letter(letter: String) -> Vector2:
	if ["A", "C", "D"].has(letter):
		return Vector2(12, 6)
	else:
		return Vector2(-12, 6)

func _on_Tween_tween_all_completed() -> void:
	emit_signal("finished_movement")
