class_name Enemy
extends CharacterBody3D

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

var max_health : int = 100
var current_health : int = 100

@export var attack_range = 2.0
@export var attack_cooldown_time = 1.5
@export var attack_damage = 20
@export var move_speed = 2.0
@export var navigation_agent: NavAgent
@export var detection_range: float = 25.0
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")

var gravity = 9.8
var dead = false
var can_attack = true

func _ready():
	navigation_agent.set_move_speed(move_speed)
	
func _physics_process(delta):
	if dead:
		return
	if player == null:
		return 
		
	if not is_on_floor():
		velocity.y -= gravity * delta

func attempt_to_kill_player():
	var dist = global_position.distance_to(player.global_position)
	if dist < attack_range and can_attack:
		perform_attack()

func perform_attack():
	can_attack = false
	navigation_agent.set_move_speed(0)
	velocity = Vector3.ZERO
	animated_sprite_3d.play("attack")
	await animated_sprite_3d.animation_finished
	var dist = global_position.distance_to(player.global_position)	
	if dist < attack_range and can_attack:
		player.take_damage(attack_damage)
		
	await get_tree().create_timer(attack_cooldown_time).timeout
	navigation_agent.set_move_speed(move_speed)
	can_attack = true

func die():
	dead = true
	$AudioStreamPlayer3D.stop()
	animated_sprite_3d.play("death")
	$CollisionShape3D.set_deferred("disabled", true)
	await animated_sprite_3d.animation_finished
	queue_free()

func take_damage(damage_taken) -> void:
	current_health = current_health - damage_taken
	print(current_health)
	if current_health <= 0:
		die()
