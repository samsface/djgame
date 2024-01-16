extends Button
class_name SearchResult

@export var top_result:bool : 
	set(value):
		top_result = value
		if top_result:
			self_modulate = Color.LIGHT_BLUE
		else:
			self_modulate = Color.GRAY

func _ready() -> void:
	$RichTextLabel.text = text
