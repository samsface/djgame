extends SplitContainer
class_name PianoRollControl

signal selection_changed
signal row_pressed
signal changed
signal add_row_pressed
signal row_header_pressed
signal zoom_changed(float)
signal seek_time_changed

@export var scroll_horizontal:float :
	set(v):
		if scroll_container_:
			scroll_container_.scroll_horizontal = v 
			header_scroll_container_.scroll_horizontal = v
	get:
		if scroll_container_:
			return scroll_container_.scroll_horizontal
		else:
			return 0

@export var disable_row_headers:bool :
	set(v):
		disable_row_headers = v
		collapsed = disable_row_headers
		split_offset = 0 if collapsed else 200
		dragger_visibility = DRAGGER_HIDDEN_COLLAPSED if disable_row_headers else DRAGGER_VISIBLE

@export var seek_time:int :
	set(v):
		%Cursor.time = v
	get:
		return %Cursor.time

enum Tool {
	none,
	move,
	resize_west,
	resize_east,
	zooming,
	selecting,
	paint,
	move_row
}

var selection_box_
var time_range := Vector2i(0, 16) :
	set(v):
		%TimeRange.time = v.x
		%TimeRange.length = v.y - v.x
	get:
		return Vector2i(%TimeRange.time, %TimeRange.time + %TimeRange.length)

@export var zoom := 4.0 :
	set(v):
		zoom = v
		invalidate_grid_size_()
		zoom_changed.emit(zoom)
		
var zoom_grab_time_ := 0.0
var zoom_grab_position_ := Vector2.ZERO
var zoom_previous_ := 0
var quantinize_snap := 16
var quantinize_snap_auto := false
var invalidate_queue_queued_ := false
var selection_:Array[Control]

var border_ = 8
var tool_ := Tool.none :
	set(v):
		tool_ = v

var grab_offet_ := 0

var undo := UndoRedo.new()
var time_ := 0.0

@onready var cursor := %Cursor
@onready var scroll_container_ := %BodyScrollContainer
@onready var header_scroll_container_ := %HeaderScrollContainer
@onready var grid_ := %Grid

func to_world(v) -> float:
	return v / zoom

func to_local(v):
	return v * zoom

func _ready() -> void:
	connect_row_item_(%Cursor)
	connect_row_item_(%TimeRange)
	header_scroll_container_.gui_input.connect(_headings_gui_input)

func _headings_gui_input(event:InputEvent) -> void:
	if event.is_action_pressed("click"):
		tool_ = Tool.zooming
		zoom_previous_ = zoom
		zoom_grab_position_ = header_scroll_container_.get_local_mouse_position()
		zoom_grab_time_ = %Overlay.get_local_mouse_position().x / zoom
	elif event.is_action_released("click"):
		tool_ = Tool.none

func connect_row_item_(row_item:Button) -> void:
	row_item.button_down.connect(_table_item_button_down.bind(row_item))
	row_item.button_up.connect(_table_item_button_up.bind(row_item)) 
	row_item.gui_input.connect(_item_gui_input.bind(row_item))
	if row_item.has_signal("changed"):
		row_item.changed.connect(queue_invalidate_queue_)

func connect_row_(row) -> void:
	pass

func clear_selection_() -> void:
	print("clear_selection")
	for node in selection_:
		node.button_pressed = false
	selection_.clear()
	last_item_down_ = null
	selection_changed.emit([])
	%Overlay.queue_redraw()

func quantinize_to_grid(value:float) -> int:
	return clamp(floor(value / zoom) * zoom, 0 , 2048)

func get_local_mouse_table_position() -> int:
	return clamp(floor(%Rows.get_local_mouse_position().x / zoom), -2048 , 2048)

func get_local_mouse_table_position_row() -> int:
	for row in %Rows.get_children() as Array[Control]:
		if row.get_local_mouse_position().y < 0:
			return max(0, row.get_index() - 1)

	return max(0, %Rows.get_child_count() - 1)

var grab_position_ := Vector2.ZERO

var last_item_down_

func _table_item_button_down(item):
	grab_position_ = get_global_mouse_position()

	if not item in selection_:
		if Input.is_action_pressed("shift"):
			selection_.push_back(item)
		else:
			clear_selection_()
			selection_.push_back(item)

	var w := where_(item)

	#if w.x == 0:
		#move_begin_()
	if w.x > 0 and not item.disable_resize:
		resize_east_begin_()
	elif w.x < 0 and not item.disable_resize:
		resize_west_begin_()
		
	time_ = item.position.x / zoom
		
	last_item_down_ = item

	selection_changed.emit(selection_)

	print("new selection", selection_)

	%Overlay.queue_redraw()

