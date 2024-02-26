extends Node3D

signal points_changed

var damage_tween_:Tween

@export var points:int :
	set(value):
		points = value
		points_changed.emit(points)

func _ready() -> void:
	$CanvasLayer/ColorRect.material.set_shader_parameter("damage", 0.0)

func miss() -> void:
	if damage_tween_:
		damage_tween_.kill()

	damage_tween_ = create_tween()
	
	damage_tween_.tween_property($CanvasLayer/ColorRect.material, "shader_parameter/damage", 1.0, 0.05)
	damage_tween_.tween_property($CanvasLayer/ColorRect.material, "shader_parameter/damage", 0.0, 0.2)
