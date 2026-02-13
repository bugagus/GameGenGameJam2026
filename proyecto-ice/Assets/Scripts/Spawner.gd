extends Node3D
class_name EnemySpawner

@export var enemy_scenes: Array[PackedScene] = [] 
@export var max_slots: int = 4
@export var spawn_radius: float = 5.0
@export var spawn_interval: float = 2.0
@export var min_player_distance: float = 10.0

var active_enemies: Array = []

func _ready():
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(timer)
	
	_on_spawn_timer_timeout()

func _on_spawn_timer_timeout():
	active_enemies = active_enemies.filter(func(enemy): return is_instance_valid(enemy))
	
	if active_enemies.size() >= max_slots:
		return
	
	if enemy_scenes.is_empty():
		return
		
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance < min_player_distance:
			return
	spawn_enemy()

func spawn_enemy():
	var enemy_scene = enemy_scenes.pick_random()
	var enemy_instance = enemy_scene.instantiate()

	get_tree().current_scene.add_child.call_deferred(enemy_instance)

	var offset = Vector3(
		randf_range(-spawn_radius, spawn_radius),
		0,
		randf_range(-spawn_radius, spawn_radius)
	)
	enemy_instance.global_position = global_position + offset

	active_enemies.append(enemy_instance)
	enemy_instance.tree_exited.connect(_on_enemy_exited.bind(enemy_instance))

func _on_enemy_exited(enemy):
	if active_enemies.has(enemy):
		active_enemies.erase(enemy)
