extends RythmicAnimationPlayerControlItem

@export var property:String : 
	set(v):
		property = v
		invalidate_value_()

@export var to_value:float : 
	set(v):
		to_value = v
		invalidate_value_()

func _ready():
	invalidate_value_()

func invalidate_value_() -> void:
	self_modulate = Color.DARK_SLATE_GRAY
	
	$Label.text = "%s->%s" % [property, to_value]

func begin():
	var target_node = get_target_node()
	if target_node:
		target_node.create_tween().tween_property(target_node, property, to_value, length)
