class_name Kid
extends CharacterBody3D

@export var puntos_de_spawn: Array[Node3D]

var is_free: bool = false

@onready var pickup_area: Area3D = $PickupArea
@onready var anim_sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var label_3d: Label3D = $Label3D

var time = 0.0

func _ready() -> void:
	label_3d.visible = false

func _process(delta: float) -> void:
	if is_free:
		time += delta
		label_3d.position.y = 1 + sin(time * 2.0) * 0.1

func take_damage(_damage_amount) -> void:
	if not is_free:
		transform_to_collectible()

func transform_to_collectible() -> void:
	is_free = true
	anim_sprite.play("idle_kid") 
	label_3d.text = "SAVE ME"
	label_3d.visible = true
	pickup_area.set_deferred("monitoring", true)

func _on_pickup_area_body_entered(body: Node3D) -> void:
	if is_free:
		if body.is_in_group("Player"): 
			if body.is_carrying == false:
				body.pickup_kid()
				print("Recogido!")
				respawn()

func respawn():
	var punto_elegido = puntos_de_spawn.pick_random()   
	global_position = punto_elegido.global_position
	reset_state()
	
func reset_state():
	is_free = false
	visible = true
	time = 0.0
	label_3d.visible = false
	pickup_area.set_deferred("monitoring", false)
	anim_sprite.play("idle_enemy")
