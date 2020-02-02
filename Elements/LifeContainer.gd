extends HBoxContainer
class_name LifeContainer

onready var lives := get_children()
onready var tween := get_node("Tween")

func display_available_lives(amount: int) -> void:
	for i in range(lives.size()):
		if i < amount:
			lives[i].rect_scale = Vector2(1,1)
		else:
			tween.interpolate_property(
				lives[i], "rect_scale", lives[i].rect_scale, Vector2(), 0.3,
				Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT
			)
			tween.start()

func reset() -> void:
	tween.stop_all()
	for life in lives:
		life.rect_scale = Vector2(1,1)
