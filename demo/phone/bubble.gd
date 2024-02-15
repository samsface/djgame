extends Control

signal finished
signal clicked

@onready var bubble_ = $bubble
@onready var text_ = $bubble/VBoxContainer/Label
@onready var image_ = get_node("%Image")

@export var color:Color
@export var text:String
@export var image:Texture
@export var left_aligned:bool
@export var animate:bool

var tween_:Tween

func _ready():

	modulate.a = 0.0
	
	var font:Font = text_.get_theme_default_font()
	
	image_.texture = image
	if not image_.texture:
		image_.custom_minimum_size = Vector2.ZERO
		
	text_.text = text
	
	for i in 3:
		await get_tree().process_frame
		if not is_inside_tree():
			return
	
	var text_size = font.get_multiline_string_size(text_.get_parsed_text(), 0)

	if text_size.x > 256:
		text_size = font.get_multiline_string_size(text_.get_parsed_text(), 0, 256)
		custom_minimum_size.y = text_size.y + 4 + image_.size.y
	else:	
		custom_minimum_size.y = text_size.y + 4 + image_.size.y
	
	text_size.x += 16 # for content margins

	bubble_.size.y = text_size.y + 3 + image_.size.y
	bubble_.size.x = size.x

	var t = size.x - text_size.x
	if not left_aligned:
		bubble_.position.x += size.x
		bubble_.self_modulate = Color.DARK_GREEN
	else:
		t = 0

	bubble_.size.x = 0
	text_.visible_ratio = 0.0
	
	modulate.a = 1.0
	
	var time:float = min(0.5, (text_size.x / size.x) * 1.5)
	var trans := Tween.TRANS_CIRC
	var easee := Tween.EASE_IN_OUT

	if not animate:
		time = 0.0
	
	tween_ = create_tween()
	tween_.set_parallel()

	tween_.tween_property(bubble_, "position:x", t, time).set_ease(easee).set_trans(trans)
	tween_.tween_property(bubble_, "size:x", text_size.x, time).set_ease(easee).set_trans(trans)
	tween_.tween_property(text_, "visible_ratio", 1.0, time).set_delay(time * 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)

	tween_.finished.connect(self.emit_signal.bind("finished"))
	
	bubble_.gui_input.connect(_gui_input)
	
func _gui_input(event) -> void:
	if Input.is_action_just_pressed("click"):
		clicked.emit()
