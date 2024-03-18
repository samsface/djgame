extends MarginContainer

@export var value:NodePath : 
	set(v):
		$H/Value.text = str(v)
	get:
		return $H/Value.text

@export var condition:String

func invalidate_() -> void:
	if condition.is_empty():
		$H/Value.visible = true
		$H/Condition.visible = false
	else:
		$H/Value.visible = false
		$H/Condition.visible = true
		$H/Condition.text = condition
