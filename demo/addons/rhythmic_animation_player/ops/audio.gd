extends RythmicAnimationPlayerControlItem

var value:float : 
	set(v):
		value = v
#
func invalidate_value_() -> void:
	pass

func begin():
	var target_node = get_target_node()
	if not target_node:
		return
	
	if target_node is not AudioStreamPlayer:
		return
		
	target_node.play()

func interprolate(from, t):
	var target_node = get_target_node()
	if not target_node:
		return
		
	if target_node is not AudioStreamPlayer:
		return
		
	var sixteenth_duration = (60.0 / Bus.audio_service.metro) / 4

	target_node.seek(t * sixteenth_duration)
	
