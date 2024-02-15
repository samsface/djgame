extends Node

var chats := PhoneChats.new()

func _input(event: InputEvent) -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$"../phone".rotation.x += delta * 0.1

func _new_contact_pressed() -> void:
	var message := PhoneChatMessage.new()
	message.message = "hello"
	message.sent_time = GameTime.now
	
	var chat := PhoneChat.new()
	chat.contact_image = preload("res://icon.svg")
	chat.contact_name = "sam"
	chat.messages.push_back(message)
	
	chats.chats[chat.contact_name] = chat

	$"../phone/SubViewport/PhoneGui/App"._new_chat(chat)

func _new_message_pressed() -> void:
	var message := PhoneChatMessage.new()
	message.message = "ssss" + str(randf())
	message.sent_time =  GameTime.now
	
	chats.chats.values()[0].messages.push_back(message)
	chats.chats.values()[0].unread_count += 1
	chats.chats.values()[0].new_message.emit(message)
