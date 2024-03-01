extends Node2D

var time_ = 0.0
var time_range_ := Vector2i(0, 16)
var stuff_
var delta_sum_ := 0.0

func _ready():
	$Table.row_pressed.connect(_row_pressed)
	$Table.selection_changed.connect(_item_selected)
	$Table.cursor.visible = true
	$Table.add_row()

func _row_pressed(row) -> void:
	var c := Button.new()
	c.position.x = row.get_local_mouse_position().x
	$Table.add_item(c, row)

func _item_selected(selection:Array) -> void:
	if selection:
		$Inspector.node = selection[0]
	else:
		$Inspector.node = ""
