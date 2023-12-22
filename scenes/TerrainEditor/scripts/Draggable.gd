extends Area2D
class_name Draggable


# Use 'button_down' because it gets processed before 'pressed'
func _on_delete_button_button_down():
	queue_free();
