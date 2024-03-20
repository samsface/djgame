extends Control
class_name PianoRollControl

signal bang
signal finished
signal selection_changed
signal row_pressed
signal row_mouse_entered
signal row_mouse_exited

@export var streams:Array[AudioStream]

enum Tool {
	none,
	move,
	resize_west,
	resize_east,
	zooming
}

var playing := false
var tempo = 1000.0/130.0
var supress_hack_ := false
var time_range := Vector2i(0, 16) :
	set(v):
		time_range = v
		if not supress_hack_:
			%TimeRange.position.x = time_range.x * grid_size
			%TimeRange.size.x = (time_range.x + time_range.y) * grid_size


var grid_size := 4 :
	set(value):
		var old_grid_size = grid_size
		grid_size = value
		invalidate_grid_size_(old_grid_size)
var grid_size_old_ := grid_size
var zoom_grab_time_ := 0
var quantinize_snap := 16
var selection_ := []

var border_ = 8
var tool_ := Tool.none
var grab_offet_ := 0
var external_undo_ := false
var undo := UndoRedo.new() : 
	set(value):
		undo = value
		external_undo_ = true
var index_ := {}
var time_ := 0.0
var queue_ := []

@onready var cursor := $ScrollContainer/MarginContainer/Cursor
@onready var scroll_container_ := $ScrollContainer
@onready var grid_ := $ScrollContainer/MarginContainer/Grid

func _ready() -> void:
	%Grid.grid_size = grid_size
	connect_row_item_(%TimeRange)
	create_headings_()
	invalidate_headings_()
	%Headings.gui_input.connect(_headings_gui_input)

func _headings_gui_input(event:InputEvent) -> void:
	if event.is_action_pressed("click"):
		tool_ = Tool.zooming
		zoom_grab_time_ = %Headings.get_local_mouse_position().x / grid_size
		grid_size_old_ = grid_size
	elif event.is_action_released("click"):
		tool_ = Tool.none
		grid_size_old_ = grid_size

func connect_row_item_(row_item:Button) -> void:
	row_item.button_down.connect(_table_item_button_down.bind(row_item))
	row_item.button_up.connect(_table_item_button_up.bind(row_item)) 
	row_item.gui_input.connect(_item_gui_input.bind(row_item))

func connect_row_(row) -> void:
	row.gui_input.connect(func(event): 
		var row_index = row.get_index() - 2
		if event.is_action_pressed("click"): 
			row_pressed.emit(row_index, row.get_local_mouse_position())
	)
	row.mouse_entered.connect(func(): var row_index = row.get_index() - 2; row_mouse_entered.emit(row_index))
	row.mouse_exited.connect(func(): var row_index = row.get_index() - 2; row_mouse_exited.emit(row_index))

func quantinize_to_grid(value:float) -> int:
	return clamp(floor(value / grid_size) * grid_size, 0 , 2048)

func get_local_mouse_table_position() -> int:
	return clamp(floor($ScrollContainer/MarginContainer/Rows.get_local_mouse_position().x / grid_size), 0 , 2048)

func _table_item_button_down(item):
	selection_.clear()
	selection_.push_back(item)
	
	var w := where_(item)

	if w.x == 0:
		move_begin_()
	elif w.x > 0:
		resize_east_begin_()
	elif w.x < 0:
		resize_west_begin_()
		
	time_ = item.position.x / grid_size
	cursor.position.x = item.position.x
		
	selection_changed.emit([item])

func _table_item_button_up(item):
	print(tool_)
	if tool_ == Tool.move:
		translation_end_()
	elif tool_ == Tool.resize_east:
		translation_end_()
	elif tool_ == Tool.resize_west:
		translation_end_()

	tool_ = Tool.none
	selection_.clear()
	#selection_changed.emit([])

func should_auto_scroll_() -> bool:
	return (
		tool_ != Tool.none
	)

func _input(event:InputEvent) -> void:
	if not external_undo_:
		if event.is_action_pressed("redo"):
			undo.redo()
		elif event.is_action_pressed("undo"):
			undo.undo()

func quantinize(value:float, q:int) -> float:
	return (floor((value / grid_size) / q) * q) * grid_size

