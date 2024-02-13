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

func _impulse(from:Vector3, force:float) -> void:
	if tween_:
		tween_.kill()

	tween_ = create_tween()
	tween_.set_trans(Tween.TRANS_SPRING)
	tween_.set_ease(Tween.EASE_OUT)
	tween_.set_parallel()
	tween_.tween_property($Wrap, "position:z", $Wrap.position.z + sign(force) * 0.0001, 0.02)
	tween_.tween_property($Wrap, "rotation:x", 0.005 * sign(force), 0.01)
	tween_.set_parallel(false)
	tween_.tween_property($Wrap, "rotation:x", 0.0, 0.02)

func get_view_position(from_position := Vector3.ZERO) -> Vector3:
	for view in $Views.get_children():
		if from_position.distance_to(view.global_position):
			return view.global_position

	return from_position
