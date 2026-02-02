extends CharacterBody3D

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

@export var move_speed = 2.0
@export var attack_range = 2.0

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

var gravity = 9.8
var dead = false

func _ready() -> void:
	target_position(player.position)
	
func _physics_process(delta):
	
	if dead:
		return
		
	if player == null:
		return 
		
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var next_location = navigation_agent_3d.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * move_speed
	
	velocity = velocity.move_toward(new_velocity, 0.25)
	move_and_slide()
	attempt_to_kill_player()
	
func attempt_to_kill_player():
	var dist_to_player = global_position.direction_to(player.global_position)
	if dist_to_player.length() > attack_range:
		return
	
	var eye_line = Vector3.UP * 1.5
	var query = PhysicsRayQueryParameters3D.create(global_position+eye_line, player.global_position+eye_line, 1)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		player.kill()
	
func target_position(target):
	navigation_agent_3d.target_position = target
	
func kill():
	dead = true
	$AudioStreamPlayer3D.disabled = true
	animated_sprite_3d.play("death")
	$CollisionShape3D.disabled = true	
