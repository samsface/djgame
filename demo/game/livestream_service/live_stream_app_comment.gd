extends HBoxContainer

@export var profile_picture:Texture :
	set(v):
		profile_picture = v
		$MarginContainer/TextureRect.texture = v
@export var user_name:String :
	set(v):
		user_name = v
@export var text:String :
	set(v):
		text = v
		invalidate_()
		
func invalidate_() -> void:
	$RichTextLabel.text = "[font_size=14][color=gray]%s[/color]    %s[/font_size]" % [user_name, text]
