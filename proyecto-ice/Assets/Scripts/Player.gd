class_name Player
extends CharacterBody3D

@export var mouse_sensitivity: float = 0.05

const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0
@onready var fade_rect: ColorRect = $"../Hud/ColorRect"

const WEAPON_AMP = 4.0
var default_weapon_pos = Vector2.ZERO
var default_hand_pos = Vector2.ZERO

@onready var cara: AnimatedSprite2D = $"../Hud/Cara"
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var camera_animation_player: AnimationPlayer = $Head/Camera3D/AnimationPlayer
@onready var weapon_holder: Control = $"../Hud/Pistol"
@onready var health: Label = $"../Hud/Vida/Health"
@onready var niño: AnimatedSprite2D = $"../Hud/Niño/Niño"
@onready var pistol: Control = $"../Hud/Pistol"
@onready var crosshair_ui: Control = $"../Hud/Crosshair"
@onready var flecha_guia = $Head/Camera3D/Arrow
@onready var kid: Area3D= $"../Kid/PickupArea"
@onready var kid_script: Kid= $"../Kid"
@export var game_over_scene: PackedScene

var is_carrying: bool = false
var max_health : int = 100
var current_health : int = 100
var granades: int = 3
var vibration_force: float = 0

@onready var ray_cast_3d: RayCast3D = $Head/Camera3D/RayCast3D
@onready var head: Node3D = $Head
@onready var Anima: AnimatedSprite2D = pistol.get_node("AnimatedSprite2D")
@onready var movement_input_component : MovementInputComponent = MovementInputComponent.new()
@export var movement_component : MovementComponent = null
@onready var zona_entrega: Area3D = $"../DeliverZone"
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

@onready var granada1: Sprite2D = $"../Hud/Granadas/Granada1"
@onready var granada2: Sprite2D = $"../Hud/Granadas/Granada2"
@onready var granada3: Sprite2D = $"../Hud/Granadas/Granada3"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health.text = "%03d/%d" % [current_health, max_health]
	$CoyoteTimer.wait_time = coyote_frames / 60.0
	$JumpBufferTimer.wait_time = jump_buffer_frames  / 60.0
	default_weapon_pos = pistol.position
	default_hand_pos = niño.position
	flecha_guia.set_new_target(kid)
	update_granades()

func _process(delta):
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
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
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
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
	pistol.position = default_weapon_pos + _weaponbob(t_bob)
	niño.position = default_hand_pos + _weaponbob(t_bob)

	
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
	if dead: return
	dead = true
	
	if fade_rect:
		fade_rect.visible = true
		fade_rect.color.a = 0.0
		
		var tween = create_tween()
		tween.tween_property(fade_rect, "color:a", 1.0, 2.0)
		
		await tween.finished

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if game_over_scene:
		get_tree().change_scene_to_packed(game_over_scene)

func take_damage(damage_taken) -> void:
	_vibrate()
	current_health -= damage_taken
	if current_health <= 0:
		die()
		current_health = 0
	elif current_health < 25:
		if cara.animation != "25":
			camera_animation_player.play("Pain")
			cara.animation = "25"
	elif current_health < 50:
		if cara.animation != "50":
			cara.animation = "50"
	elif current_health < 75:
		if cara.animation != "75":
			cara.animation = "75"
	else:
		cara.animation = "100"
	health.text = "%03d/%d" % [current_health, max_health]

func add_health(added_health) -> void:
	if current_health + added_health < max_health:
		current_health += added_health
		if current_health > 25:
			if cara.animation != "50":
				cara.animation  = "50"
		elif current_health > 50:
			if cara.animation != "75":
				cara.animation = "75"
		elif current_health > 75:
			if cara.animation != "100":
				cara.animation = "100"
	else:
		current_health = max_health
		cara.animation = "100"
	if has_node("PickUpHealth"):
		$PickUpHealth.play()   
	health.text = "%03d/%d" % [current_health, max_health]
	camera_animation_player.play("RESET")
	
		
func shoot():
	if can_shoot:
		var crosshair_center = crosshair_ui.global_position + (crosshair_ui.size / 2.0)
		var ray_origin = camera_3d.project_ray_origin(crosshair_center)
		var ray_direction = camera_3d.project_ray_normal(crosshair_center)
		var target_global_point = ray_origin + (ray_direction * max_shoot_distance)
		ray_cast_3d.target_position = ray_cast_3d.to_local(target_global_point)
		ray_cast_3d.force_raycast_update()
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
				var damage = int(max_damage * damage_multiplier)
				ray_cast_3d.get_collider().take_damage(damage)
				if has_node("HitMarkerSound"):
					$HitMarkerSound.play()   
		
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
		update_granades()
		
	elif granades == 0:
		granades = granades

func pickup_kid():
	is_carrying = true
	if has_node("PickUpKidSound"):
		$PickUpKidSound.play()    
	flecha_guia.set_new_target(zona_entrega)
	ScoreManager.add_score(points_kid_pick)
	TimeManager.add_time(time_kid_pick)
	niño.play("Con")
	print("llevo al crio")
	
func deliver_kid():
	is_carrying = false
	if has_node("DeliverSound"):
		$DeliverSound.play()   
	flecha_guia.set_new_target(kid)
	kid_script.actualizar_contador()
	ScoreManager.add_score(points_kid_delivery)
	TimeManager.add_time(time_kid_delivery)
	niño.play("Sin")
	print("llevo al crio")

func _on_throw_timer_timeout() -> void:
	can_throw = true
	
func add_granade():
	if granades < 3:
		if has_node("PickUpGranadeSound"):
			$PickUpGranadeSound.play()   
		granades+=1
		update_granades()
		
func vibrate_camera(force):
	vibration_force = force

func _vibrate() -> void:
	var original_pos = health.position
	var t = create_tween() 
	
	t.set_trans(Tween.TRANS_SINE)
	t.set_ease(Tween.EASE_IN_OUT)
	
	for i in range(4):
		var offset = Vector2(randf_range(-5,5), randf_range(-5,5))
		t.tween_property(health, "position", original_pos + offset, 0.05)
	
	t.tween_property(health, "position", original_pos, 0.05)

func update_granades() -> void:
	granada1.visible = granades >= 1
	granada2.visible = granades >= 2
	granada3.visible = granades >= 3
