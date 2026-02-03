class_name StateMachine 
extends Node3D

@export var initial_state: State
var current_state: State = null
var states: Dictionary = {}

func _ready():
	await owner.ready
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transitioned)
	
	if initial_state:
		current_state = initial_state
		initial_state.enter()

func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func on_child_transitioned(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states[new_state_name.to_lower()]
	
	if current_state:
		current_state.exit()
	
	new_state.enter()
