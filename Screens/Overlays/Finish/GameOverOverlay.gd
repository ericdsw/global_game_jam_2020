extends BaseOverlay

onready var score_label := get_node("ScoreLabel") as Label

func show_score(score: int) -> void:
	score_label.text = "%d" % score
