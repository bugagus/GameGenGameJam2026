extends Node3D

@export var target_node: Node3D 

func _process(_delta: float) -> void:
	if target_node == null:
		return
	look_at(target_node.global_position, Vector3.UP)
	rotation.x = 0
	rotation.z = 0

func set_new_target(new_target: Node3D):
	target_node = new_target
