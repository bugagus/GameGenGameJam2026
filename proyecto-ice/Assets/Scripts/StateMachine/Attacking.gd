extends State
class_name Attacking


@onready var enemy : CharacterBody3D = get_parent().get_parent()
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")

func enter():
	enemy.navigation_agent.set_target(player.global_position)

func physics_process(_delta: float):
	enemy.navigation_agent.set_target(player.global_position)
	enemy.attempt_to_kill_player()
