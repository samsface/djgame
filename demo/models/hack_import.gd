@tool
extends EditorScenePostImport

func _post_import(scene):
	if scene.get_child_count() == 0:
		return
		
	var rigid_body:RigidBody3D = scene.get_child(0)
	if not rigid_body:
		return

	for child in rigid_body.get_children():
		rigid_body.remove_child(child)
		scene.add_child(child)
	
	scene.remove_child(rigid_body)
	
	return scene
