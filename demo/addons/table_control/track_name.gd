extends MarginContainer

@export var value:NodePath : 
	set(v):
		$H/Value.text = str(v)
	get:
		return $H/Value.text
