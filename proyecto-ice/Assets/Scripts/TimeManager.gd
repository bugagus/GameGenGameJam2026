extends Node

signal time_changed(current_time: float)
signal time_over

@export var start_time := 60.0

var time_left := 0.0
var running := false

func _ready():
	reset()

func reset():
	time_left = start_time
	running = true
	emit_signal("time_changed", time_left)

func _process(delta):
	if not running:
		return
	
	time_left -= delta
	time_left = max(time_left, 0.0)
	emit_signal("time_changed", time_left)

	if time_left <= 0.0:
		running = false
		emit_signal("time_over")

func add_time(amount: float):
	time_left += amount
	emit_signal("time_changed", time_left)

func stop():
	running = false
