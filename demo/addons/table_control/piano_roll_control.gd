extends Control
class_name PianoRollControl

signal begin
signal end
signal finished
signal selection_changed
signal row_pressed
signal row_mouse_entered
signal row_mouse_exited
signal changed
signal seeked

@export var scroll_horizontal_ratio:float :
	set(v):
		scroll_container_.scroll_horizontal = v * scroll_container_.get_child(0).size.x
	get:
		return scroll_container_.scroll_horizontal * scroll_container_.get_child(0).size.x 

@export var scroll_horizontal:float :
	set(v):
		scroll_container_.scroll_horizontal = v 
	get:
		return scroll_container_.scroll_horizontal

enum Tool {
	none,
	move,
	resize_west,
	resize_east,
	zooming,
	selecting
}

var selection_box_
var supress_hack_ := false
var time_range := Vector2i(0, 16) :
	set(v):
		time_range = v
		if not supress_hack_:
			%TimeRange.position.x = to_local(time_range.x * grid_size)
			%TimeRange.size.x = to_local(time_range.y - time_range.x)

var start := 0 :
	set(v):
		%Start.position.x = v * grid_size
	get:
		return to_world(%Start.position.x / grid_size)

var grid_size := 4 :
	set(value):

		var old_grid_size = grid_size
		grid_size = value

		invalidate_grid_size_(old_grid_size)
		
var grid_size_old_ := grid_size
var zoom_grab_time_ := 0
var quantinize_snap := 16
var invalidate_queue_queued_ := false
var selection_:Array[Control]

var border_ = 8
var tool_ := Tool.none :
	set(v):
		tool_ = v

var grab_offet_ := 0

var undo := UndoRedo.new()
var time_ := 0.0
var queue_on_ := []
var queue_off_ := []

@onready var cursor := %Cursor
@onready var scroll_container_ := %ScrollContainer
@onready var grid_ := %Grid

func to_world(v) -> float:
	return v / grid_size

func to_local(v):
	return v * grid_size

func _ready() -> void:
	grid_.grid_size = grid_size
	connect_row_item_(%TimeRange)
	connect_row_item_(%Start)
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
	if row_item.has_signal("changed"):
		row_item.changed.connect(queue_invalidate_queue_)

func connect_row_(row) -> void:
	row.gui_input.connect(func(event:InputEvent): 
		var row_index = row.get_index()
		if event.is_action_pressed("click"): 
			var selection_size = selection_.size()
			clear_selection_()
			
			#if selection_size <= 1:
			#	row_pressed.emit(row_index, row.get_local_mouse_position())
	)
	#row.mouse_entered.connect(func(): var row_index = row.get_index(); row_mouse_entered.emit(row_index))
	#row.mouse_exited.connect(func(): var row_index = row.get_index(); row_mouse_exited.emit(row_index))

func clear_selection_() -> void:
	print("clear_selection")
	for node in selection_:
		node.button_pressed = false
	selection_.clear()
	last_item_down_ = null
	selection_changed.emit([])
	%Overlay.queue_redraw()

func quantinize_to_grid(value:float) -> int:
	return clamp(floor(value / grid_size) * grid_size, 0 , 2048)

func get_local_mouse_table_position() -> int:
	return clamp(floor(%MarginContainer.get_local_mouse_position().x / grid_size), -2048 , 2048)

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
	if w.x > 0:
		resize_east_begin_()
	elif w.x < 0:
		resize_west_begin_()
		
	time_ = item.position.x / grid_size
	cursor.position.x = item.position.x
		
	last_item_down_ = item

		
	selection_changed.emit([item])

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
	return (floor((value / grid_size) / q) * q) * grid_size

func _physics_process(delta:float) -> void:
	if not is_visible_in_tree():
		return
	
	if tool_ != Tool.none:
		if scroll_container_.auto_scroll(delta):
			_input(InputEventMouseMotion.new())
	
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
			item.size.x = quantinize((row_position + quantinize_snap) * grid_size, quantinize_snap) - item.position.x
		%Overlay.queue_redraw()
	elif tool_ == Tool.resize_west:
		for item in selection_:
			var c = item.position.x
			item.position.x = quantinize(row_position * grid_size, quantinize_snap)
			item.size.x += c - item.position.x
		%Overlay.queue_redraw()
	elif tool_ == Tool.zooming:
		var zoom = %Headings.get_local_mouse_position().y
		grid_size = clamp(grid_size_old_ + zoom * 0.1, 3, 32)
		%Overlay.queue_redraw()

func get_bounding_box(items:Array[Control]) -> Rect2:
	if items.is_empty():
		return Rect2()
	
	var bounding_box = items[0].get_global_rect()
	for control in items:
		bounding_box = bounding_box.merge(control.get_global_rect())
	
	return bounding_box

func duplicate_(items:Array[Control]) -> void:
	if items.is_empty():
		return
		
	undo.create_action("duplicate")

	var bounding_box := get_bounding_box(items)
	bounding_box.position -= %Rows.global_position
	var max_x := bounding_box.position.x + bounding_box.size.x

	var new_selection:Array[Control]

	for item in items:
		var duplicate = item.duplicate()
		duplicate.position.x = max_x + (item.position.x - bounding_box.position.x)
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
	undo.add_do_method(invalidate_queue_)
	undo.add_undo_method(%Overlay.queue_redraw)
	undo.add_undo_method(emit_signal.bind("changed"))
	undo.add_undo_method(invalidate_queue_)
	
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

