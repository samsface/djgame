extends RythmicAnimationPlayerControlItem

@export var match_viewport_camera_transform:bool :
	set(v):
			var node = get_target_node()
			if not node:
				return

			camera_position = node.camera_.global_position
			camera_rotation = node.camera_.global_rotation
			print(camera_rotation)

@export var camera_position:Vector3
@export var camera_rotation:Vector3

func begin() -> void:
	flash()
	
	var node = get_target_node()
	if not node:
		return
	
	if not node.has_method("looky"):
		return
	
	node.looky(camera_position, camera_rotation)
