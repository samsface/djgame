extends Node2D

signal end

var fuzzy_search_ := FuzzySearch.new()
var top_search_result_

func _ready() -> void:
	%Search.grab_focus()

	fuzzy_search_.data = NodeDb.db.keys()

func _text_changed(new_text: String) -> void:
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
		if top_search_result_:
			queue_free()
			end.emit(top_search_result_)

	elif event.is_action("click"):
		if not Rect2($VBoxContainer.global_position, $VBoxContainer.size).has_point(get_global_mouse_position()):
			queue_free()
			end.emit("")
