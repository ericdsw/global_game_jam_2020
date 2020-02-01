extends Sprite

onready var sprite_dirt : Sprite = get_node(".")
var opacity : float = 1
var dirt_hp : float = 1
var area_check : bool = false



func _process(delta) -> void:
	if area_check == true:
		dirt_hp =  dirt_hp - (delta * 2)
		
		sprite_dirt.modulate = Color(1,1,1,opacity)
		opacity = opacity - (delta * 2)
		
		if dirt_hp <= 0:
			print("opacity", opacity)
			print("hp", dirt_hp)
			sprite_dirt.queue_free()

func _on_Area2D_area_entered(area):
	if area.is_in_group("Cleaning"):
		area_check = true

func _on_Area2D_area_exited(area):
	area_check = false

