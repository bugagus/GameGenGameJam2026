class_name Player
extends CharacterBody3D

const mouse_sensitivity : float = 0.05

var max_health : int = 100
var current_health : int = 100

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var head: Node3D = $Head
@onready var Anima: AnimatedSprite2D = $Pistol/CanvasLayer/Control/AnimatedSprite2D
@onready var movement_input_component : MovementInputComponent = MovementInputComponent.new()
@export var movement_component : MovementComponent = null
var dead = false

@export var coyote_frames := 6

var coyote := false
var last_floor := false
var jumping := false

var max_shoot_distance: float = 100.0
var max_damage : float = 50.0

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
		
func die() -> void:
	#dead = true
	dead = false

func take_damage(damage_taken) -> void:
	current_health = current_health - damage_taken
	if current_health <= 0:
		die()
	
func _process(_delta) -> void:
	if Input.is_action_just_pressed("Disparo"):
		shoot()
		
func shoot():
	Anima.animation = "Shoot"
	Anima.frame = 0 
	Anima.play()
	if has_node("ShootSound"):
		$ShootSound.play()    
		
	if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("take_damage"):
		if ray_cast_3d.get_collider().has_method("take_damage"):
			var distance = ray_cast_3d.position.distance_to(ray_cast_3d.get_collider().position)
			var damage_multiplier = 1.0 - (distance/max_shoot_distance)
			var damage = max_damage * damage_multiplier
			ray_cast_3d.get_collider().take_damage(damage)
			print("Disparo a agente guarro")
		else:
			print("Disparo a mierdon")
	$ShootSound.play()
	
func _on_coyote_timer_timeout() -> void:
	coyote = false
