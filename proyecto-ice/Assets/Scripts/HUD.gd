extends CanvasLayer

@onready var time_label: Label = $Tiempo/TimeLabel

func _ready():
	TimeManager.time_changed.connect(_on_time_changed)
	TimeManager.time_over.connect(_on_time_over)

func _on_time_changed(time_left: float):
	var total_seconds = int(ceil(time_left))
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]

func _on_time_over():
	time_label.text = "TIME OVER"
