extends Node2D


func _add_row_pressed() -> void:
	$TimelineControl.add_row()

func _row_pressed(row_idx:int, time:int) -> void:
	var item := TimelineControlItem.new()
	item.time = time
	$TimelineControl.add_item(item, row_idx)

func _duplicate_pressed() -> void:
	var dup = $TimelineControl.duplicate(1 + 2 + 4)
	dup.position.y = 450
	add_child(dup)

func _add_row_with_control_pressed() -> void:
	var label := Label.new()
	label.text = "sam"
	$TimelineControl.add_row(label)


func _timeline_control_add_row_pressed() -> void:
	_add_row_pressed()
