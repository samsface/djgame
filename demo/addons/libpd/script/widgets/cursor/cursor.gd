extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _play_mode_begin() -> void:
	pass
	
func _play_mode_end() -> void:
	pass


func _area_entered(area):
	return
	if area.has_method("_mouse_entered"):
		area._mouse_entered(area)

func _area_exited(area):
	return
	if area.has_method("_mouse_exited"):
		area._mouse_exited(area)
