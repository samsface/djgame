extends Button

@export var who:String :
	set(v):
		who = v
		invalidate_value_()

@export var value:String : 
	set(v):
		value = v
		invalidate_value_()

@export var replay_a:String
@export var replay_b:String

func _ready():
	invalidate_value_()
	item_rect_changed.connect(invalidate_value_)

func invalidate_value_() -> void:
	text = who + ": \"" + value + "\""
