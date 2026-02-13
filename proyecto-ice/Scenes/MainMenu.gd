extends Control

@onready var label = $Label
@onready var video_player = $VideoStreamPlayer
@onready var animation_player = $AnimationPlayer
@onready var controls_label = $Node/Label
@onready var texture_rect: TextureRect = $TextureRect
@onready var lore_label = $Node2/Label
@export var World: PackedScene 

var can_start = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	label.hide()
	texture_rect.hide()
	lore_label.hide()
	video_player.hide()
	controls_label.show()
	await get_tree().create_timer(10).timeout
	controls_label.hide()
	texture_rect.show()
	await get_tree().create_timer(1.0).timeout
	label.show()
	can_start = true

func _input(event):
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if can_start and (event is InputEventKey or event is InputEventMouseButton):
		if event.is_pressed():
			start_cinematic_sequence()

func start_cinematic_sequence():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	can_start = false
	animation_player.play("fade_in")
	await animation_player.animation_finished
	label.hide()
	texture_rect.hide()
	lore_label.show()
	animation_player.play("fade_out")
	await animation_player.animation_finished
	await get_tree().create_timer(5.0).timeout
	animation_player.play("fade_in")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(World)
