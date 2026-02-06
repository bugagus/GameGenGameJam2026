class_name Player
extends CharacterBody3D

@export var mouse_sensitivity: float = 0.05

const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

const WEAPON_AMP = 4.0
var default_weapon_pos = Vector2.ZERO
var default_hand_pos = Vector2.ZERO

@onready var cara: AnimatedSprite2D = $"../HUD/Cara"
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var weapon_holder: Control = $Pistol/CanvasLayer/Control
@onready var health: Label = $"../CanvasLayer/Health"
@onready var niño: AnimatedSprite2D = $"../CanvasLayer/Niño"

var is_carrying: bool = false
var max_health : int = 100
var current_health : int = 100
var granades: int = 3
var vibration_force: float = 0

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var head: Node3D = $Head
@onready var Anima: AnimatedSprite2D = $Pistol/CanvasLayer/Control/AnimatedSprite2D
@onready var movement_input_component : MovementInputComponent = MovementInputComponent.new()
@export var movement_component : MovementComponent = null
var dead = false

@export var coyote_frames := 6
@export var points_kid_delivery:= 100
@export var points_kid_pick:= 100

@export var time_kid_delivery:= 10
@export var time_kid_pick:= 10

var coyote := false
var last_floor := false
var jumping := false

var max_shoot_distance: float = 100.0
var max_damage : float = 50.0
@export var jump_cut_multiplier := 0.5
@export var jump_buffer_frames := 6

var jump_buffer := false

@export var fall_cam_offset := -0.25
@export var cam_lerp_speed := 8.0
@export var dash_cam_tilt := 4.0

@export var hard_landing_threshold := -20.0

var can_shoot : bool = true

var grenade = preload("res://Scenes/Grenade.tscn") 
var can_throw = true

@onready var damage_overlay: ColorRect = $"../HUD/DamageOverlay"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health.text = str(current_health)
	$CoyoteTimer.wait_time = coyote_frames / 60.0
	$JumpBufferTimer.wait_time = jump_buffer_frames  / 60.0
	default_weapon_pos = $Pistol/CanvasLayer/Control.position
	default_hand_pos = $"../CanvasLayer/Niño".position

func _process(delta):
	if vibration_force > 0.01:
		camera_3d.h_offset = randf_range(-vibration_force, vibration_force)
		camera_3d.v_offset = randf_range(-vibration_force, vibration_force)
		vibration_force = lerp(vibration_force, 0.0, 5.0 * delta)
	else:
		camera_3d.h_offset = 0
		camera_3d.v_offset = 0
	if Input.is_action_just_pressed("Disparo"):
		shoot()

func _physics_process(delta: float) -> void:
	if dead:
		return
	handle_gravity(delta)
	
	head.position.y = lerp(head.position.y, 0.0, cam_lerp_speed * delta)
	
	if not movement_component.is_dashing and Input.is_action_just_released("Saltar") and velocity.y > 0.0:
		velocity.y *= jump_cut_multiplier
	
	movement_component.handle_movement_state()
	
	if movement_input_component.get_dash_input():
		movement_component.start_dash(self, movement_input_component.get_movement_input())
	
	movement_component.update_dash(self, delta)
	var target_tilt := 0.0

	if movement_component.is_dashing:
		target_tilt = dash_cam_tilt * sign(movement_component.dash_direction.x)
	head.rotation.z = lerp(head.rotation.z, deg_to_rad(target_tilt), 10.0 * delta)
	
	movement_component.handle_acceleration(self, movement_input_component.get_movement_input())
	
	if movement_input_component.get_jump_input():
		jump_buffer = true
		$JumpBufferTimer.start()

	if jump_buffer and (is_on_floor() or coyote):
		movement_component.handle_jump(self, true)
		jumping = true
		jump_buffer = false
		coyote = false
	else:
		jumping = false
	
	var prev_velocity_y = velocity.y
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	$Head/Camera3D.transform.origin = _headbob(t_bob)
	$Pistol/CanvasLayer/Control.position = default_weapon_pos + _weaponbob(t_bob)
	$"../CanvasLayer/Niño".position = default_hand_pos + _weaponbob(t_bob)

	
	move_and_slide()
	
	if is_on_floor() and not last_floor:
		if prev_velocity_y < hard_landing_threshold:
			head.position.y = fall_cam_offset
		coyote = true 
		$CoyoteTimer.start()
	
	if not is_on_floor() and last_floor and not jumping:
		coyote = true
		$CoyoteTimer.start()

	last_floor = is_on_floor()
	
	grenade_throw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	movement_component.set_movement_state(movement_input_component.get_walk_input(), movement_input_component.get_sprint_input())

func handle_gravity(delta: float) -> void:
	if is_on_floor():
		return

	velocity += get_gravity() * delta

		
func die() -> void:
	#dead = true
	dead = false

func take_damage(damage_taken) -> void:
	add_health(-damage_taken)
	if current_health <= 0:
		die()
	elif current_health  <  25:
		cara.animation = "25"
	elif current_health  <  50:
		cara.animation = "50"
	elif current_health  <  75:
		cara.animation = "75"

func add_health(added_health) -> void:
	if current_health + added_health < max_health:
		current_health += added_health
	else:
		current_health = max_health
	health.text = str(current_health)
	
		
func shoot():
	if can_shoot:
		Anima.animation = "Shoot"
		can_shoot = false
		Anima.frame = 0 
		Anima.play()
		if has_node("ShootSound"):
			$ShootSound.play()    
			
		if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("take_damage"):
			if ray_cast_3d.get_collider().has_method("take_damage"):
				var distance = ray_cast_3d.global_position.distance_to(ray_cast_3d.get_collider().global_position)
				var damage_multiplier = 1.0 - (distance/max_shoot_distance)
				var damage = max_damage * damage_multiplier
				ray_cast_3d.get_collider().take_damage(damage)
				print("Disparo a agente guarro")
			else:
				print("Disparo a mierdon")
		
		$ShootSound.play()
		await Anima.animation_finished
		Anima.play("Idle")
		can_shoot = true
	
func _on_coyote_timer_timeout() -> void:
	coyote = false
	
func _on_jump_buffer_timer_timeout() -> void:
	jump_buffer = false

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func _weaponbob(time) -> Vector2:
	var pos = Vector2.ZERO
	pos.y = sin(time * BOB_FREQ) * WEAPON_AMP
	pos.x = cos(time * BOB_FREQ / 2) * WEAPON_AMP
	return pos

func grenade_throw():
	if Input.is_action_just_pressed("Granada") and can_throw and granades > 0:
		var grenadeins = grenade.instantiate()
		grenadeins.global_position = $Head/GrenadePos.global_position
		get_tree().current_scene.add_child(grenadeins)
		can_throw = false
		$ThrowTimer.start()
		granades -= 1
		var force = 18
		var up_force = 3.5
		var direction = -$Head.global_transform.basis.z.normalized()
		grenadeins.launch(force, up_force, direction)
		
	elif granades == 0:
		granades = granades

func pickup_kid():
	is_carrying = true
	ScoreManager.add_score(points_kid_pick)
	TimeManager.add_time(time_kid_pick)
	niño.play("Con")
	print("llevo al crio")
	
func deliver_kid():
	is_carrying = false
	ScoreManager.add_score(points_kid_delivery)
	TimeManager.add_time(time_kid_delivery)
	niño.play("Sin")
	print("llevo al crio")

func _on_throw_timer_timeout() -> void:
	can_throw = true
	
func add_granade():
	if granades < 3:
		granades+=1
		
func vibrate_camera(force):
	vibration_force = force
