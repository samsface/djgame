extends WorldEnvironment


func _ready() -> void:
	Bus.config_service.graphics_quality_changed.connect(_invalidate_graphics_quality)
	_invalidate_graphics_quality()

func _invalidate_graphics_quality() -> void:
	match Bus.config_service.graphics_quality:
		ConfigService.GraphicsQuality.HIGH:
			environment = preload("res://settings/environment_high.tres")
			camera_attributes.dof_blur_far_enabled = true
		ConfigService.GraphicsQuality.POTATO:
			environment = preload("res://settings/environment_potato.tres")
			camera_attributes.dof_blur_far_enabled = false
