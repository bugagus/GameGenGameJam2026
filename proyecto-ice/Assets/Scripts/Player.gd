class_name Player
extends CharacterBody3D

const mouse_sensitivity : float = 0.05

@onready var head: Node3D = $Head
@onready var Anima: AnimatedSprite2D = $Pistol/CanvasLayer/Control/AnimatedSprite2D
@onready var movement_input_component : MovementInputComponent = MovementInputComponent.new()
@export var movement_component : MovementComponent = null
var dead = false

@export var coyote_frames := 6

var coyote := false
var last_floor := false
var jumping := false

@export var jump_cut_multiplier := 0.35
@export var jump_buffer_frames := 6

var jump_buffer := false

@export var fall_gravity_multiplier := 2.2
@export var low_jump_gravity_multiplier := 1.6

@export var fall_cam_offset := -0.5
@export var cam_lerp_speed := 8.0
@export var dash_cam_tilt := 4.0

func _ready() -> void:
	$CoyoteTimer.wait_time = coyote_frames / 60.0
	$JumpBufferTimer.wait_time = jump_buffer_frames  / 60.0


func _physics_process(delta: float) -> void:
	if dead:
		return
	handle_gravity(delta)
	
	var target_y := 0.0

	if velocity.y < -1.0:
		target_y = fall_cam_offset

	head.position.y = lerp(head.position.y, target_y, cam_lerp_speed * delta)

	
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
	var jump_input := movement_input_component.get_jump_input()

	if jump_buffer and (is_on_floor() or coyote):
		movement_component.handle_jump(self, true)
		jumping = true
		jump_buffer = false
		coyote = false
	else:
		jumping = false
	
	move_and_slide()
	
	if not is_on_floor() and last_floor and not jumping:
		coyote = true
		$CoyoteTimer.start()

	last_floor = is_on_floor()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	movement_component.set_movement_state(movement_input_component.get_walk_input(), movement_input_component.get_sprint_input())

func handle_gravity(delta: float) -> void:
	if is_on_floor():
		return

	var gravity := get_gravity().y

	# Cayendo → más gravedad
	if velocity.y < 0.0:
		velocity.y += gravity * fall_gravity_multiplier * delta
	# Subiendo pero soltaste el botón → salto corto más rápido
	elif velocity.y > 0.0 and not Input.is_action_pressed("Saltar"):
		velocity.y += gravity * low_jump_gravity_multiplier * delta
	# Subida normal
	else:
		velocity.y += gravity * delta

		
func kill() -> void:
	var i = 0
	
func _process(_delta) -> void:
	if Input.is_action_just_pressed("Disparo"):
		shoot()
		
func shoot():
	Anima.animation = "Shoot"
	Anima.frame = 0 
	Anima.play()
	if has_node("ShootSound"):
		$ShootSound.play()    
		
	var camera = get_viewport().get_camera_3d()
	
	var from = camera.global_position
	var to = from - camera.global_transform.basis.z * 100.0

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	query.exclude = [self.get_rid()] 
	
	var result = space_state.intersect_ray(query)

	if result:
		var collider = result.collider
		
		if collider.has_method("kill"):
			print("Disparo acertado a: ", collider.name)
			collider.kill()
		else:
			print("Disparo a pared/objeto: ", collider.name)
	$ShootSound.play()
	
func _on_coyote_timer_timeout() -> void:
	coyote = false
	
func _on_jump_buffer_timer_timeout() -> void:
	jump_buffer = false
