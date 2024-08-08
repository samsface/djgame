extends RythmicAnimationPlayerControlItem

@export var who:String :
	set(v):
		who = v
		invalidate_value_()

@export_multiline var value:String : 
	set(v):
		value = v
		invalidate_value_()

@export var db_name:String

@export var reply_a:String
@export var reply_b:String

func _ready():
	invalidate_value_()
	item_rect_changed.connect(invalidate_value_)

func invalidate_value_() -> void:
	text = value.replace("\n", " ")
	tooltip_text = text
	
func begin() -> void:
	var target_node = get_target_node()
	if target_node:
		if target_node.has_method("dialog"):
			target_node.dialog(db, length, who, value, db_name, reply_a, reply_b)
