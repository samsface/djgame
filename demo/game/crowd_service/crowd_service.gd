extends Node3D

var delta_sum_ := 0.0

func _ready() -> void:
	Bus.crowd_service = self

func clap(value:float) -> void:
	$Clap.play()
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property($Ch03_nonPBR, "clap", value, 1.0)
	tween.tween_property($Ch03_nonPBR2, "clap", value, 1.0)
	
	tween.tween_property($Ch03_nonPBR, "clap", 0.0, 1.0).set_delay(1.0)
	tween.tween_property($Ch03_nonPBR2, "clap", 0.0, 1.0).set_delay(1.0)

func scream() -> void:
	$Scream.play()

func _physics_process(delta: float) -> void:
	delta_sum_ += delta
#	visible = sin(delta_sum_ * 100.0) > -0.5

func look(view_position_idx:int = 0) -> void:
	Bus.camera_service.look_at_node(self)

func get_view_position(from_position := Vector3.ZERO) -> Vector3:
	return $Marker3D.global_position

func set_attention(value:float) -> void:
	var tween := create_tween()
	tween.tween_property($Ch03_nonPBR, "attention", value, 1.0)
	tween.tween_property($Ch03_nonPBR2, "attention", value, 1.0)


func set_cheer(value:float) -> void:
	var tween := create_tween()
	tween.tween_property($Ch03_nonPBR, "cheer", value, 0.4)
	tween.tween_property($Ch03_nonPBR2, "cheer", value, 0.4)

func set_tired(value:float) -> void:
	var tween := create_tween()
	tween.tween_property($Ch03_nonPBR, "tired", value, 0.4)
	tween.tween_property($Ch03_nonPBR2, "tired", value, 0.4)
