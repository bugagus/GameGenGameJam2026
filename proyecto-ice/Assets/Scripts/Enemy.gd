class_name Enemy
extends CharacterBody3D


@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@export var death_effect_scene: PackedScene 
@export var grenade_pickup_scene: PackedScene

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

@export var score_value: int = 100
@export var time_value: int = 10

func _ready():
	navigation_agent.set_move_speed(move_speed)
	
func _physics_process(delta):
	if dead:
		return
	if player == null:
		return 
		
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	update_movement_animation()

func update_movement_animation():
	if not can_attack or animated_sprite_3d.animation == "damage":
		return
	var horizontal_velocity = Vector2(velocity.x, velocity.z)
	if horizontal_velocity.length() > 0.1:
		if animated_sprite_3d.animation != "walk":
			animated_sprite_3d.play("walk")
	else:
		if animated_sprite_3d.animation != "idle":
			animated_sprite_3d.play("idle")

func attempt_to_kill_player():
	var dist = global_position.distance_to(player.global_position)
	if dist < attack_range and can_attack:
		perform_attack()

func perform_attack():
	can_attack = false
	navigation_agent.set_move_speed(0)
	velocity = Vector3.ZERO
	animated_sprite_3d.play("attack")
	player.take_damage(attack_damage)
	await animated_sprite_3d.animation_finished
	animated_sprite_3d.play("idle")
	await get_tree().create_timer(attack_cooldown_time).timeout
	navigation_agent.set_move_speed(move_speed)
	can_attack = true

func die():
	if dead: 
		return
	dead = true
	if death_effect_scene:
		var effect = death_effect_scene.instantiate()
		effect.global_transform = global_transform
		get_tree().current_scene.add_child(effect)
	$CollisionShape3D.set_deferred("disabled", true)
	ScoreManager.add_score(score_value)
	TimeManager.add_time(time_value)
	$AudioStreamPlayer3D.stop()
	navigation_agent.set_move_speed(0)
	velocity = Vector3.ZERO
	animated_sprite_3d.play("death")
	granade_drop()
	queue_free()

func take_damage(damage_taken) -> void:
	if dead:
		return
	current_health = current_health - damage_taken
	if current_health <= 0 and !dead:
		die()
	else:
		if !dead:
			animated_sprite_3d.play("damage")
			await animated_sprite_3d.animation_finished
			animated_sprite_3d.play("idle")
		
func death_by_granade() -> void:
	if dead: 
		return
	dead = true
	$CollisionShape3D.set_deferred("disabled", true)
	ScoreManager.add_score(score_value)
	TimeManager.add_time(time_value)
	$AudioStreamPlayer3D.stop()
	navigation_agent.set_move_speed(0)
	velocity = Vector3.ZERO
	animated_sprite_3d.play("death_granade")
	granade_drop()
	await animated_sprite_3d.animation_finished
	queue_free()

func granade_drop():
		var granadiña = grenade_pickup_scene.instantiate()
		granadiña.global_position = global_position + Vector3(0, -0.4, 0)
		get_tree().current_scene.add_child(granadiña)
