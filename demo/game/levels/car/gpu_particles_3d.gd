@tool
extends GPUParticles3D

@export var rows := 4 :
	set(v):
		rows = v
		update_aabb()
@export var spacing := 1.0 :
	set(v):
		spacing = v
		update_aabb()
		
func update_aabb() -> void:
	amount = rows * rows
	process_material.set_shader_parameter("rows", rows)
	process_material.set_shader_parameter("spacing", spacing)
	
	var size := rows * spacing
	visibility_aabb = AABB(Vector3(-0.5 * size, 0.0, -0.5 * size), Vector3(size, 20.0, size))

func _ready() -> void:
	update_aabb()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		global_position = EditorInterface.get_editor_viewport_3d(0 ).get_camera_3d().global_position
		global_position.y = 0
	else:
		var viewport = get_viewport()
		var camera = viewport.get_camera_3d()
		global_position = camera.global_position
		global_position.y = 0
