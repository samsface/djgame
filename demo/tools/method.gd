extends Button

@export var method:StringName :
	set(v):
		method = v
		$Label.text = method
