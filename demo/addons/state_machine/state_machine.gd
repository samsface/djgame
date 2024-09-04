extends Node
class_name State

signal ui_accept

func _enter_tree() -> void:
	if get_parent().owner:
		owner = get_parent().owner
	else:
		owner = get_parent()

func move_to(game_state:State) -> void:
	queue_free()
	var parent := get_parent()
	parent.remove_child(self)
	parent.add_child(game_state)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		ui_accept.emit()
	elif event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed and not event.echo:
			ui_accept.emit()

func delay(time:float):
	return get_tree().create_timer(time).timeout
