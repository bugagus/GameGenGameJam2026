extends Label

func _ready() -> void:
	text = "Score: 0"
	ScoreManager.score_changed.connect(_on_score_changed)

func _on_score_changed(new_score: int) -> void:
	text = "Score: %d" % new_score
