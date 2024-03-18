extends Node

var chats := PhoneChats.new()

var last_notification_

@onready var notifications_ = $"../CanvasLayer2/Notifications"

func _input(event: InputEvent) -> void:
	pass

func _ready() -> void:
	get_parent().look()
	
	var chat_app := preload("res://models/phone/contacts.tscn").instantiate()
	
	chat_app.chats = chats
	chat_app.notification_service_node_path = $"../CanvasLayer2/MarginContainer/Notifications".get_path()

	$"../SubViewport/PhoneGui".start_app(chat_app)
	
	setup_gf_chat_()
	setup_bf_chat_()
	setup_mm_chat_()

func _new_contact_pressed() -> void:
	var message := PhoneChatMessage.new()
	message.message = "Hey"
	message.sent_time = GameTime.now
	
	var chat := PhoneChat.new()
	chat.contact_image = preload("res://models/phone/giadi_small.png")
	chat.contact_name = "Giada"
	chat.messages.push_back(message)
	
	chats.chats[chat.contact_name] = chat
	
	chats.new_chat.emit(chat)

func _new_message_pressed() -> void:
	var message := PhoneChatMessage.new()
	message.message = "I knew it. You've been out DJing again :("
	message.sent_time =  GameTime.now
	
	chats.chats.values()[0].messages.push_back(message)
	chats.chats.values()[0].unread_count += 1
	chats.chats.values()[0].new_message.emit(message)

func _vibrate_pressed() -> void:
	get_parent().vibrate()

func setup_gf_chat_() -> void:
	var chat := PhoneChat.new()
	chat.contact_image = preload("res://models/phone/giadi_small.png")
	chat.contact_name = "Giada"

	var history := [
		"me:Hello!",
		"me:Hey!",
		"me:Hi",
	]

	chat.from_simple(history)
	chats.chats[chat.contact_name] = chat
	chats.new_chat.emit(chat)
	
func setup_bf_chat_() -> void:
	var chat := PhoneChat.new()
	chat.contact_image = preload("res://models/phone/toast.png")
	chat.contact_name = "Gorpho"
	
	var history := [
		"Gorpho:What time are you playing?",
		"me:Starting at 11",
		"Gorpho:You feeling good about it?",
		"me:meh, crowd isn't here for me",
		"Gorpho:True but have fun, leaving in 10"
	]
	
	chat.from_simple(history)
	chats.chats[chat.contact_name] = chat
	chats.new_chat.emit(chat)
	
func setup_mm_chat_() -> void:
	var chat := PhoneChat.new()
	chat.contact_image = preload("res://models/phone/gorpho.png")
	chat.contact_name = "Mano"

	var history := [
		"Mano:You're on at 11 tonight ok?",
		"me:Cool, thanks for setting this up",
		"Mano:Np",
		"me:Hey just setting up now..."
	]
	chat.from_simple(history)
		
	var message := PhoneChatMessage.new()
	message.message = "Cool, txt me when you want to start"
	message.replies = ["Let's go."]
	message.reply.connect(_reply)
	
	chat.messages.push_back(message)

	chats.chats[chat.contact_name] = chat
	chats.new_chat.emit(chat)

func _reply(reply_idx:int):
	Camera.level.play()

func dialog(length:float, who:String, value:String, replay_a:String, reply_b:String) -> void:
	var message := PhoneChatMessage.new()
	message.contact_name = who
	message.message = value
	message.sent_time = GameTime.now
	message.replies = [replay_a, reply_b]

	var chat = chats.chats[who]
	chat.messages.push_back(message)
	chat.unread_count += 1
	chat.new_message.emit(message)
