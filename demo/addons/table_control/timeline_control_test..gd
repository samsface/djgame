extends Node2D


func _add_row_pressed() -> void:
	$TimelineControl.add_row()

func _row_pressed(row_idx:int, time:int) -> void:
	var item := PianoRollItem.new()
	item.time = time
	$TimelineControl.add_item(item, row_idx)

func _duplicate_pressed() -> void:
	var dup = $TimelineControl.duplicate(1 + 2 + 4)
	dup.position.y = 450
	add_child(dup)
