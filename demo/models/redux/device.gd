@tool
extends Node3D

@onready var base_mesh_ := $CSGCombiner3D/CSGMesh3D

func _ready():
	HyperRandom.call_recursive(self, 3, func(child):
		if child.has_node("CutOut"):
			var cut_out = child.get_node("CutOut")
			child.remove_child(cut_out)
			cut_out.visible = true
			base_mesh_.add_child(cut_out)
			var remote_transform := RemoteTransform3D.new()
			remote_transform.remote_path = cut_out.get_path()
			child.add_child(remote_transform))

func invalidate_labels_() -> void:
	pass
