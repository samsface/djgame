extends Button

@export var who:String :
	set(v):
		who = v
		invalidate_value_()

@export_multiline var value:String : 
	set(v):
		value = v
		invalidate_value_()

@export var db_name:String

@export var replay_a:String
@export var replay_b:String

func _ready():
	invalidate_value_()
	item_rect_changed.connect(invalidate_value_)

func invalidate_value_() -> void:
	text = value.replace("\n", " ")
	tooltip_text = text

func op(db:Object, node:Node, length:float) -> void:
	node.dialog(db, length, who, value, db_name, replay_a, replay_b)
