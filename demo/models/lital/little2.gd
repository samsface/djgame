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
		for m in map.radios + map.exprs + map.arrays:
			m.hook(self)
			#n.impulse.connect(_impulse)
	
func _value_changed(value, m:NobMapping) -> void:
	m = m.duplicate()
	m.name = m.name.format({ select=select })
	value_changed.emit(m, value)

func _expr(value, m:NobMapping) -> void:
	if value:
		select = m.name
	
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
