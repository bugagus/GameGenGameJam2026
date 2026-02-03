class_name MovementComponent
extends Node

@export var base_speed : float = 5.0
@export var sprint_speed : float = 8.0
@export var walk_speed : float = 3.0
@export var jump_height : float = 6.5

@export var dash_speed := 20.0
@export var dash_duration := 0.25
@export var dash_cooldown := 1.0

var current_speed : float = 0.0

var is_dashing := false
var dash_time := 0.0
var dash_direction := Vector3.ZERO
var can_dash := true

enum movement_states {Neutral, Walking, Sprinting, Dashing}

var current_movement_state : movement_states = movement_states.Neutral

func handle_movement_state() -> void:
	match current_movement_state:
		movement_states.Neutral:
			current_speed = base_speed
		movement_states.Walking:
			current_speed = walk_speed
		movement_states.Sprinting:
			current_speed = sprint_speed
		movement_states.Dashing:
			current_speed = dash_speed

func set_movement_state(is_walking : bool, is_sprinting: bool) -> void:
	if is_walking:
		current_movement_state = movement_states.Walking
	elif is_sprinting:
		current_movement_state = movement_states.Sprinting
	else:
		current_movement_state = movement_states.Neutral

func handle_acceleration(entity : CharacterBody3D, target_direction: Vector2) -> void:
	var direction : Vector3 = (entity.transform.basis * Vector3(target_direction.x, 0, target_direction.y))
	
	direction.normalized()
	
	if direction:
		entity.velocity.x = direction.x * current_speed
		entity.velocity.z = direction.z * current_speed
	else:
		entity.velocity.x = move_toward(entity.velocity.x, 0, current_speed)
		entity.velocity.z = move_toward(entity.velocity.z, 0, current_speed)

func handle_jump(entity : CharacterBody3D, is_jumping : bool) -> void:
	if is_jumping:
		entity.velocity.y = jump_height
		

func start_dash(entity: CharacterBody3D, input: Vector2) -> void:
	if not can_dash or input == Vector2.ZERO:
		return
	
	is_dashing = true
	can_dash = false
	dash_time = 0.0
	current_movement_state = movement_states.Dashing
	dash_direction = (entity.transform.basis * Vector3(input.x, 0, input.y)).normalized()

func update_dash(entity: CharacterBody3D, delta: float) -> void:
	if not is_dashing:
		return
	
	dash_time += delta
	var t := dash_time / dash_duration
	t = clamp(t, 0.0, 1.0)
	#var strength: float = dash_speed * sin((1.0 - t) * PI * 0.5)
	var strength := dash_speed * sin(t * PI)


	entity.velocity.x = dash_direction.x * strength
	entity.velocity.z = dash_direction.z * strength
	if t >= 1.0:
		end_dash()
		
func end_dash() -> void:
	is_dashing = false
	current_movement_state = movement_states.Neutral
	
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true
