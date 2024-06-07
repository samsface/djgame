extends InspectorControl

@export var packed_scenes:Array[PackedScene]

func _ready():
	for packed_scene in packed_scenes:
		%Value.add_item(packed_scene.resource_path.get_file().capitalize())
	
func _item_selected(index):
	value_changed.emit(packed_scenes[index])

func set_value(value) -> void:
	var search := packed_scenes.find(value)
	
	if %Value.selected == search:
		return
		
	if search > -1:
		%Value.selected = search
