extends GraphControlMode
class_name GraphControlPlayMode

var previous_title_:String

static func test(input:InputEvent, selection:Array) -> bool:
	if input.is_action_pressed("toggle_play_mode"):
		return true
	
	return false

func _ready() -> void:
	var window = get_viewport().get_window()
	if window:
		previous_title_ = window.title
		window.title = get_parent().patch_path.get_file() + " - play"
	
	for node in get_parent().get_children():
		node._play_mode_begin()

func _input(event:InputEvent) -> void:
	if event.is_action_pressed("toggle_play_mode"):
		done_()

func done_() -> void:
	var window = get_viewport().get_window()
	if window:
		window.title = previous_title_

	for node in get_parent().get_children():
		node._play_mode_end()
	
	queue_free()

func _play_mode_begin():
	pass

func _play_mode_end():
	pass
