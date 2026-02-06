extends CanvasLayer

@onready var volume_slider: HSlider = $Panel/VBoxContainer/VBoxContainer/Volumen
@onready var sens_slider: HSlider = $Panel/VBoxContainer/VBoxContainer/VBoxContainer/Sensibilidad

var paused := false

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	var master_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	volume_slider.value = db_to_linear(master_db)

	var player = get_tree().get_first_node_in_group("Player")
	if player:
		sens_slider.value = player.mouse_sensitivity

func _unhandled_input(event):
	if event.is_action_pressed("Pause"):
		toggle_pause()

func toggle_pause():
	paused = !paused
	visible = paused
	get_tree().paused = paused

	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_volumen_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(value)
	)

func _on_reanudar_pressed() -> void:
	toggle_pause()

func _on_salir_pressed() -> void:
	get_tree().quit()

func _on_sensibilidad_value_changed(value: float) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.mouse_sensitivity = value
