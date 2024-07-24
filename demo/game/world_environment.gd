extends WorldEnvironment
class_name WorldEnviromentService

@onready var sun:DirectionalLight3D = $Sun
@onready var sky:ProceduralSkyMaterial :
	set(v):
		pass
	get:
		return environment.sky.sky_material

func _ready() -> void:
	Bus.config_service.graphics_quality_changed.connect(_invalidate_graphics_quality)
	_invalidate_graphics_quality()

func _invalidate_graphics_quality() -> void:
	match Bus.config_service.graphics_quality:
		ConfigService.GraphicsQuality.HIGH:
			environment = preload("res://game/settings/environment_high.tres")
			camera_attributes.dof_blur_far_enabled = false
			camera_attributes.dof_blur_near_enabled = true
			$Sun.shadow_enabled = true
		ConfigService.GraphicsQuality.LOW:
			environment = preload("res://game/settings/environment_potato.tres")
			camera_attributes.dof_blur_far_enabled = false
			camera_attributes.dof_blur_near_enabled = false
			$Sun.shadow_enabled = true
			await get_tree().process_frame
			camera_attributes.dof_blur_far_enabled = false
		ConfigService.GraphicsQuality.POTATO:
			environment = preload("res://game/settings/environment_potato.tres")
			camera_attributes.dof_blur_far_enabled = false
			camera_attributes.dof_blur_near_enabled = false
			$Sun.shadow_enabled = false
			await get_tree().process_frame
			camera_attributes.dof_blur_far_enabled = false
		
