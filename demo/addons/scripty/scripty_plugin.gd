@tool
extends EditorPlugin

var code_edit_:CodeEdit
var methods_ := []
var carets_ := []
var editing_token_:String
var mouse_down_ := false

func _enter_tree():
	EditorInterface.get_script_editor().editor_script_changed.connect(_on_editor_script_changed)

func _on_editor_script_changed(script) -> void:
	if code_edit_:
		code_edit_.caret_changed.disconnect(_caret_changed)
		code_edit_.text_changed.disconnect(_text_changed)
		code_edit_.gui_input.disconnect(_gui_input)
		code_edit_.remove_secondary_carets()
		code_edit_ = null
		editing_token_ = ""
	
	invalidate_methods_()
	
	code_edit_ = EditorInterface.get_script_editor().get_current_editor().get_base_editor()
	code_edit_.caret_changed.connect(_caret_changed)
	code_edit_.text_changed.connect(_text_changed)
	code_edit_.gui_input.connect(_gui_input)

func invalidate_methods_() -> void:
	methods_.clear()
	var method_list := EditorInterface.get_script_editor().get_current_script().get_script_method_list()

	for method in method_list:
		if method.name.begins_with("_"):
			methods_.push_back(method.name)

	print(methods_)

func search_all(text:String) -> Array:
	var res := []
	
	var search = code_edit_.search(editing_token_, TextEdit.SEARCH_WHOLE_WORDS, 0, 0)
	while search.x != -1 and not res.has(search):
		res.push_back(search)
		search = code_edit_.search(editing_token_, TextEdit.SEARCH_WHOLE_WORDS, res.back().y + 1, 0)

	return res

func _caret_changed() -> void:
	# don't activate if user is already messing with multiple cursors
	if code_edit_.get_caret_count() > 1:
		return
	
	carets_.clear()
	
	var p = code_edit_.get_caret_draw_pos(0)
	var word =  code_edit_.get_word_at_pos(p)

	prints("checking word", word)
	if methods_.has(word):
		editing_token_ = word
		prints("editing_token", word)

		var cl := code_edit_.get_caret_line()
		var cc := code_edit_.get_caret_column()
		var caret_offset = code_edit_.get_caret_column() - code_edit_.get_line(cl).find(editing_token_)

		for r in search_all(editing_token_):
			if r.y == code_edit_.get_caret_line(0):
				continue

			carets_.push_back(code_edit_.add_caret(r.y, r.x + caret_offset))
	else:
		if editing_token_:
			code_edit_.remove_secondary_carets()
			editing_token_ = ""

func _tessssst() -> void:
	_tessssst()

func _text_changed() -> void:
	#print("text_changed", editing_token_)
	if editing_token_:
		var p = code_edit_.get_caret_draw_pos(0)
		var new_editing_token =  code_edit_.get_word_at_pos(p)

		methods_.erase(editing_token_)
		methods_.push_back(new_editing_token)
		editing_token_ = editing_token_

func _gui_input(event) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		mouse_down_ = event.pressed
	
	elif event is InputEventMouseMotion and mouse_down_ and editing_token_:
		print("selecting so clear word")
		carets_.clear()
		code_edit_.remove_secondary_carets()
		#prints("not editing_token")
		editing_token_ = ""