func _table_item_button_up(item):
	if tool_ == Tool.move:
		translation_end_()
	elif tool_ == Tool.resize_east:
		translation_end_()
	elif tool_ == Tool.resize_west:
		translation_end_()

	tool_ = Tool.none
	#selection_.clear()
	#selection_changed.emit([])

func quantinize(value:float, q:int) -> float:
	return (floor((value / zoom) / q) * q) * zoom

func _physics_process(delta:float) -> void:
	if not is_visible_in_tree():
		return
	
	if tool_ != Tool.none and tool_ != Tool.paint:
		if scroll_container_.auto_scroll(delta):
			header_scroll_container_.scroll_horizontal = scroll_container_.scroll_horizontal
			_input(InputEventMouseMotion.new())
	

	%BodyScrollContainer.scroll_vertical = -$VBoxContainer/ScrollContainer.scroll_vertical 

func _input(event):
	if not is_visible_in_tree():
		return

	var row_position = get_local_mouse_table_position()

	if event.is_action_pressed("duplicate"):
		duplicate_(selection_)
	
	elif event.is_action_pressed("ui_text_delete"):
		erase_(selection_)

	elif last_item_down_ and last_item_down_.button_pressed and tool_ == Tool.none:
		# button input order hack fix
		await get_tree().process_frame
		if last_item_down_ and last_item_down_.button_pressed:
			if abs(get_global_mouse_position().x - grab_position_.x) > 0.1:
				move_begin_()
	elif tool_ == Tool.move:
		move_process_()
	elif tool_ == Tool.resize_east:
		for item in selection_:
			item.length = round(to_world(quantinize((row_position + quantinize_snap) * zoom, quantinize_snap) - item.position.x))
		%Overlay.queue_redraw()
	elif tool_ == Tool.resize_west:
		for item in selection_:
			var c = item.position.x
			item.time = round(to_world(quantinize(row_position * zoom, quantinize_snap)))
			item.length += round(to_world(c - item.position.x))
		%Overlay.queue_redraw()
	elif tool_ == Tool.zooming:
		var new_zoom = zoom_grab_position_.y - header_scroll_container_.get_local_mouse_position().y
		new_zoom *= 0.1
		
		zoom = clamp(zoom_previous_ - new_zoom, 2, 64)
		%Overlay.queue_redraw()

	elif tool_ == Tool.move_row:
		if event.is_action_released("click"):
			tool_ == Tool.none

func find_max_time(items:Array[Control]) -> int:
	if items.is_empty():
		return 0
		
	var max_time = items[0].time + items[0].length
	for item in items:
		if (item.time + item.length) > max_time:
			max_time = item.time + item.length
			
	return max_time

func find_min_time(items:Array[Control]) -> int:
	if items.is_empty():
		return 0
		
	var min_time = items[0].time
	for item in items:
		if item.time < min_time:
			min_time = item.time
			
	return min_time

func duplicate_(items:Array[Control]) -> void:
	if items.is_empty():
		return
		
	undo.create_action("duplicate")

	var max_time := find_max_time(items)
	var min_time := find_min_time(items)

	var new_selection:Array[Control]

	for item in items:
		var duplicate = item.duplicate()
		duplicate.time = duplicate.time - min_time + max_time
		connect_row_item_(duplicate)
		
		undo.add_do_method(item.get_parent().add_child.bind(duplicate))
		undo.add_undo_method(item.get_parent().remove_child.bind(duplicate))
		undo.add_undo_reference(duplicate)
	
		new_selection.push_back(duplicate)

	undo.add_do_property(self, "selection_", new_selection.duplicate())
	undo.add_undo_property(self, "selection_", items.duplicate())
	
	commit_action_()

func commit_action_() -> void:
	undo.add_do_method(%Overlay.queue_redraw)
	undo.add_do_method(emit_signal.bind("changed"))
	undo.add_undo_method(%Overlay.queue_redraw)
	undo.add_undo_method(emit_signal.bind("changed"))
	
	undo.commit_action()

