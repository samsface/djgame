@tool
extends Resource
class_name LabelStyle

@export var size:int : 
	set(v):
		size = v
		emit_changed()
@export var font:String :
	set(v):
		font = v
		emit_changed()
@export_range(-1.0, 1.0) var curve:float :
	set(v):
		curve = v
		emit_changed()
