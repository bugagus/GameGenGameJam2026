extends MeshInstance3D

var time = 0.0

func _process(delta):
	rotate_y(0.2 * delta)
	time += delta
	position.y = sin(time * 3.0) * 0.05
