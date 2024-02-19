extends Node3D
class_name Device

signal value_changed

@export var patch:String
@export var map:DeviceData

var tween_:Tween
var select := "1"

func _ready() -> void:
	await get_tree().process_frame
	
	if map:
		for m in map.radios + map.exprs + map.arrays + map.sliders + map.bangs:
			m.hook(self)
			#n.impulse.connect(_impulse)

func get_view_position(from_position := Vector3.ZERO) -> Vector3:
	for view in $Views.get_children():
		if from_position.distance_to(view.global_position):
			return view.global_position

	return from_position
