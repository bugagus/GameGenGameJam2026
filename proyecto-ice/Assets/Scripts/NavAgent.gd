class_name NavAgent
extends NavigationAgent3D

var move_speed = 2.0
@onready var actor: CharacterBody3D = get_parent()

var active = false 

func _physics_process(_delta):
	if not active or is_navigation_finished():
		actor.velocity = Vector3.ZERO
		return
		
	var next_location = get_next_path_position()
	var current_location = actor.global_transform.origin
	var direction = (next_location - current_location).normalized()
	var new_velocity = direction * move_speed
	actor.velocity = actor.velocity.move_toward(new_velocity, 0.25)
	
	actor.move_and_slide()
	
func set_target(target):
	target_position = target
	active = true
	
func stop():
	active = false
	actor.velocity = Vector3.ZERO
	
func set_move_speed(speed):
	move_speed = speed
