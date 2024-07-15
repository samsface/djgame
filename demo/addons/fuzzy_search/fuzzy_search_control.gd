extends VBoxContainer

signal found(String, Object)
signal cancel

@export var data:Array[String]
@export var data_user:Array

func _ready() -> void:
	$LineEdit.grab_focus()
	$LineEdit.gui_input.connect(_gui_input)
	$LineEdit.focus_exited.connect(func(): cancel.emit())
	
func _search_text_changed(new_text: String) -> void:
	for child in $SearchResults.get_children():
		child.queue_free()
		$SearchResults.remove_child(child)
	
	var fs := FuzzySearch.new()
	fs.data = data
	var search = fs.search(new_text)
	for search_result in search:
		var button := preload("res://addons/fuzzy_search/fuzzy_search_result_item.tscn").instantiate()
		button.get_node("RichTextLabel").text = search_result[1]
		button.set_meta("search_result", search_result)
	
		$SearchResults.add_child(button)

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var s = $SearchResults.get_child(0).get_meta("search_result")
		if data_user.size() > s[2]:
			found.emit(s[0], data_user[s[2]])
		else:
			found.emit(s[0], null)
	elif event.is_action_pressed("ui_cancel"):
		cancel.emit()
