@tool
extends EditorPlugin

var code_edit_:CodeEdit
var methods_ := []
var editing_token_:String

func _enter_tree():
	EditorInterface.get_script_editor().editor_script_changed.connect(_on_editor_script_changed)

func _on_editor_script_changed(script) -> void:
	if code_edit_:
		code_edit_.caret_changed.disconnect(_caret_changed)
		code_edit_.text_changed.disconnect(_text_changed)
		code_edit_ = null
	
	methods_.clear()
	var method_list := EditorInterface.get_script_editor().get_current_script().get_script_method_list()
	for method in method_list:
		if method.name.begins_with("_"):
			methods_.push_back(method.name)
	
	code_edit_ = EditorInterface.get_script_editor().get_current_editor().get_base_editor()
	code_edit_.caret_changed.connect(_caret_changed)
	code_edit_.text_changed.connect(_text_changed)

func _caret_changed() -> void:
	if methods_.has(code_edit_.get_word_under_caret()):
		editing_token_ = code_edit_.get_word_under_caret()
		prints("editing_token", code_edit_.get_word_under_caret())
	else:
		editing_token_ = "sasssssssssssasssssssdssssasssmxzx"

func _text_changed() -> void:
	if editing_token_:
		var p = code_edit_.get_caret_draw_pos()
		var new_editing_token =  code_edit_.get_word_at_pos(p)
		code_edit_.text.replace("func " + editing_token_, "func " + new_editing_token)
		methods_.erase(editing_token_)
		methods_.push_back(new_editing_token)
		editing_token_ = editing_token_
