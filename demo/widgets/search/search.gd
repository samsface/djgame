extends Node2D

signal end

var fuzzy_search_ := FuzzySearch.new()
var top_search_result_

func _ready() -> void:
	%Search.grab_focus()
	fuzzy_search_.data = NodeDb.db.keys()

func _text_changed(new_text: String) -> void:
	if new_text.contains(' '):
		return

	top_search_result_ = null

	for child in $VBoxContainer.get_children():
		if child is SearchResult:
			child.queue_free()
			$VBoxContainer.remove_child(child)

	var res = fuzzy_search_.search(new_text)
	
	var i = 0
	for result in fuzzy_search_.search(new_text):
		var search_result := preload("search_result.tscn").instantiate()
		search_result.text = result[1]
		if i == 0:
			search_result.top_result = true
			top_search_result_ = result[0]
		else:
			search_result.top_result = false
		search_result.pressed.connect(end_.bind(result[0]))
		$VBoxContainer.add_child(search_result)
		i += 1

func end_(text:String) -> void:
	queue_free()
	end.emit(text)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
		end.emit("")
		
	elif Input.is_action_just_pressed("enter"):
		if %Search.text.is_empty():
			return

		if not top_search_result_:
			try_load_subpatch_()
		
		if top_search_result_:
			queue_free()
			found_()

	elif event.is_action("click"):
		if not Rect2($VBoxContainer.global_position, $VBoxContainer.size).has_point(get_global_mouse_position()):
			queue_free()
			end.emit("")

func found_() -> void:
	var a = %Search.text.split(' ')
	a[0] = top_search_result_
	
	var command = PureData.found_(' '.join(a), position)
	end.emit(command)

func try_load_subpatch_():
	var a = %Search.text.split(' ')
	top_search_result_ = a[0]
	
	var nm = NodeDb.get_node_model(top_search_result_)
	if nm:
		top_search_result_ = nm.title
	
