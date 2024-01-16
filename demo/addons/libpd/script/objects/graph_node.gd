extends Area2D
class_name PDNode

@export var text:String : 
	set(value):
		set_text_(value)
	get:
		return ' '.join(args_).replace(' , ', ' \\, ')
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
		$ColorRect.size = value
		_item_rect_changed()
	get:
		return $ColorRect.custom_minimum_size

var selectable:bool = true
var canvas:Node
var in_subpatch:bool
var size:Vector2 :
	set(value):
		pass
	get: return $ColorRect.size


@export var args_ := PackedStringArray()

signal title_changed
signal end_edit_text
signal begin_resize
signal end_resize

var mouse_over_ := false
var moving_ := false
var resizing_ := false
var drag_offset := Vector2.ZERO
var selected_ := false

var connections_ := []
var ghost_rs := []
var editing_text_ := false
var original_text_ := ""
var node_model_

func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	visibility_changed.connect(_visibility_changed)
	$ColorRect/Reize.visible = resizeable

	if not visible:
		_visibility_changed()

	_item_rect_changed()

func get_best_slot(slot:PDSlot) -> PDSlot:
	var test_slots
	if slot.is_output:
		test_slots = %Inputs.get_children()
	else:
		test_slots = %Outputs.get_children()
	
	for test_slot in test_slots:
		if slot.allowed_connections_mask & test_slot.allowed_connections_mask != 0:
			return test_slot

	return null

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

func pretty_text_(text:String):
	if text.begins_with("bng"):
		return "bang"

	if text.begins_with("nbx"):
		return "nbx"

	if text.begins_with("tgl"):
		return "tgl"
		
	if text.begins_with("hsl"):
		return "hsl"

	if text.begins_with("coords"):
		return "coords"

	var r := RegEx.new()
	r.compile("\\$1\\/.+")
	text = r.sub(text, "")
	
	return text

func set_text_(value:String) -> String:
	if not canvas:
		return value

	var res = create_obj_(value,)
	if not res:
		return ""

	value = res[1]

	%LineEdit.text = pretty_text_(node_model_.title + res[3])
	%LineEdit.caret_column = %LineEdit.text.length()

	visible_in_subpatch = node_model_.visible_in_subpatch

	if in_subpatch:
		monitorable = false
		if not node_model_.visible_in_subpatch:
			visible = false

	update_connection_(node_model_.inputs, %Inputs, false)
	update_connection_(node_model_.outputs, %Outputs, true)
	update_specialized_(node_model_)
	
	return value

func update_connection_(connection_models:Array, node:Node, is_output:bool) -> void:
	var slot_index = 0
	for connection_model in connection_models:
		var slot
		if node.get_child_count() <= slot_index:
			slot = preload("slot.tscn").instantiate()
			slot.parent = self
			slot.index = slot_index
			slot.is_output = is_output
			#slot.button_down.connect(connection_down_.bind(slot))
			node.add_child(slot)
		else:
			slot = node.get_child_count(slot_index)

		slot_index += 1
	
	for leftover_past_connection in range(slot_index, node.get_child_count()):
		var slot = node.get_child(slot_index)
		slot.queue_free()
		node.remove_child(slot)

func update_specialized_(node_model) -> void:
	for node in %Specialized.get_children():
		node.queue_free()
		node.get_parent().remove_child(node)

	if node_model.specialized:
		%Specialized.visible = true
		var specialized = node_model.specialized.instantiate()
		
		if specialized.hide_text():
			%LineEdit.visible = false

		if node_model.specialized.has_meta("path"):
			specialized.patch_path = node_model.specialized.get_meta("path")
		%Specialized.add_child(specialized)
		specialized._pd_init()
	else:
		%Specialized.visible = false
		%LineEdit.visible = true

func add_connection(cable):
	cable.tree_exiting.connect(remove_connection.bind(cable))
	connections_.push_back(cable)

func remove_connection(cable):
	connections_.erase(cable)

func _item_rect_changed() -> void:
	$CollisionShape2D.shape.size = $ColorRect.size
	$CollisionShape2D.position = $ColorRect.size * 0.5

func _exit_tree() -> void:
	SelectionBus.remove_from_selection(self)
	SelectionBus.remove_from_hover(self)

func interprit(command):
	command = PureData.found_(command, position)
	text = command

func set_text(t):
	text = t

func _select():
	selected_ = true
	%Selected.visible = true
	
	prints(index, text)

func _unselect():
	selected_ = false
	%Selected.visible = false

func _move() -> void:
	if not moving_:
		moving_ = true
		drag_offset = global_position - get_global_mouse_position()
		
	position = get_global_mouse_position() + drag_offset

