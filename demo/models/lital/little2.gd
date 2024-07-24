extends Node3D
class_name Device

signal value_changed

@export var map:DeviceData

var tween_:Tween
var select := "1"

func _ready() -> void:
	await get_tree().process_frame
	
	if map:
		for m in map.radios + map.exprs + map.arrays + map.sliders + map.bangs:
			m.hook(self)

func look(view_position:String) -> void:
	Bus.camera_service.look_at_node($Views.get_node_or_null(view_position))

func set_swing(value:float):
	Bus.audio_service.emit_float("toykit-swing", value)

func set_preset(value:float):
	Bus.audio_service.emit_float("acid-preset", value)

func set_sample(idx:int, sample_path:String) -> void:
	Bus.audio_service.emit_message("toykit-set-sample-" + str(idx), [sample_path])
