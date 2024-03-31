@tool
extends Node3D
class_name Knob

@export var label_style:LabelStyle : 
	set(v):
		label_style = v
		label_style.changed.connect(invalidate_labels_)
		invalidate_labels_()

@export var label:String :
	set(v):
		label = v
		$Label.mesh.text = v

func invalidate_labels_() -> void:
	$Label.mesh.font_size = label_style.size
