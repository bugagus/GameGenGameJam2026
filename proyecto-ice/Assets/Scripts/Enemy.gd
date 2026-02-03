extends CharacterBody3D

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

@export var move_speed = 2.0
@export var attack_range = 2.0

@export var navigation_agent: NavAgent
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")

var gravity = 9.8
var dead = false
	
func _physics_process(delta):
	
	if dead:
		return
	if player == null:
		return 
	if not is_on_floor():
		velocity.y -= gravity * delta

	navigation_agent.set_target(player.global_position)
	attempt_to_kill_player()
	
func attempt_to_kill_player():
	var dist_to_player = global_position.direction_to(player.global_position)
	if dist_to_player.length() < attack_range:
		player.kill()
	
func kill():
	dead = true
	$AudioStreamPlayer3D.disabled = true
	animated_sprite_3d.play("death")
	$CollisionShape3D.disabled = true	