func _physics_process(delta:float) -> void:
	if should_auto_scroll_():
		var mpx = scroll_container_.get_local_mouse_position().x
		var d = mpx - scroll_container_.size.x

		if d > 0:
			scroll_container_.scroll_horizontal += d * delta * 10.0
			_input(InputEventMouseMotion.new())
		elif mpx < 0:
			scroll_container_.scroll_horizontal += mpx * delta * 10.0
			_input(InputEventMouseMotion.new())

	var row_position = get_local_mouse_table_position()

	if tool_ == Tool.move:
		for item in selection_:
			item.position.x = row_position * grid_size - quantinize_to_grid(grab_offet_)
			item.position.x = quantinize(item.position.x, quantinize_snap)
	elif tool_ == Tool.resize_east:
		for item in selection_:
			item.size.x = quantinize((row_position + quantinize_snap) * grid_size, quantinize_snap) - item.position.x
	elif tool_ == Tool.resize_west:
		for item in selection_:
			var c = item.position.x
			item.position.x = quantinize(row_position * grid_size, quantinize_snap)
			item.size.x += c - item.position.x
	elif tool_ == Tool.zooming:
		var zoom = %Headings.get_local_mouse_position().y
		grid_size = clamp(grid_size_old_ + zoom * 0.1, 3, 32)

	play_(delta)

func play_(delta) -> void:
	if not playing:
		return
	
	var time = time_
	time_ += delta * tempo

	if (floor(time_) <= floor(time)) and time != 0.0:
		return

	var t := int(floor(time_))
	
	if t >= time_range.y:
		finished.emit()

	t = t % (time_range.y - time_range.x) + time_range.x

	cursor.position.x = t * grid_size

	invalidate_queue_()

	for i in queue_.size():
		var item = queue_[i].get(t)
		if item:
			bang.emit(item, i)

func translation_begin_() -> void:
	for item in selection_:
		undo.add_undo_property(item, "position", item.position)
		undo.add_undo_property(item, "size", item.size)

func translation_end_() -> void:
	if selection_[0] == %TimeRange:
		supress_hack_ = true
		time_range = Vector2i(%TimeRange.position.x, %TimeRange.position.x + %TimeRange.size.x) / grid_size
		supress_hack_ = false
		undo.commit_action(false)
		return
	
	for item in selection_:
		undo.add_do_property(item, "position", item.position)
		undo.add_do_property(item, "size", item.size)

	undo.commit_action()

func move_begin_() -> void:
	tool_ = Tool.move
	# should be an average of the selection
	grab_offet_ = selection_[0].get_local_mouse_position().x
	undo.create_action("move")
	translation_begin_()

func resize_east_begin_() -> void:
	tool_ = Tool.resize_east
	undo.create_action("resize east")
	translation_begin_()

func resize_west_begin_() -> void:
	tool_ = Tool.resize_west
	undo.create_action("resize west")
	translation_begin_()

func where_(control:Control) -> Vector2i:
	var where := Vector2i.ZERO
	
	var p := control.get_local_mouse_position()
	
	if p.x < border_:
		where.x = -1
	
	if p.x > control.size.x - border_:
		where.x = 1
	
	if p.y < border_:
		where.y = -1
	
	if p.y > control.size.y - border_:
		where.y = 1

	return where

func add_item(node:Button, row_idx:int, quantinize := true) -> void:
	if node == null:
		return

	if %Rows.get_child_count() <= row_idx + 2:
		return

	var row = %Rows.get_child(row_idx + 2)

	node.custom_minimum_size = Vector2i(grid_size, 32)
	node.size.y *= 0
	if quantinize:
		node.position.x = quantinize(node.position.x, quantinize_snap)
		node.size.x = quantinize_snap * grid_size
	connect_row_item_(node)

	undo.create_action("add")
	undo.add_do_method(row.add_child.bind(node))
	undo.add_do_reference(node)
	undo.add_undo_method(row.remove_child.bind(node))

	undo.commit_action()

func remove_item(node:Control) -> void:
	if node == null or node.get_parent() == null:
		return
	
	undo.create_action("remove")
	undo.add_do_method(node.get_parent().remove_child.bind(node))
	undo.add_undo_method(node.get_parent().add_child.bind(node))
	undo.add_undo_reference(node)

	undo.commit_action()

