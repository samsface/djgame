extends Control

var syntax_highligher_:CodeHighlighter

@export var base_instance:Node
@onready var code_edit_ = $CodeEdit
@onready var error_text_ = $Error

var symbol_color_ := Color.DEEP_PINK
var varialbe_color_ := Color.GRAY

func _ready():
	syntax_highligher_ = code_edit_.syntax_highlighter
	invalidate_base_instance_properties()

func invalidate_base_instance_properties() -> void:
	syntax_highligher_.clear_keyword_colors()
	
	syntax_highligher_.add_keyword_color("and", symbol_color_)
	syntax_highligher_.add_keyword_color("or", symbol_color_)
	syntax_highligher_.add_keyword_color("not", symbol_color_)
	syntax_highligher_.add_keyword_color("true", symbol_color_)
	syntax_highligher_.add_keyword_color("false", symbol_color_)

	if base_instance == null:
		return

	var property_list := base_instance.get_property_list()
	for property in property_list:
		if property.usage & PROPERTY_USAGE_EDITOR == 0:
			continue
		syntax_highligher_.add_keyword_color(property.name, Color.GRAY)

func add_code_completion_options_() -> void:
	code_edit_.add_code_completion_option(CodeEdit.KIND_CONSTANT, "and", "and", symbol_color_, preload("op_icon.png"))
	code_edit_.add_code_completion_option(CodeEdit.KIND_CONSTANT, "or", "or", symbol_color_, preload("op_icon.png"))
	code_edit_.add_code_completion_option(CodeEdit.KIND_CONSTANT, "not", "not", symbol_color_, preload("op_icon.png"))
	code_edit_.add_code_completion_option(CodeEdit.KIND_CONSTANT, "true", "true", symbol_color_, preload("op_icon.png"))
	code_edit_.add_code_completion_option(CodeEdit.KIND_CONSTANT, "false", "false", symbol_color_, preload("op_icon.png"))

	if base_instance == null:
		return

	var property_list := base_instance.get_property_list()
	for property in property_list:
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue

		code_edit_.add_code_completion_option(CodeEdit.KIND_VARIABLE, property.name, property.name, varialbe_color_, preload("bool_icon.png"))

func _text_changed():
	add_code_completion_options_()
	code_edit_.update_code_completion_options(true)

	var expr := Expression.new()
	if expr.parse(code_edit_.text) != OK:
		show_error_(expr.get_error_text())
		return

	var res = expr.execute([], base_instance if base_instance else self)
	if expr.has_execute_failed():
		show_error_(expr.get_error_text())
		return

	hide_error_()
	
	print(res)

func show_error_(error_string:String) -> void:
	error_text_.text = error_string
	error_text_.visible = true

func hide_error_() -> void:
	error_text_.visible = false
