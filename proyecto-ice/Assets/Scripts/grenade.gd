extends RigidBody3D

@export var damage: int = 50
@export var arm_time: float = 0.15

@onready var explosion_area: Area3D = $Radius

var armed: bool = false

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1
	await get_tree().create_timer(arm_time).timeout
	armed = true

func launch(force: float, up_force: float, direction: Vector3) -> void:
	apply_central_impulse(direction.normalized() * force + Vector3.UP * up_force)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if armed and state.get_contact_count() > 0:
		explode()

func explode() -> void:
	var bodies = explosion_area.get_overlapping_bodies()
	for obj in bodies:
		if obj.is_in_group("Enemy"):
			obj.take_damage(damage)
	print("Explotó granada")
	queue_free()
