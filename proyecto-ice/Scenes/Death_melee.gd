extends Node3D

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@export var wait_time: float = 0.0
func _ready():
	await get_tree().create_timer(wait_time).timeout
	$DeathSound.play()
	await animated_sprite_3d.animation_finished
	queue_free()
