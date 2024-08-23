@tool
extends Control

var tween_:Tween

@export var frequency:float :
	set(v):
		frequency = v
		%FrequencyLabel.text = "[font_size=24]%.1f" % frequency + " FM[/font_size]"
		
@export var channel_name:String :
	set(v):
		channel_name = v
		%ChannelNameLabel.text = "[font_size=32]%s[/font_size]" %channel_name

func tween_to_channel(frequency:float, channel_name:String, duration:float) -> void:
	if tween_:
		tween_.kill()
		
	tween_ = create_tween()
	tween_.set_ease(Tween.EASE_OUT)
	tween_.set_trans(Tween.TRANS_CUBIC)
	tween_.set_parallel()
	tween_.tween_property(self, "frequency", frequency, duration)
	tween_.tween_property(self, "channel_name", channel_name, duration)