func seek(time:float) -> void:
	time_ = time
	
	var t := int(time)
	
	var l = (time_range.y - time_range.x) 
	
	if time >= time_range.y:
		t =  int(t % l)

	t += time_range.x
	
	cursor.position.x = t * grid_size

	for i in queue_off_.size():
		var item = queue_off_[i].get(t)
		if item:
			end.emit(item, i)

	for i in queue_on_.size():
		var item = queue_on_[i].get(t)
		if item:
			begin.emit(item, i)
			
	seeked.emit(t)

func translation_begin_() -> void:
	for item in selection_:
		undo.add_undo_method(item.reparent.bind(item.get_parent()))
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
		undo.add_do_method(item.reparent.bind(item.get_parent()))
		undo.add_do_property(item, "position", item.position)
		undo.add_do_property(item, "size", item.size)
	
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

	handle_item_position.x = row_position * grid_size - grab_offet_
	handle_item_position.x = quantinize(handle_item_position.x, quantinize_snap)

	var move = handle_item_position - handle_item.position
	
	for item in selection_:
		item.position.x += move.x
	
	if selection_.size() == 1:
		if handle_item != %TimeRange and handle_item != %Start:
			if handle_item.get_parent().get_index() != track_index:
				handle_item.get_parent().remove_child(handle_item)
				%Rows.get_child(track_index).add_child(handle_item)

	%Overlay.queue_redraw()

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
	
	if control == %Start:
		return where
	
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

func add_item(node:Button, row_idx:int, quantinize := true) -> void:
	if node == null:
		return

	if %Rows.get_child_count() <= row_idx:
		return

	var row = %Rows.get_child(row_idx)

	node.custom_minimum_size = Vector2i(grid_size, 36)
	node.size.y *= 0
	node.piano_roll_ = self
	if quantinize:
		node.position.x = quantinize(node.position.x, quantinize_snap)
		node.size.x = quantinize_snap * grid_size
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

func invalidate_grid_size_(old_grid_size) -> void:
	grid_.grid_size = grid_size

	for row in %Rows.get_children() + [%TimeRange.get_parent(), %Start.get_parent()]:
		for item in row.get_children():
			var t = item.position.x / old_grid_size
			var l = item.size.x / old_grid_size
			item.position.x = t * grid_size 
			
			if item != %Start:
				item.size.x = l * grid_size

	if is_visible_in_tree():
		scroll_horizontal = -(zoom_grab_time_ * grid_size) + %ScrollContainer.get_local_mouse_position().x

func queue_invalidate_queue_() -> void:
	if invalidate_queue_queued_:
		return
	
	invalidate_queue_queued_ = true
	call_deferred("invalidate_queue_")
	set_deferred("invalidate_queue_queued_", false)

func invalidate_queue_() -> void:
	queue_on_.clear()
	queue_off_.clear()

	for row in %Rows.get_children():
		var dict_on := {}
		var dict_off := {}
		for item in row.get_children():
			var begin = int(item.position.x / grid_size) - item.get_lookahead()
			var end = int(item.position.x / grid_size) + int(item.size.x / grid_size)

			if item.fill():
				for i in range(begin, end - 1):
					dict_on[i] = item
			
			dict_on[begin] = item
			dict_off[end] = item
		
		queue_on_.push_back(dict_on)
		queue_off_.push_back(dict_off)

func get_queue() -> Array:
	invalidate_queue_()

	var res := []
	
	for q in queue_off_:
		var items := []
		for item in q.values():
			items.push_back(item)
		
		res.push_back(items)

	return res

func add_row() -> void:
	var row := PianoRollRow.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.custom_minimum_size.y = 36
	connect_row_(row)
	undo.add_do_method(%Rows.add_child.bind(row))
	undo.add_do_property(row, "owner", %Rows)
	undo.add_do_reference(row)
	undo.add_undo_method(%Rows.remove_child.bind(row))

func remove_row(idx:int) -> void:
	var row = %Rows.get_child(idx)

	undo.add_do_method(%Rows.remove_child.bind(row))
	undo.add_undo_method(%Rows.add_child.bind(row))
	undo.add_undo_method(%Rows.move_child.bind(row, idx))
	undo.add_undo_reference(row)

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

func set_quantinize_snap(index):
	match index:
		0:
			quantinize_snap = 1
		1:
			quantinize_snap = 4
		2:
			quantinize_snap = 16

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
		selection_box_.size = event.position - selection_box_.position
		#selection_box_ = selection_box_.abs()
		var globalized = selection_box_.abs()
		globalized.position += global_position
		selection_ = get_items_in_rect_(globalized)
		%Overlay.queue_redraw()
	elif event is InputEventMouseButton:
		if event.pressed:
			tool_ = Tool.selecting
			selection_box_ = Rect2(event.position, Vector2.ZERO)
			selection_ = []
			%Overlay.queue_redraw()
		else:
			selection_box_ = null
			tool_ = Tool.none
			%Overlay.queue_redraw()

func get_items_in_rect_(rect:Rect2) -> Array[Control]:
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
	grid_size = 4 * r
	scroll_horizontal_ratio = 0
