extends HBoxContainer

@export var value:NodePath : 
	set(v):
		value = v
		$Value.text = str(value)
	get:
		return value
