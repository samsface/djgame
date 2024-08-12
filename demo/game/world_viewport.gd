extends SubViewportContainer

@onready var subviewport_ = $SubViewport

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Bus.config_service.graphics_quality_changed.connect(_invalidate_graphics_quality)
	_invalidate_graphics_quality()

	subviewport_.get_window().focus_entered.connect(func():
		print_debug("focus entered main window")
		Bus.camera_service.cursor.disabled = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		)

	subviewport_.get_window().focus_exited.connect(func():
		print_debug("focus exited main window")
		Bus.camera_service.cursor.disabled = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		)

func _invalidate_graphics_quality() -> void:
	match Bus.config_service.graphics_quality:
		ConfigService.GraphicsQuality.HIGH:
			subviewport_.msaa_3d = Window.MSAA_8X
			subviewport_.screen_space_aa = Window.SCREEN_SPACE_AA_FXAA
			subviewport_.use_taa = false
			subviewport_.scaling_3d_scale = 0.5
			get_tree().call_group("light", "set_visible", true)
		ConfigService.GraphicsQuality.LOW:
			subviewport_.msaa_3d = Window.MSAA_DISABLED
			subviewport_.screen_space_aa = Window.SCREEN_SPACE_AA_DISABLED
			subviewport_.use_taa = false
			subviewport_.scaling_3d_scale = 0.5
			get_tree().call_group("light", "set_visible", false)
		ConfigService.GraphicsQuality.POTATO:
			subviewport_.msaa_3d = Window.MSAA_DISABLED
			subviewport_.screen_space_aa = Window.SCREEN_SPACE_AA_DISABLED
			subviewport_.use_taa = false
			subviewport_.scaling_3d_scale = 0.25
			get_tree().call_group("light", "set_visible", false)