func _move_end() -> void:
	moving_ = false
	update_text_position_()

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
	%Block.visible = false
	editing_text_ = true
	original_text_ = %LineEdit.text

func _line_edit_text_submitted(new_text: String) -> void:
	original_text_ = new_text
	title_changed.emit(new_text)

func _line_edit_focus_exited() -> void:
	%LineEdit.text = original_text_
	%Block.visible = true
	end_edit_text.emit()
	editing_text_ = false
	
	if %Specialized.get_child_count() > 0:
		if %Specialized.get_child(0).hide_text():
			%Specialized.visible = true
			%LineEdit.visible = false

func _input(event: InputEvent) -> void:
	if resizing_:
		if event.is_action_released("click"):
			resizing_ = false
			update_text_position_()
			end_resize.emit()
			_item_rect_changed()
		else:
			$ColorRect.custom_minimum_size = get_global_mouse_position() - global_position

func _begin_edit() -> void:
	await get_tree().process_frame
	%Block.visible = false
	%Specialized.visible = false
	%LineEdit.visible = true
	%LineEdit.select_all()
	%LineEdit.grab_focus()

func _size_control_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		resizing_ = true
		begin_resize.emit()

func get_human_readable_for_obj_(args) -> String:
	var res := ' '.join(args.slice(4))
	if not res.is_empty():
		res = " " + res
		
	res = res.replace(' ,', ',')

	return res
	
func get_human_readable_for_widget_(args) -> String:
	var res := ' '.join(args.slice(3))
	if not res.is_empty():
		res = " " + res

	res = res.replace(' ,', ',')

	return res
	
func remove_namespace_(args:PackedStringArray):
	for i in args.size():
		if args[i].contains("NAMESPACE"):
			args.remove_at(i)
			return args
	return args

func create_obj_(message:String) -> Array:
	message = message.replace('\n', ' ')
	message = message.replace('  ', ' ')

	var arg_parser = PureData.IteratePackedStringArray.new(message)

	var pretty_text := ""

	var message_type = arg_parser.next()
	var node_model

	if message_type == 'obj':
		position.x = arg_parser.next_as_int()
		position.y = arg_parser.next_as_int()
		node_model = NodeDb.get_node_model(arg_parser.next())
	elif message_type == 'coords':
		node_model = NodeDb.db.get(message_type)
		# not an object so doesn't need this
		canvas.object_count_ -= 1
	else:
		position.x = arg_parser.next_as_int()
		position.y = arg_parser.next_as_int()
		node_model = NodeDb.db.get(message_type)

	if not node_model:
		push_error("no model for %s" % message)
		return []

	node_model_ = node_model

	resizeable = node_model_.resizeable
	
	var human_readable_args := ""
	if message_type == 'obj':
		human_readable_args = get_human_readable_for_obj_(arg_parser.packed_string_)
	else:
		human_readable_args = get_human_readable_for_widget_(arg_parser.packed_string_)
		
	args_ = arg_parser.packed_string_
	args_ += node_model_.default_args.slice(args_.size())

	if node_model_.instance:
		args_ = remove_namespace_(args_)
		args_.push_back("NAMESPACE/" + str(canvas.object_count_))

	send_message_(args_)
	index = canvas.object_count_
	canvas.object_count_ += 1

	return [canvas.object_count_ - 1, ' '.join(args_), node_model_, human_readable_args]

func send_message_(args) -> void:
	canvas.send_message(args)

func update_text_position_() -> void:
	if not node_model_:
		return

	if node_model_.x_pos_in_command < args_.size():
		args_[node_model_.x_pos_in_command] = str(position.x)
		
	if node_model_.y_pos_in_command < args_.size():
		args_[node_model_.y_pos_in_command] = str(position.y)

	if node_model_.width_pos_in_command < args_.size():
		args_[node_model_.width_pos_in_command] = str($ColorRect.size.x)

	if node_model_.height_pos_in_command < args_.size():
		args_[node_model_.height_pos_in_command] = str($ColorRect.size.y)

func _play_mode_begin() -> void:
	%Inputs.visible = false
	%Outputs.visible = false
	
	monitorable = false
	if %Specialized.get_child_count() > 0:
		%Block.visible = false
	set_process_input(false)

func _play_mode_end() -> void:
	%Inputs.visible = true
	%Outputs.visible = true

	monitorable = true
	if %Specialized.get_child_count() > 0:
		%Block.visible = true
	set_process_input(true)

func get_slots() -> Array:
	return %Inputs.get_children() + %Outputs.get_children()
