extends Node

var chats := PhoneChats.new()

var last_notification_

@onready var notifications_ = $"../CanvasLayer2/Notifications"

func _input(event: InputEvent) -> void:
	pass

func _ready() -> void:
	var chat_app := preload("res://models/phone/contacts.tscn").instantiate()
	
	chat_app.chats = chats
	chat_app.notification_service_node_path = $"../CanvasLayer2/MarginContainer/Notifications".get_path()

	$"../SubViewport/PhoneGui".start_app(chat_app)

func _new_contact_pressed() -> void:
	var message := PhoneChatMessage.new()
	message.message = "hello"
	message.sent_time = GameTime.now
	
	var chat := PhoneChat.new()
	chat.contact_image = preload("res://models/phone/giadi_small.png")
	chat.contact_name = "sam"
	chat.messages.push_back(message)
	
	chats.chats[chat.contact_name] = chat
	
	chats.new_chat.emit(chat)

func _new_message_pressed() -> void:
	var message := PhoneChatMessage.new()
	message.message = "ssss" + str(randf())
	message.sent_time =  GameTime.now
	
	chats.chats.values()[0].messages.push_back(message)
	chats.chats.values()[0].unread_count += 1
	chats.chats.values()[0].new_message.emit(message)

func _vibrate_pressed() -> void:
	get_parent().vibrate()
