extends Nob

var value := 0.0 :
	set(v):
		if v == value:
			return

		value = 1.0
		bang_()
		await get_tree().process_frame
		value = 0.0

var electric:Color = Color.TRANSPARENT :
	set(v):
		electric = v
		$StaticBody3D.electric = v

@onready var remote_transform = $Path/PathFollow/RemoteTransform

var mouse_over_ := false
var down_ := false

func _ready() -> void:
	$StaticBody3D.mouse_entered.connect(_mouse_entered)
	$StaticBody3D.mouse_exited.connect(_mouse_exited)
	path_follow = $Path/PathFollow

func bang_() -> void:
	get_parent().click(global_position)

func _mouse_entered() -> void:
	mouse_over_ = true
	set_process_input(true)
	
	#$Nob/Model.hover_begin()
	
func _mouse_exited() -> void:
	mouse_over_ = false
	if not down_:
		set_process_input(false)
		#$Nob/Model.hover_end()

func _input(event: InputEvent) -> void:
	if down_:
		if event.is_action_released("click"):
			released()
		
	if mouse_over_:
		if event.is_action_pressed("click"):
			pressed()

func pressed() -> void:
	if down_:
		return

	down_ = true

	value = intended_value

	if has_node("Sound"):
		$Sound.play()

	Bus.camera_service.cursor.push(self, Cursor.Action.grab)
	#Bus.camera_service.cursor.try_set_position(self, global_position)

func released() -> void:
	if not down_:
		return

	down_ = false

	Bus.camera_service.cursor.pop(self)
