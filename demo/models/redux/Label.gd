@tool
extends Node3D

@export var label_style:LabelStyle : 
	set(v):
		label_style = v
		label_style.changed.connect(invalidate_labels_)
		invalidate_labels_()

@export var label:String :
	set(v):
		label = v
		if has_node("Mesh"):
			$Mesh.mesh.text = v

func invalidate_labels_() -> void:
	$Mesh.mesh.font_size = label_style.size
	$Mesh.set_instance_shader_parameter("curve", label_style.curve)
