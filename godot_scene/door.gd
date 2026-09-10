extends Area3D

var is_open: bool = false

func interact() -> void:
	is_open = not is_open
	if is_open:
		print("Door opened")
	else:
		print("Door closed")
