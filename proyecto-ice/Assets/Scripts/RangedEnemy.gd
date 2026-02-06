class_name RangedEnemy
extends CharacterBody3D
signal died

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@export var bullet_scene : PackedScene

var max_health : int = 50
var current_health : int = 50

@export var attack_range = 20.0
@export var attack_cooldown_time = 1.5
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

func attempt_to_kill_player():
	var dist = global_position.distance_to(player.global_position)
	if dist < attack_range and can_attack:
		perform_attack()

func perform_attack():
	can_attack = false
	navigation_agent.set_move_speed(0)
	velocity = Vector3.ZERO
	animated_sprite_3d.play("attack")
	spawn_bullet()
	await animated_sprite_3d.animation_finished
	await get_tree().create_timer(attack_cooldown_time).timeout
	navigation_agent.set_move_speed(move_speed)
	can_attack = true

func spawn_bullet():
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	var spawn_pos = global_position + Vector3(0, 1.0, 0)
	bullet.global_position = spawn_pos
	bullet.look_at(player.global_position)

func die():
	dead = true
	ScoreManager.add_score(score_value)
	$AudioStreamPlayer3D.stop()
	animated_sprite_3d.play("death")
	$CollisionShape3D.set_deferred("disabled", true)
	emit_signal("died", self)
	await animated_sprite_3d.animation_finished
	queue_free()

func death_by_granade() -> void:
	dead = true
	ScoreManager.add_score(score_value)
	TimeManager.add_time(time_value)
	$AudioStreamPlayer3D.stop()
	navigation_agent.set_move_speed(0)
	animated_sprite_3d.play("death_granade")
	$CollisionShape3D.set_deferred("disabled", true)
	emit_signal("died", self)
	await animated_sprite_3d.animation_finished
	queue_free()

func take_damage(damage_taken) -> void:
	current_health = current_health - damage_taken
	if current_health <= 0:
		die()