func erase_(items:Array[Control]) -> void:
	if items.is_empty():
		return
		
	undo.create_action("delete")

	var new_selection = selection_.duplicate()

	for item in items:
		undo.add_do_method(item.get_parent().remove_child.bind(item))
		undo.add_undo_method(item.get_parent().add_child.bind(item))
		undo.add_undo_reference(item)
		new_selection.erase(item)
		
	undo.add_do_property(self, "selection_", new_selection.duplicate())
	undo.add_undo_property(self, "selection_", selection_.duplicate())

	commit_action_()

func translation_begin_() -> void:
	for item in selection_:
		undo.add_undo_method(item.reparent.bind(item.get_parent()))
		undo.add_undo_property(item, "time", item.time)
		if not item.disable_resize:
			undo.add_undo_property(item, "length", item.length)

func translation_end_() -> void:
	for item in selection_:
		undo.add_do_method(item.reparent.bind(item.get_parent()))
		undo.add_do_property(item, "time", item.time)
		if not item.disable_resize:
			undo.add_do_property(item, "length", item.length)
	
	commit_action_()

func move_begin_() -> void:
	print("move begin")
	tool_ = Tool.move
	grab_offet_ = last_item_down_.get_local_mouse_position().x
	undo.create_action("move")
	translation_begin_()

func move_process_() -> void:
	if Input.is_action_just_released("click"):
		_table_item_button_up(null)
		return
	
	var track_index = get_local_mouse_table_position_row()

	var row_position := get_local_mouse_table_position()
	
	var handle_item = last_item_down_
	
	var handle_item_position = handle_item.position

	handle_item_position.x = %Overlay.get_local_mouse_position().x - grab_offet_
	handle_item_position.x = quantinize(handle_item_position.x, quantinize_snap)

	var move = handle_item_position - handle_item.position

	for item in selection_:
		item.time += round(to_world(move.x))

	if selection_.size() == 1:
		if handle_item != %TimeRange and handle_item != %Cursor:
			if handle_item.get_parent().get_index() != track_index:
				handle_item.get_parent().remove_child(handle_item)
				%Rows.get_child(track_index).add_child(handle_item)

	%Overlay.queue_redraw()

	if selection_[0] == %Cursor:
		seek_time_changed.emit()

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

func set_row_target_node(row_idx:int, target_node:Node) -> void:
	%Rows.get_child(row_idx).target_node = target_node

func add_item(node:Button, row_idx:int) -> void:
	if node == null:
		return

	if %Rows.get_child_count() <= row_idx:
		return

	var row = %Rows.get_child(row_idx)

	node.custom_minimum_size = Vector2i(zoom, 36)
	node.size.y *= 0
	node.piano_roll_ = self
	node.time = node.time
	node.length = node.length

	connect_row_item_(node)

	undo.create_action("add")
	undo.add_do_method(row.add_child.bind(node))
	undo.add_do_property(node, "owner", row)
	undo.add_do_reference(node)
	undo.add_undo_method(row.remove_child.bind(node))

	commit_action_()

func remove_item(node:Control) -> void:
	if node == null or node.get_parent() == null:
		return
	
	undo.create_action("remove")
	undo.add_do_method(node.get_parent().remove_child.bind(node))
	undo.add_undo_method(node.get_parent().add_child.bind(node))
	undo.add_undo_reference(node)

	commit_action_()

func invalidate_grid_size_() -> void:
	#grid_.grid_size = zoom

	for row in %Rows.get_children() + [%Cursor.get_parent(), %TimeRange.get_parent()]:
		for item in row.get_children():
			item.time = item.time
			
			if not item.disable_resize:
				item.length = item.length
		
	if is_visible_in_tree():
		scroll_horizontal = -(zoom_grab_time_ * zoom) + scroll_container_.get_local_mouse_position().x

	if quantinize_snap_auto:
		quantinize_snap = get_quantinize_snap_()

func queue_invalidate_queue_() -> void:
	if invalidate_queue_queued_:
		return
	
	invalidate_queue_queued_ = true
	call_deferred("invalidate_queue_")
	set_deferred("invalidate_queue_queued_", false)

func add_row(control:Control = null) -> void:
	undo.create_action("add row")
	
	var row := PianoRollRow.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.custom_minimum_size.y = 36
	connect_row_(row)
	undo.add_do_method(%Rows.add_child.bind(row))
	undo.add_do_property(row, "owner", %Rows)
	undo.add_do_reference(row)
	undo.add_undo_method(%Rows.remove_child.bind(row))
	
	var row_header := preload("res://addons/timeline_control/timeline_control_row_header.tscn").instantiate()
	if control:
		row_header.get_node("%Body").add_child(control)
		row_header.pressed.connect(func(): row_header_pressed.emit(control))

	undo.add_do_method(%RowHeaders.add_child.bind(row_header))
	undo.add_undo_method(%RowHeaders.remove_child.bind(row_header))
	
	commit_action_()

