class_name Player
extends CharacterBody3D

const mouse_sensitivity : float = 0.05

@onready var head: Node3D = $Head
@onready var Anima: AnimatedSprite2D = $Pistol/CanvasLayer/Control/AnimatedSprite2D
@onready var movement_input_component : MovementInputComponent = MovementInputComponent.new()
@export var movement_component : MovementComponent = null
var dead = false

func _physics_process(delta: float) -> void:
	if dead:
		return
	handle_gravity(delta)
	
	movement_component.handle_movement_state()
	
	if movement_input_component.get_dash_input():
		movement_component.start_dash(self, movement_input_component.get_movement_input())

	movement_component.update_dash(self, delta)
	
	movement_component.handle_acceleration(self, movement_input_component.get_movement_input())
	if is_on_floor():
		movement_component.handle_jump(self, movement_input_component.get_jump_input())
	
	move_and_slide()

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
	Anima.play()
	$ShootSound.play()
