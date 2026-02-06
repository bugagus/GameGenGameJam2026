extends Label

func _ready() -> void:
	text = "Score: 0"
	ScoreManager.score_changed.connect(_on_score_changed)

func _on_score_changed(new_score: int) -> void:
	text = "Score: %d" % new_score
	_vibrate()

func _vibrate() -> void:
	var original_pos = position
	var t = create_tween() 

	for i in range(4):
		var offset = Vector2(randf_range(-5,5), randf_range(-5,5))
		t.tween_property(self, "position", original_pos + offset, 0.05).as_relative()
	
	t.tween_property(self, "position", original_pos, 0.05)
