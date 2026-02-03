class_name NavAgent
extends NavigationAgent3D

@export var move_speed = 2.0
@onready var actor: CharacterBody3D = get_parent()

func _physics_process(_delta):
		
	var next_location = get_next_path_position()
	print(next_location)
	var current_location = actor.global_transform.origin
	var direction = (next_location - current_location).normalized()
	var new_velocity = direction * move_speed
	actor.velocity = actor.velocity.move_toward(new_velocity, 0.25)
	actor.move_and_slide()
	
func set_target(target):
	target_position = target
