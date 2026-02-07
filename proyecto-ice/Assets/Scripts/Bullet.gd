extends Area3D

@export var bullet_speed: float = 20.0
@export var bullet_damage: int = 10
@export var max_lifetime: float = 5.0

var timer = 0.0

func _physics_process(delta: float) -> void:
	position -= transform.basis.z * bullet_speed * delta
	timer += delta
	if timer >= max_lifetime:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(bullet_damage)
		queue_free()
	elif not body.is_in_group("Enemy"): 
		queue_free()
