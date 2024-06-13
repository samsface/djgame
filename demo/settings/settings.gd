extends CanvasLayer
class_name ConfigService

signal graphics_quality_changed

enum GraphicsQuality {
	HIGH,
	MEDIUM,
	LOW,
	POTATO
}

@export var graphics_quality:GraphicsQuality :
	set(v):
		graphics_quality = v
		graphics_quality_changed.emit()
		save_()

var is_loading_ := false

func _enter_tree() -> void:
	visible = false

func _ready() -> void:
	load_()
	Bus.config_service = self

func _graphics_quality_selected(index: int) -> void:
	graphics_quality = index

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		visible = not visible
		Bus.camera_service.cursor.disabled = visible

func save_() -> void:
	if is_loading_:
		return

	var file := ConfigFile.new()
	file.set_value("graphics", "graphics_quality", graphics_quality)
	file.save("user://config.ini")

func load_() -> void:
	is_loading_ = true
	var file := ConfigFile.new()
	file.load("user://config.ini")
	graphics_quality = file.get_value("graphics", "graphics_quality", GraphicsQuality.MEDIUM)
	%GraphicsQuality.select(graphics_quality)
	is_loading_ = false
