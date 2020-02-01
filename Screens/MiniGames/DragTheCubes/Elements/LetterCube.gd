extends Node2D
class_name LetterCube

onready var background_sprite := get_node("Sprite") as Sprite
onready var letter_label := get_node("Label") as Label
onready var detection_area := get_node("DetectionArea") as Area2D
onready var tween := get_node("Tween") as Tween

var assigned_letter := ""

signal finished_movement()

func get_cube_size() -> Vector2:
	return background_sprite.texture.get_size()

func show_letter(letter: String) -> void:
	assigned_letter = letter
	letter_label.text = letter

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

func _on_Tween_tween_all_completed() -> void:
	emit_signal("finished_movement")
