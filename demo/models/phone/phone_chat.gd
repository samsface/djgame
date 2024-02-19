class_name PhoneChat
extends Resource

signal new_message
signal status_changed

@export var contact_name:String
@export var contact_image:Texture
@export var messages:Array[PhoneChatMessage]
@export var unread_count := 0 :
	set(value):
		unread_count = value
		changed.emit()
@export var status:String = "online" :
	set(value):
		status = value
		status_changed.emit()
