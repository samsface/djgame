extends MarginContainer

@onready var contacts_ = get_node("%Contacts")
@export var chats:PhoneChats : 
	set(value):
		chats = value
		chats.new_chat.connect(_new_chat)
@export var notification_service_node_path:NodePath

var chat_

func _contact_pressed(chat:PhoneChat) -> void:
	if chat_:
		chat_.queue_free()
		chat_.get_parent().remove_child(chat_)

	chat_ = preload("res://models/phone/chat.tscn").instantiate()
	chat_.chat = chat
	chat_.tree_exited.connect(_chat_exit)
	add_child(chat_)

func _chat_exit() -> void:
	chat_ = null

func _new_chat(phone_chat:PhoneChat) -> void:
	var contact_list_item = preload("res://models/phone/contacts_list_item.tscn").instantiate()
	contact_list_item.pressed.connect(_contact_pressed.bind(phone_chat))
	contact_list_item.contact_name = phone_chat.contact_name
	contact_list_item.contact_image = phone_chat.contact_image
	contact_list_item.unread_count = phone_chat.unread_count
	if not phone_chat.messages.is_empty():
		contact_list_item.message = phone_chat.messages.back().message
		contact_list_item.time_stamp = phone_chat.messages.back().sent_time
	else:
		contact_list_item.message = ""
 
	phone_chat.changed.connect(_chat_changed.bind(phone_chat, contact_list_item))
	phone_chat.new_message.connect(_new_message.bind(phone_chat, contact_list_item))

	contacts_.add_child(contact_list_item)
	contacts_.move_child(contact_list_item, 0)

func _visibility_changed():
	pass

func _chat_changed(chat:PhoneChat, contact_list_item:Node) -> void:
	contact_list_item.message = chat.messages.back().message
	contact_list_item.time_stamp = chat.messages.back().sent_time
	contact_list_item.unread_count = chat.unread_count

func _new_message(message:PhoneChatMessage, chat:PhoneChat, contact_list_item:Node) -> void:
	if message.contact_name == "me":
		return
	
	contacts_.move_child(contact_list_item, 0)
	
	var notification_service = get_node_or_null(notification_service_node_path)
	if notification_service:
		notification_service.show_notification(chat.messages.back(), chat)
