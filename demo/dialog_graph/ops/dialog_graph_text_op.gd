extends GraphNode

signal fire(int)

@export var text:String
@export var replies:Array[String] = ["", ""]

func _ready() -> void:
	set_slot(0, true, 0, Color.BLUE, false, 0, Color.GREEN)
	set_slot(1, false, 0, Color.GREEN, true, 0, Color.GREEN)
	set_slot(2, false, 0, Color.GREEN, true, 0, Color.GREEN)

	$Text.set_value(text)
	$Reply0.set_value(replies[0])
	$Reply1.set_value(replies[1])

func _text_value_changed(value) -> void:
	text = value

func _reply_0_value_changed(value) -> void:
	replies[0] = value

func _reply_1_value_changed(value) -> void:
	replies[1] = value
	
func begin() -> void:
	if not get_parent():
		return
		
	if not get_node(get_parent().root_node):
		return

	get_node(get_parent().root_node).text(text, replies).connect(fire)
	
