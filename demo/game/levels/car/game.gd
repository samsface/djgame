extends Node3D

var r
var road_blocks_ := []

var go_ := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Bus.audio_service.set_metro(((60000.0 / 132.0) / 4.0))
	get_viewport().get_camera_3d().far = 1000
	
	$ClipMap.material_override.set_shader_parameter("texture_road_distance", $SubViewport.get_texture())

func _physics_process(delta: float) -> void:
	$ClipMap.global_position = %Car.global_position
	$ClipMap.global_position.y = 0
