extends Node
class_name InpsectorVirtualProperties

@export var node:Control : 
	set(v):
		node = v
		
@export var parent:Control

var grid_size : 
	set(v):
		pass
	get:
		return parent.piano_roll_.grid_size

enum Type {
	bang,
	slide,
	method,
	dialog,
	tween,
	scene
}

@export var type:Type : 
	set(value):
		parent.change_type_(node, value)
	get:
		if node:
			return node.get_meta("__type__", Type.bang)
		else:
			return 0

@export var time:int : 
	set(value):
		if node:
			node.position.x = value * grid_size
	get:
		if node:
			return int(node.position.x / grid_size)
		else:
			return 0

@export var length:int = 1 : 
	set(value):
		if node:
			node.size.x = value * grid_size
	get:
		if node:
			return int(node.size.x / grid_size)#
		else:
			return 0
