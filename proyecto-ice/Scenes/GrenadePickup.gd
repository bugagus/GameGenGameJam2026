extends Area3D

@export var health: float = 50.0
var time = 0.0
func _process(delta: float) -> void:
	time += delta
	position.y = sin(time * 2.0) * 0.1
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.granades < 3:
			body.add_granade()
			queue_free()
