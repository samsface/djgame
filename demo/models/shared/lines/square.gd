@tool
extends Node3D

@export var line_style:LineStyle :
	set(v):
		line_style = v
		line_style.changed.connect(invalidate_labels_)
		invalidate_labels_()
		
@export var size:Vector2 :
	set(v):
		size = v
		$Node3D.set_instance_shader_parameter("size", size)

func invalidate_labels_() -> void:
	$Node3D.set_instance_shader_parameter("line_width", line_style.line_width)
	$Node3D.set_instance_shader_parameter("fill_line_width", line_style.fill_line_width)
	$Node3D.set_instance_shader_parameter("fill_line_spacing", line_style.fill_line_spacing)
