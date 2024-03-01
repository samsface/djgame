extends Button
class_name GridItem

@export var grid_position := Vector2i.ZERO
@export var grid_width := 1

signal right_click
signal mouse_enter
signal mouse_exit

var border_ := 8
var where_ := Vector2.ZERO

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				right_click.emit()
				return

	var where := Vector2.ZERO
	
	var p := get_local_mouse_position()
	
	if p.x < border_:
		where.x = -1
	
	if p.x > size.x - border_:
		where.x = 1
	
	if p.y < border_:
		where.y = -1
	
	if p.y > size.y - border_:
		where.y = 1
	
	if where_ != where:
		where_ = where
		update_cursor_()
		mouse_enter.emit(where_)

func update_cursor_() -> void:
	await get_tree().process_frame
	if abs(where_.x) > 0:
		mouse_default_cursor_shape = Control.CURSOR_HSIZE
	elif abs(where_.y) > 0: 
		mouse_default_cursor_shape = Control.CURSOR_VSIZE
	else:
		mouse_default_cursor_shape = 0

