extends State
class_name Attacking


@onready var enemy : CharacterBody3D = get_parent().get_parent()
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
@export var pursuit_limit_range := 18.0

	
func enter():
	enemy.navigation_agent.set_target(player.global_position)

func physics_update(_delta: float):
	enemy.navigation_agent.set_target(player.global_position)
	enemy.attempt_to_kill_player()
	var dist = enemy.global_position.distance_to(player.global_position)
	if dist > pursuit_limit_range and can_see_player() == false:
		print("Intentamos cambiar a idle")
		Transitioned.emit(self, "Idle")

func can_see_player() -> bool:
	var space_state = enemy.get_world_3d().direct_space_state
	var origin = enemy.global_position + Vector3(0, 1, 0)
	var target = player.global_position + Vector3(0, 1, 0)
	var query = PhysicsRayQueryParameters3D.create(origin, target)
	query.exclude = [enemy.get_rid()]
	var result = space_state.intersect_ray(query)
	if result:
		if result.collider == player:
			return true
	return false
