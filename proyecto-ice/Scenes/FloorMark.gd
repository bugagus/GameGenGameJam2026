extends Decal

func _ready():
	await get_tree().create_timer(10).timeout
	var tween = create_tween()
	tween.tween_property(self, "albedo_mix", 0.0, 2.0)
	tween.tween_callback(queue_free)
