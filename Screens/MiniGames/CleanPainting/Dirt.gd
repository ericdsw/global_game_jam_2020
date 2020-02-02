extends Sprite

onready var sprite_dirt : Sprite = get_node(".")
onready var anim_p : AnimationPlayer = get_node("AnimationPlayer")

var opacity : float = 1
var dirt_hp : float = 1
var area_check : bool = false
var cleaned : bool = false

export var rinse_threshold : float = 0.4

signal ruined_painting()
signal cleaned()

func _process(delta) -> void:
	if area_check == true:
		dirt_hp =  dirt_hp - (delta * 2)
		
		sprite_dirt.modulate = Color(1,1,1,opacity)
		if dirt_hp >= 0 and !cleaned:
			opacity = opacity - (delta * 2)
		elif dirt_hp <= 0 and !cleaned:
			cleaned = true
			opacity = 1
			anim_p.play("cleaned")
		elif dirt_hp <= -rinse_threshold:
			anim_p.play("ruin")
			emit_signal("ruined_painting")

func _on_Area2D_area_entered(area):
	if area.is_in_group("Cleaning"):
		area_check = true
		
		# clicking dirt after it has been cleaned should not clean it further.
		if rinse_threshold > -dirt_hp and dirt_hp <= 0:
			area_check = false
			emit_signal("cleaned")

func _on_Area2D_area_exited(area):
	area_check = false
	
	if area.is_in_group("Cleaning"):
	# when letting go of "scrub", send signal it was cleaned
		if rinse_threshold > -dirt_hp and dirt_hp <= 0:
			emit_signal("cleaned")
			queue_free()

