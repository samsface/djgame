extends Node3D
class_name Device

signal value_changed
signal clicked


@export var map:DeviceData

var tween_:Tween
var select := "1"

var mouse_over := false

func _ready() -> void:
	await get_tree().process_frame
	
	if map:
		for m in map.radios + map.exprs + map.arrays + map.sliders + map.bangs:
			m.hook(self)

func set_swing(value:float):
	Bus.audio_service.emit_float("toykit-swing", value)

func set_preset(value:float):
	Bus.audio_service.emit_float("acid-preset", value)

func set_sample(idx:int, sample_path:String) -> void:
	Bus.audio_service.emit_message("toykit-set-sample-" + str(idx), [sample_path])

func _mouse_entered() -> void:
	set_physics_process(true)
	mouse_over = true

func _mouse_exited() -> void:
	set_physics_process(false)
	mouse_over = false

func _physics_process(delta: float) -> void:
	pass
