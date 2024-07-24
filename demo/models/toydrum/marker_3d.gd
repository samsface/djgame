@tool
extends Marker3D
class_name CameraAngle

@export var match_editor_camera_transform:bool :
	set(v):
		if Engine.is_editor_hint():
			var editor_camera := EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
			position = editor_camera.position
			rotation = editor_camera.rotation
			
			editor_camera.position = global_position
			editor_camera.rotation = global_rotation

@export var show_camera_angle_in_editor:bool :
	set(v):
		if Engine.is_editor_hint():
			var editor_camera := EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
			editor_camera.position = global_position
			editor_camera.rotation = global_rotation
