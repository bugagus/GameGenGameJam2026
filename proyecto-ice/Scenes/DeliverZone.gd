extends Area3D

@export var tiempo_extra: float = 10.0
@export var puntuacion_extra: int = 500

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if body.is_carrying == true:
			body.deliver_kid()
			print("estoy hasta los cojones son las 4:08 de la mañana y aqui sigo")
			if has_node("AudioStreamPlayer3D"):
				$AudioStreamPlayer3D.play()
