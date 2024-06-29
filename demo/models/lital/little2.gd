extends Node3D
class_name Device

signal value_changed

@export var map:DeviceData

var tween_:Tween
var select := "1"
var current_view_position_:Node3D

func _ready() -> void:
	await get_tree().process_frame
	
	if map:
		for m in map.radios + map.exprs + map.arrays + map.sliders + map.bangs:
			m.hook(self)

func get_view_position(from_position := Vector3.ZERO) -> Vector3:
	if not current_view_position_:
		return Vector3.ZERO

	return current_view_position_.global_position

func look(view_position_idx:int = 0) -> void:
	current_view_position_ = $Views.get_child(view_position_idx)
	Bus.camera_service.look_at_node(self)

func set_swing(value:float):
	Bus.audio_service.emit_float("toykit-swing", value)

func set_preset(value:float):
	Bus.audio_service.emit_float("acid-preset", value)
