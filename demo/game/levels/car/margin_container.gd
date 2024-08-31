extends MarginContainer

signal finished

var tween_:Tween

@export var text:String :
	set(v):
		text = v
		if not is_node_ready():
			await ready
		
		if tween_:
			tween_.kill()

		tween_ = create_tween()
		
		$Text.text = prefix + text
		$Text.visible_ratio = 0
		
		var duration = $Text.get_total_character_count() * 0.025
		tween_.tween_property($Text, "visible_ratio", 1.0, duration)
		tween_.finished.connect(func(): finished.emit())

@export var prefix:String :
	set(v):
		prefix = v