func remove_row(idx:int) -> void:
	undo.create_action("remove row")
	
	var row = %Rows.get_child(idx)

	undo.add_do_method(%Rows.remove_child.bind(row))
	undo.add_undo_method(%Rows.add_child.bind(row))
	undo.add_undo_method(%Rows.move_child.bind(row, idx))
	undo.add_undo_reference(row)
	
	commit_action_()

func _item_gui_input(event:InputEvent, item:Control):
	update_cursor_(item, where_(item))

func update_cursor_(item:Control, where) -> void:
	await get_tree().process_frame

	if abs(where.x) > 0:
		item.mouse_default_cursor_shape = Control.CURSOR_HSIZE
	elif abs(where.y) > 0: 
		item.mouse_default_cursor_shape = Control.CURSOR_VSIZE
	else:
		item.mouse_default_cursor_shape = Control.CURSOR_DRAG

func move_row_up(row_idx:int) -> void:
	var row = %Rows.get_child(row_idx)
	if row.get_index() == 2:
		return

	row.get_parent().move_child(row, row.get_index() - 1)

func move_row_down(row_idx:int) -> void:
	var row = %Rows.get_child(row_idx)
	if row.get_index() == row.get_parent().get_child_count() - 1:
		return

	row.get_parent().move_child(row, row.get_index() + 1)

func _scroll_container_gui_input(event: InputEvent) -> void:	
	if selection_box_ and event is InputEventMouseMotion:
		selection_box_.size = %Overlay.get_local_mouse_position() - selection_box_.position
		#selection_box_ = selection_box_.abs()
		var globalized = selection_box_.abs()
		globalized.position += %Overlay.global_position
		selection_ = get_items_in_rect_(globalized)
		%Overlay.queue_redraw()
	elif event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				if %Rows.get_child_count() > 0:
					var table_idx := get_local_mouse_table_position_row()
					row_pressed.emit(get_local_mouse_table_position_row(), get_local_mouse_table_position())
			else:
				tool_ = Tool.selecting
				selection_box_ = Rect2(%Overlay.get_local_mouse_position(), Vector2.ZERO)
				selection_ = []
				%Overlay.queue_redraw()
		else:
			if selection_box_:
				selection_changed.emit(selection_)
				selection_box_ = null
				tool_ = Tool.none
				%Overlay.queue_redraw()

func get_items_in_rect_(rect:Rect2) -> Array[Control]:
	print(rect)
	var items:Array[Control]
	for row in %Rows.get_children() as Array[Control]:
		for item in row.get_children() as Array[Control]:
			if rect.has_point(item.get_global_rect().get_center()):
				items.push_back(item)
			
	return items

func fit() -> void:
	while not is_visible_in_tree():
		await visibility_changed
	
	await get_tree().process_frame

	var r = max(1, %ScrollContainer.size.x / %TimeRange.size.x)
	zoom = 4 * r
	scroll_horizontal = 0

func _add_row_pressed() -> void:
	add_row_pressed.emit()

func get_row_header(row_idx:int) -> Control:
	if row_idx >= %RowHeaders.get_child_count():
		return null
	
	return %RowHeaders.get_child(row_idx).get_node("%Body").get_child(0)

func get_row_count() -> int:
	return %Rows.get_child_count()

func get_quantinize_snap_() -> int:
	if zoom < 2:
		return 16
	elif zoom < 8:
		return 8
	elif zoom < 16:
		return 2
	return 1

func _snap_selected(index: int) -> void:
	quantinize_snap_auto = false
	
	match index:
		0:
			quantinize_snap = get_quantinize_snap_()
			quantinize_snap_auto = true
		1:
			quantinize_snap = 1
		2:
			quantinize_snap = 2
		3:
			quantinize_snap = 4
		4:
			quantinize_snap = 8
		5:
			quantinize_snap = 16

func _row_headers_scroll_started() -> void:
	pass # Replace with function body.

func _row_headers_scroll_ended() -> void:
	pass # Replace with function body.


func _cursor_changed():
	pass # Replace with function body.
