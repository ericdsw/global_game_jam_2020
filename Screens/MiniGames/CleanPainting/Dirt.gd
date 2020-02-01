extends Sprite

onready var sprite_dirt : Sprite = get_node(".")
onready var anim_p : AnimationPlayer = get_node("AnimationPlayer")

var opacity : float = 1
var dirt_hp : float = 1
var area_check : bool = false
var cleaned : bool = false

signal ruined_painting()

func _process(delta) -> void:
	if area_check == true:
		dirt_hp =  dirt_hp - (delta * 2)
		
		sprite_dirt.modulate = Color(1,1,1,opacity)
		if dirt_hp >= 0 and !cleaned:
			opacity = opacity - (delta * 2)
		elif dirt_hp <= 0 and !cleaned:
			cleaned = true
			print("opacity", opacity)
			print("hp", dirt_hp)
			opacity = 1
			anim_p.play("cleaned")
		elif dirt_hp <= -0.4:
			anim_p.play("ruin")
			emit_signal("ruined_painting")

func _on_Area2D_area_entered(area):
	if area.is_in_group("Cleaning"):
		area_check = true

func _on_Area2D_area_exited(area):
	area_check = false

