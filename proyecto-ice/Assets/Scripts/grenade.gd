extends RigidBody3D

@export var damage: int = 100
@export var arm_time: float = 0.15
@export var explosion_force: float = 0.5
@export var max_force: int = 2

@export var FloorMarkScene : PackedScene
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
	var player = get_tree().get_first_node_in_group("Player")
	var dist = global_position.distance_to(player.global_position)
	var final_force = explosion_force/dist
	print(final_force)
	if final_force > max_force:
		final_force = max_force
	player.vibrate_camera(final_force)
	for obj in bodies:
		if obj.is_in_group("Enemy"):
			obj.death_by_granade()
	print("Explotó granada")
	var floor_mark = FloorMarkScene.instantiate()
	get_tree().current_scene.add_child(floor_mark)
	floor_mark.global_position = global_position
	queue_free()
