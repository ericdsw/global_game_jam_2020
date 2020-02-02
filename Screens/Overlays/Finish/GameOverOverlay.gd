extends BaseOverlay

onready var score_label := get_node("ScoreLabel") as Label

signal retry_requested()

func show_score(score: int) -> void:
	score_label.text = "%d" % score

func _on_StartButton_pressed() -> void:
	request_hide()
	yield(self, "finished")
	emit_signal("retry_requested")
