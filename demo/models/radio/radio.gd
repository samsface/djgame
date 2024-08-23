extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _channel_1_button_pressed(value) -> void:
	if value:
		%LedDisplay.tween_to_channel(98.1, "POP HEADS", 0.5)

func _channel_2_button_pressed(value) -> void:
	if value:
		%LedDisplay.tween_to_channel(98.5, "WEAHTER", 0.5)

func _channel_3_button_pressed(value) -> void:
	if value:
		%LedDisplay.tween_to_channel(102.8, "D HIP HOP", 0.5)

func _channel_4_button_pressed(value) -> void:
	if value:
		%LedDisplay.tween_to_channel(112.0, "CLASSIC FM", 0.5)
