extends Area3D

@export var health: float = 50.0
var time = 0.0
var spawn_y: float = 0.0
var first_frame: bool = true
func _process(delta: float) -> void:
	if first_frame:
		spawn_y = global_position.y
		first_frame = false
	time += delta
	global_position.y = spawn_y + (sin(time * 2.0) * 0.05)
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.granades < 3:
			body.add_granade()
			queue_free()
