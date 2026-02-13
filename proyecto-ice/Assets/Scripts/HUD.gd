extends CanvasLayer

@onready var time_label: Label = $Tiempo/TimeLabel
@export var game_over_scene: PackedScene

func _ready():
	TimeManager.time_changed.connect(_on_time_changed)
	TimeManager.time_over.connect(_on_time_over)

func _on_time_changed(time_left: float):
	var total_seconds = int(ceil(time_left))
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	if total_seconds <= 0:
		if game_over_scene:
			get_tree().change_scene_to_packed(game_over_scene)
		else:
			print("ERROR: No has asignado la PackedScene en el Inspector")
	time_label.text = "%02d:%02d" % [minutes, seconds]

func _on_time_over():
	time_label.text = "TIME OVER"
