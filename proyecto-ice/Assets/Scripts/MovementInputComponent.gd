class_name MovementInputComponent
extends Resource

func get_movement_input() -> Vector2:
	var movement_direction : Vector2 = Input.get_vector("PaIzqda","PaDcha","Palante","Patras")
	
	return movement_direction

func get_sprint_input() -> bool:
	return Input.is_action_pressed("Correr")
	
func get_walk_input() -> bool:
	return Input.is_action_pressed("Andar")
	
func get_jump_input() -> bool:
	return Input.is_action_just_pressed("Saltar")
	
func get_dash_input() -> bool:
	return Input.is_action_just_pressed("Dash")
