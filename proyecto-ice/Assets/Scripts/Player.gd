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

func _ready() -> void:
	$CoyoteTimer.wait_time = coyote_frames / 60.0


func _physics_process(delta: float) -> void:
	if dead:
		return
	handle_gravity(delta)
	
	movement_component.handle_movement_state()
	
	if movement_input_component.get_dash_input():
		movement_component.start_dash(self, movement_input_component.get_movement_input())

	movement_component.update_dash(self, delta)
	
	movement_component.handle_acceleration(self, movement_input_component.get_movement_input())
	var jump_input := movement_input_component.get_jump_input()

	if jump_input and (is_on_floor() or coyote):
		movement_component.handle_jump(self, true)
		jumping = true
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

func handle_gravity(delta : float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
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