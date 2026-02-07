extends Sprite2D

@export var velocidad: float = 50.0
@export var distancia: float = 2.0
var contador_frames: int = 0
var time = 0.0

func _physics_process(delta: float) -> void:
	contador_frames += 1
	if contador_frames % 20:
		offset.x = sin(time * velocidad) * distancia
		offset.y = cos(time * velocidad * 1.3) * distancia
	else:
		offset = Vector2.ZERO
