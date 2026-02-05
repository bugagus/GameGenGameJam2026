extends CanvasLayer

@onready var time_label: Label = $TimeLabel

func _ready():
	TimeManager.time_changed.connect(_on_time_changed)
	TimeManager.time_over.connect(_on_time_over)

func _on_time_changed(time_left: float):
	time_label.text = "TIME: " + str(int(ceil(time_left)))

func _on_time_over():
	time_label.text = "TIME OVER"
