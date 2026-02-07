extends Node3D

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

func _ready():
	await animated_sprite_3d.animation_finished
	queue_free()
