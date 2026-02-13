extends Control

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			if event.pressed:
				get_tree().quit()
