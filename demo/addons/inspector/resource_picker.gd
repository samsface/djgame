extends InspectorControl

@export var resources:Array

func set_property(property:Dictionary) -> void:
	property_ = property
	
	for r in resources:
		var item_name:String = r.resource_path.get_file()
		item_name = item_name.replace("." + item_name.get_extension(), "")
		
		var icon = InspectorPreview.generate_icon(property_.class_name, r)
		if icon:
			%Value.add_icon_item(icon, item_name)
		else:
			%Value.add_item(item_name)

func _item_selected(index):
	value_changed.emit(resources[index])

func set_value(value) -> void:
	var search := resources.find(value)
	
	if %Value.selected == search:
		return
		
	if search > -1:
		%Value.selected = search
