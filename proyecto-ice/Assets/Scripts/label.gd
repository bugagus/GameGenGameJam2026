extends Label

func _ready() -> void:
	text = "0"
	ScoreManager.score_changed.connect(_on_score_changed)

func _on_score_changed(new_score: int) -> void:
	text = "%d" % new_score
	_vibrate()

func _vibrate() -> void:
	var original_pos = position
	var t = create_tween() 
	
	t.set_trans(Tween.TRANS_SINE)
	t.set_ease(Tween.EASE_IN_OUT)
	
	for i in range(4):
		var offset = Vector2(randf_range(-5,5), randf_range(-5,5))
		t.tween_property(self, "position", original_pos + offset, 0.05)
	
	t.tween_property(self, "position", original_pos, 0.05)


func _on_time_label_time_changed(current_time: float) -> void:
	pass # Replace with function body.