func invalidate_grid_size_(old_grid_size) -> void:
	$ScrollContainer/MarginContainer/Grid.grid_size = grid_size

	for row in %Rows.get_children():
		if row.get_index() > 0:
			for item in row.get_children():
				#if row.get_index() > 1:
					#item.grid_size = grid_size
				
				var t = item.position.x / old_grid_size
				var l = item.size.x / old_grid_size
				item.position.x = t * grid_size 
				item.size.x = l * grid_size

	%ScrollContainer.scroll_horizontal = zoom_grab_time_ * grid_size - %ScrollContainer.size.x * 0.5

	invalidate_headings_()

func invalidate_queue_() -> void:
	queue_.clear()

	for row in %Rows.get_children():
		if row.get_index() <= 1:
			continue

		var dict := {}
		for item in row.get_children():
			dict[int(item.position.x / grid_size)] = item
		
		queue_.push_back(dict)

func get_queue() -> Array:
	invalidate_queue_()

	var res := []
	
	for q in queue_:
		var items := []
		for item in q.values():
			items.push_back(item)
		
		res.push_back(items)

	return res

func add_row() -> void:
	var row := Control.new()
	row.custom_minimum_size.y = 32
	connect_row_(row)
	undo.add_do_method(%Rows.add_child.bind(row))
	undo.add_do_reference(row)
	undo.add_undo_method(%Rows.remove_child.bind(row))
	
func remove_row(idx:int) -> void:
	var row = %Rows.get_child(idx + 2)

	undo.add_do_method(%Rows.remove_child.bind(row))
	undo.add_undo_method(%Rows.add_child.bind(row))
	undo.add_undo_method(%Rows.move_child.bind(row, idx + 2))
	undo.add_undo_reference(row)

func _item_gui_input(event:InputEvent, item:Control):
	if item != %TimeRange:
		if event is InputEventMouseButton:
			if event.pressed:
				if event.button_index == MOUSE_BUTTON_RIGHT:
					remove_item(item)
					return

	var where := Vector2.ZERO
	
	var p := item.get_local_mouse_position()
	
	if p.x < border_:
		where.x = -1
	
	if p.x > item.size.x - border_:
		where.x = 1
	
	if p.y < border_:
		where.y = -1
	
	if p.y > item.size.y - border_:
		where.y = 1

	update_cursor_(item, where)

func update_cursor_(item:Control, where) -> void:
	await get_tree().process_frame

	if abs(where.x) > 0:
		item.mouse_default_cursor_shape = Control.CURSOR_HSIZE
	elif abs(where.y) > 0: 
		item.mouse_default_cursor_shape = Control.CURSOR_VSIZE
	else:
		item.mouse_default_cursor_shape = 0

func create_headings_() -> void:
	for i in 256:
		var label := Label.new()
		label.custom_minimum_size.y = 32
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		label.position.x = i * grid_size
		%Headings.add_child(label)

func invalidate_headings_() -> void:
	var m = 4
	if grid_size <= 8:
		m = 16

	for i in 256:
		var label:Label = %Headings.get_child(i)
		if i % m == 0:
			label.visible = true
			label.custom_minimum_size.y = 32
			label.size_flags_vertical = Control.SIZE_EXPAND_FILL
			label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			label.text = " " + str(int(floor(i / 16)))
			
			if m < 16:
				label.text += "." + str(i % 16)

			label.position.x = i * grid_size
		else:
			label.visible = false

func _quant_selected(index):
	match index:
		0:
			quantinize_snap = 1
		1:
			quantinize_snap = 4
		2:
			quantinize_snap = 16

func move_row_up(row_idx:int) -> void:
	var row = %Rows.get_child(row_idx + 2)
	if row.get_index() == 2:
		return

	row.get_parent().move_child(row, row.get_index() - 1)

func move_row_down(row_idx:int) -> void:
	var row = %Rows.get_child(row_idx + 2)
	if row.get_index() == row.get_parent().get_child_count() - 1:
		return

	row.get_parent().move_child(row, row.get_index() + 1)
