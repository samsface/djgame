extends PianoRollItem

@export var scene:String : 
	set(v):
		scene = v
		invalidate_scene_()

func _ready():
	invalidate_scene_()
	item_rect_changed.connect(invalidate_scene_)

func invalidate_scene_() -> void:
	$Label.text = scene

func op(db, node, length) -> void:
	node.play_scene(scene)

func end(db, node) -> void:
	node.stop_scene(scene)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.double_click:
			find_parent("BeatPlayerHost").show_scene(scene)
