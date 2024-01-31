extends Sprite2D

var x := Vector2.ZERO

func _ready() -> void:
	position = get_window().get_mouse_position()

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		x = event.relative

func update() -> void:
	position += x * 1.5
	x = Vector2.ZERO
