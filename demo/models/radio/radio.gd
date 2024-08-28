@tool
extends Device

signal on_pressed

@export var on:bool :
	set(v):
		on = v
		on_()

@export var frequency:float :
	set(v):
		frequency = v
		%FrequencyLabel.text = "[font_size=24]%.1f" % frequency + " FM[/font_size]"
		
@export var channel_name:String :
	set(v):
		channel_name = v
		%ChannelNameLabel.text = "[font_size=32]%s[/font_size]" %channel_name

func _channel_1_button_pressed(value) -> void:
	if value:
		tween_to_channel(98.1, "POP HEADS", 0.5)

func _channel_2_button_pressed(value) -> void:
	if value:
		tween_to_channel(98.5, "WEAHTER", 0.5)

func _channel_3_button_pressed(value) -> void:
	if value:
		tween_to_channel(102.8, "D HIP HOP", 0.5)

func _channel_4_button_pressed(value) -> void:
	if value:
		tween_to_channel(112.0, "CLASSIC FM", 0.5)

func _power_button_pressed(value:float) -> void:
	on = not on
	on_pressed.emit()

func on_() -> void:
	if on:
		%FrequencyLabel.visible = true
		%ChannelNameLabel.visible = true

		var f = frequency
		var c = channel_name
		frequency = 0
		channel_name = "XXXXXXX"
		tween_to_channel(f, c, 1.0)
		$NorthFace/LedDisplayMesh.mesh.material.emission_energy_multiplier = 16.0
		
	else:
		%FrequencyLabel.visible = false
		%ChannelNameLabel.visible = false
		$NorthFace/LedDisplayMesh.mesh.material.emission_energy_multiplier = 0.0
		
	on_pressed.emit()

func tween_to_channel(frequency:float, channel_name:String, duration:float) -> void:
	if tween_:
		tween_.kill()
		
	tween_ = create_tween()
	tween_.set_ease(Tween.EASE_OUT)
	tween_.set_trans(Tween.TRANS_CUBIC)
	tween_.set_parallel()
	tween_.tween_property(self, "frequency", frequency, duration)
	tween_.tween_property(self, "channel_name", channel_name, duration)
