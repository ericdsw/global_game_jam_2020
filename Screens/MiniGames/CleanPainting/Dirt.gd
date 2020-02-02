extends Sprite

onready var sprite_dirt : Sprite = get_node(".")
onready var anim_p : AnimationPlayer = get_node("AnimationPlayer")

onready var spot_1 : Texture = preload("res://Resources/CleanPainting/SpotT1.png")
onready var spot_2 : Texture = preload("res://Resources/CleanPainting/SpotT2.png")
onready var spot_3 : Texture = preload("res://Resources/CleanPainting/SpotT3.png")
onready var spot_4 : Texture = preload("res://Resources/CleanPainting/SpotT4.png")
onready var spot_5 : Texture = preload("res://Resources/CleanPainting/SpotT5.png")
onready var spot_6 : Texture = preload("res://Resources/CleanPainting/SpotT6.png")
onready var rip : Texture = preload("res://Resources/CleanPainting/SpotT7.png")

var spots_array : Array
var spots_thresholds : Array
var current_spot : int = 0

var dirt_hp : float = 1
var area_check : bool = false
var cleaned : bool = false

export var rinse_threshold : float = 0.4

signal ruined_painting()
signal cleaned()

func _ready() -> void:
	spots_array = [spot_1, spot_2, spot_3, spot_4, spot_5, spot_6]
	texture = spots_array[current_spot]
	_set_up_spot_thresholds()

func _set_up_spot_thresholds() -> void:
	for i in range(7):
		spots_thresholds.append(1.0 - i/6.0)

func _process(delta) -> void:
	if area_check == true:
		dirt_hp =  dirt_hp - (delta * 1.2)
		
		if dirt_hp <= 0 and !cleaned:
			cleaned = true
#			anim_p.play("cleaned")
		elif dirt_hp <= -rinse_threshold:
			texture = rip
			scale = Vector2(0.5, 0.5)
			emit_signal("ruined_painting")

func _on_Area2D_area_entered(area):
	if area.is_in_group("Cleaning"):
		area_check = true
		
		anim_p.play("cleaning")
		
		# clicking dirt after it has been cleaned should not clean it further.
		if rinse_threshold > -dirt_hp and dirt_hp <= 0:
			area_check = false
			emit_signal("cleaned")

func _on_Area2D_area_exited(area):
	area_check = false
	
	if area.is_in_group("Cleaning"):
		anim_p.stop(false)
	# when letting go of "scrub", send signal it was cleaned
		if rinse_threshold > -dirt_hp and dirt_hp <= 0:
			emit_signal("cleaned")
			queue_free()

