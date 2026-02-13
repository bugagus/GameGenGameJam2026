class_name Kid
extends CharacterBody3D

@export var puntos_de_spawn: Array[Node3D]
@export var win_scene: PackedScene

var is_free: bool = false
var total_recogidos: int = 0
const meta: int = 9
var ultimo_punto: Node3D = null

@onready var pickup_area: Area3D = $PickupArea
@onready var anim_sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var label_3d: Label3D = $Label3D
@onready var label_kid: Label = $"../Hud/Niños/NiñosLabel"
@onready var cry_sound: AudioStreamPlayer3D = $CrySound 
@export var offest_h: float = 0.3
@onready var fade_rect: ColorRect = $"../Hud/ColorRect"

var time = 0.0
var finalizando_juego: bool = false
var volumen_actual_db: float = 0.0

func _ready() -> void:
	label_3d.visible = false
	scale = Vector3(1.6, 1.6, 1.6)
	position.y += offest_h

func _process(delta: float) -> void:
	if is_free:
		time += delta
		label_3d.position.y = 1 + sin(time * 2.0) * 0.1
	if finalizando_juego:
		volumen_actual_db -= 20 * delta 
		var master_db = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_volume_db(master_db, volumen_actual_db)

func take_damage(_damage_amount) -> void:
	if not is_free:
		transform_to_collectible()

func transform_to_collectible() -> void:
	position.y -= offest_h
	is_free = true
	scale = Vector3(1, 1, 1)
	if not cry_sound.playing:
		cry_sound.play()
	
	anim_sprite.play("idle_kid") 
	label_3d.text = "SAVE ME"
	label_3d.visible = true
	pickup_area.set_deferred("monitoring", true)

func _on_pickup_area_body_entered(body: Node3D) -> void:
	if is_free:
		if body.is_in_group("Player"): 
			if body.is_carrying == false:
				body.pickup_kid()
				respawn()

func respawn():
	var opciones_disponibles: Array[Node3D] = []
	
	for punto in puntos_de_spawn:
		if punto != ultimo_punto:
			opciones_disponibles.append(punto)
	
	if opciones_disponibles.is_empty():
		opciones_disponibles = puntos_de_spawn

	var punto_elegido = opciones_disponibles.pick_random()
	ultimo_punto = punto_elegido
	
	global_position = punto_elegido.global_position
	reset_state()

func reset_state():
	position.y += offest_h
	is_free = false
	visible = true
	time = 0.0
	scale = Vector3(1.6, 1.6, 1.6)
	cry_sound.stop()
	
	label_3d.visible = false
	pickup_area.set_deferred("monitoring", false)
	anim_sprite.play("idle_enemy")

func actualizar_contador():
	total_recogidos += 1
	label_kid.text = str(total_recogidos) + "/" + str(meta)
	if total_recogidos >= meta:
		iniciar_final()

func iniciar_final():
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 1.5)
	finalizando_juego = true
	await tween.finished
	get_tree().change_scene_to_packed(win_scene)
