class_name StateMachine
extends Node3D

@export var starting_state: State

var current_state: State

func _init() -> void:
	change_state(starting_state)

func process_physics(delta: float) -> State: 
	
	return null

func process_frame(delta: float) -> State: 
	
	return null

func process_input(event: InputEvent) -> State: 
	
	return null


func change_state(new_state: State) -> void:
	if current_state: current_state.exit()
	current_state = new_state
	current_state.enter()
