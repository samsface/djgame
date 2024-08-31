@tool
extends CanvasLayer

signal bars_changed

@onready var top_bar_ = $TopBar
@onready var bottom_bar_ = $BottomBar

@export_range(0.0, 1.0) var bars := 0.0 :
	set(v):
		bars = v
		if not is_node_ready():
			await ready
		invalidate_()

func _ready() -> void:
	Bus.bars = self

func get_rect() -> Rect2:
	return Rect2(0, top_bar_.size.y, top_bar_.size.x, bottom_bar_.position.y)

func invalidate_() -> void:
	top_bar_.size.y = get_viewport().size.y * 0.5 * bars
	bottom_bar_.size.y = get_viewport().size.y * 0.5 * bars
	bottom_bar_.position.y =  get_viewport().size.y - bottom_bar_.size.y
	bars_changed.emit()
