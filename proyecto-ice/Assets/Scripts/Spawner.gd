extends Node3D
class_name EnemySpawner

@export var enemy_scenes: Array[PackedScene] = [] 
@export var max_slots: int = 4
@export var spawn_radius: float = 5.0
@export var spawn_interval: float = 2.0

var active_enemies: Array = []

func _ready():
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	add_child(timer)

func _on_spawn_timer_timeout():
	if active_enemies.size() >= max_slots:
		return
	
	if enemy_scenes.is_empty():
		return
	
	var enemy_scene: PackedScene = enemy_scenes[randi() % enemy_scenes.size()]
	var enemy_instance = enemy_scene.instantiate()

	get_tree().current_scene.add_child(enemy_instance)

	var offset = Vector3(
		randf_range(-spawn_radius, spawn_radius),
		0,
		randf_range(-spawn_radius, spawn_radius)
	)
	enemy_instance.global_position = global_position + offset

	active_enemies.append(enemy_instance)

	if enemy_instance.has_signal("died"):
		enemy_instance.died.connect(Callable(self, "_on_enemy_die"))


func _on_enemy_die(enemy):
	active_enemies.erase(enemy)
