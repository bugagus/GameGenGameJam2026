extends Node3D

var high_score = 0
var current_score: int
var previous_score: int

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("DEBUG_FORCE_QUIT"):
		get_tree().quit()
