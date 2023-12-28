extends Area2D
class_name PDNode

@export var text:String : 
	set(value):
		text = set_text_(value)
@export var index := 0
@export var resizeable := false
@export var visible_in_subpatch := false
@export var clip_contents:bool :
	set(value):
		$ColorRect.clip_contents = value
	get:
		return $ColorRect.clip_contents
		
@export var custom_minimum_size:Vector2 :
	set(value):
		$ColorRect.custom_minimum_size = value
	get:
		return $ColorRect.custom_minimum_size

var selectable:bool = true
var canvas:Node
var in_subpatch:bool

signal connection_clicked
signal title_changed
signal begin_edit_text
signal end_edit_text
signal begin_resize
signal end_resize

var mouse_over_ := false
var dragging_ := false
var resizing_ := false
var drag_offset := Vector2.ZERO
var selected_ := false

var connections_ := []
var editing_text_ := false
var original_text_ := ""

func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	visibility_changed.connect(_visibility_changed)
	tree_exiting.connect(_tree_exiting)
	_item_rect_changed()
	$ColorRect/Reize.visible = resizeable

func _mouse_entered() -> void:
	if not monitorable:
		return

	mouse_over_ = true
	SelectionBus.hovering = self
	modulate = Color.WHITE * 1.1

func _mouse_exited() -> void:
	if not monitorable:
		return

	mouse_over_ = false
	if SelectionBus.hovering == self:
		SelectionBus.hovering = null
	modulate = Color.WHITE

func stop_dragging_() -> void:
	if dragging_:
		dragging_ = false

func connection_down_(connection:PDSlot) -> void:
	connection_clicked.emit(connection)

func pretty_text_(text:String):
	if text.begins_with("bng"):
		return "bang"
		
	if text.begins_with("nbx"):
		return "nbx"
		
	if text.begins_with("tgl"):
		return "toggle"

	if text.begins_with("coords"):
		return "coords"

	var r := RegEx.new()
	r.compile("\\$1\\/.+")
	text = r.sub(text, "")
	
	return text

func set_text_(value:String, is_update := false) -> String:
	if not canvas:
		return value

	var res = canvas.create_obj(value, global_position)
	if res:

		index = res[0]
		value = res[1]

	%LineEdit.text = pretty_text_(value)
	%LineEdit.caret_column = %LineEdit.text.length()

	var args = value.split(' ')

	var node_model = NodeDb.db.get(args[0])
	if not node_model:
		return ""
		
	visible_in_subpatch = node_model.visible_in_subpatch

	if in_subpatch:
		monitorable = false
		if not node_model.visible_in_subpatch:
			visible = false

	update_connection_(node_model.inputs, %Inputs)
	update_connection_(node_model.outputs, %Outputs)
	update_specialized_(node_model)
	
	return value

func update_connection_(connection_models:Array, node:Node) -> void:
	var slot_index = 0
	for connection_model in connection_models:
		var slot
		if node.get_child_count() <= slot_index:
			slot = preload("slot.tscn").instantiate()
			slot.parent = self
			slot.index = slot_index
			slot.button_down.connect(connection_down_.bind(slot))
			node.add_child(slot)
		else:
			slot = node.get_child_count(slot_index)

		slot_index += 1
	
	for leftover_past_connection in range(slot_index, node.get_child_count()):
		var slot = node.get_child(slot_index)
		slot.queue_free()
		node.remove_child(slot)

func update_specialized_(node_model) -> void:
	if node_model.title.begins_with("coords"):
		pass
	
	for node in %Specialized.get_children():
		node.queue_free()
		node.get_parent().remove_child(node)

	if node_model.specialized:
		var specialized = node_model.specialized.instantiate()
		if node_model.specialized.has_meta("path"):
			specialized.patch_path = node_model.specialized.get_meta("path")
		%Specialized.add_child(specialized)

func add_connection(cable):
	cable.tree_exiting.connect(remove_connection.bind(cable))
	connections_.push_back(cable)

func remove_connection(cable):
	connections_.erase(cable)

func _item_rect_changed() -> void:
	$CollisionShape2D.shape.size = $ColorRect.size
	$CollisionShape2D.position = $ColorRect.size * 0.5

func _exit_tree() -> void:
	pass

func _tree_exiting() -> void:
	for connection in connections_:
		connection.queue_free()
		connection.get_parent().remove_child(connection)

	SelectionBus.remove_from_selection(self)
	SelectionBus.remove_from_hover(self)

func update(text):
	set_text_(text, true)

func _select():
	selected_ = true
	%Selected.visible = true

func _unselect():
	selected_ = false
	%Selected.visible = false

func _drag(pos:Vector2) -> void:
	if not dragging_:
		dragging_ = true
		drag_offset = global_position - get_global_mouse_position()

func _drag_end() -> void:
	dragging_ = false

func get_inlet(index:int) -> Node:
	if %Inputs.get_child_count() <= index:
		push_error("No inlet")
		return null

	return %Inputs.get_child(index)
	
func get_outlet(index:int) -> Node:
	if %Outputs.get_child_count() <= index:
		push_error("No outlet")
		return

	return %Outputs.get_child(index)

func _connection(to) -> void:
	for node in %Specialized.get_children():
		node._connection(to)

func _visibility_changed():
	if not visible:
		monitorable = false

func _line_edit_focus_entered() -> void:
	%LineEdit.mouse_filter = LineEdit.MOUSE_FILTER_STOP
	editing_text_ = true
	original_text_ = %LineEdit.text
	begin_edit_text.emit()

func _line_edit_text_submitted(new_text: String) -> void:
	title_changed.emit(new_text)
	original_text_ = new_text

func _line_edit_focus_exited() -> void:
	%LineEdit.text = original_text_
	%LineEdit.mouse_filter = LineEdit.MOUSE_FILTER_IGNORE
	end_edit_text.emit()
	editing_text_ = false

func _input(event: InputEvent) -> void:
	if dragging_:
		global_position = get_global_mouse_position() + drag_offset
		
		for connection in connections_:
			connection.invalidate()

	elif  resizing_:
		if event.is_action_released("click"):
			resizing_ = false
			end_resize.emit()
			resizing_ = false
			_item_rect_changed()
		else:
			$ColorRect.custom_minimum_size = get_global_mouse_position() - global_position
		
	elif selected_:
		if editing_text_:
			if event.is_action_pressed("ui_cancel"):
				%LineEdit.release_focus()

			elif event.is_action_pressed("click"):
				if not Rect2(%LineEdit.global_position, %LineEdit.size).has_point(get_global_mouse_position()):
					%LineEdit.release_focus()
		elif event is InputEventMouseButton:
			if event.double_click:
				if Rect2(%LineEdit.global_position, %LineEdit.size).has_point(get_global_mouse_position()):
					%LineEdit.release_focus()
					await get_tree().process_frame
					%LineEdit.grab_focus()
					%LineEdit.caret_column = %LineEdit.text.length()


func _size_control_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		resizing_ = true
		begin_resize.emit()
