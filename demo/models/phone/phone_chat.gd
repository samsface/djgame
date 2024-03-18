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

func from_simple(history:Array):
	for i in history.size():
		var message := PhoneChatMessage.new()
		message.contact_name = history[i].split(":")[0]
		message.message = history[i].split(":")[1]
		message.sent_time = GameTime.now
		messages.push_back(message)
