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
	if dist > pursuit_limit_range:
		print("Intentamos cambiar a idle")
		Transitioned.emit(self, "Idle")
