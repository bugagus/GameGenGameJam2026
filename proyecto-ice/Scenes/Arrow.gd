extends Node3D

@export var target_node: Node3D 
@export var tamaño_final: Vector3 = Vector3(0.1, 0.1, 0.1)

func _process(_delta: float) -> void:
	if target_node == null:
		return
	look_at(target_node.global_position, Vector3.UP)
	rotation.x = 0
	rotation.z = 0

func set_new_target(new_target: Node3D):
	target_node = new_target
	var t = create_tween().set_trans(Tween.TRANS_BACK)
	if new_target != null:
		visible = true
		t.set_ease(Tween.EASE_OUT)
		t.tween_property(self, "scale", tamaño_final, 0.3) 
		
	else:
		t.set_ease(Tween.EASE_IN)
		t.tween_property(self, "scale", Vector3.ZERO, 0.3)
		await t.finished
		visible = false
