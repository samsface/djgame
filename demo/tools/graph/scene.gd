extends Control

@export var scene:String

func op() -> void:
	pass

func _select() -> void:
	pass

func get_output_schema() -> Array:
	var outputs := []
	outputs.push_front(GraphControlNodeDatabase.C.new("done", "bang"))
	return outputs

func get_input_schema() -> Array:
	var inputs := []
	inputs.push_front(GraphControlNodeDatabase.C.new("value", "bang"))
	return inputs
