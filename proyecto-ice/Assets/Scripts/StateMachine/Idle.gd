extends State
class_name Idle

@export var wander_radius := 5.0
@export var min_wander_time := 1.5
@export var max_wander_time := 4.0

var wander_time : float = 0.0
@onready var enemy : CharacterBody3D = get_parent().get_parent()
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")


func enter():
	enemy.animated_sprite_3d.play("idle")
	randomize_wander()
	
func update(delta: float):
	wander_time-=delta
	if wander_time < 0:
		randomize_wander()
		

func physics_update(_delta: float):
	var dist = enemy.global_position.distance_to(player.global_position)
	if can_see_player() and dist < enemy.detection_range:
		Transitioned.emit(self, "Attacking")


func randomize_wander():
	wander_time = randf_range(min_wander_time, max_wander_time)
	var random_x = randf_range(-wander_radius, wander_radius)
	var random_z = randf_range(-wander_radius, wander_radius)
	var target_pos = enemy.global_position + Vector3(random_x, 0, random_z)
	enemy.navigation_agent.set_target(target_pos)

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
