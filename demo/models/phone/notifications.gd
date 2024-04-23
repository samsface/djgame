extends Control

var last_notification_

func show_notification(message:PhoneChatMessage, chat:PhoneChat) -> void:
	#get_parent().get_parent().get_parent().vibrate()
	
	if Bus.camera_service.is_looking_at_parent(self):
		return

	var chat_notification := preload("res://models/phone/chat_notification.tscn").instantiate()
	chat_notification.message = message.message
	chat_notification.contact_name = chat.contact_name
	chat_notification.contact_image = chat.contact_image
	chat_notification.time_stamp = message.sent_time
	chat_notification.pressed.connect(_chat_notification_pressed.bind(chat))

	add_child(chat_notification)

	chat_notification.position.y = (get_child_count() - 1) * chat_notification.size.y - chat_notification.size.y
	chat_notification.z_index = 100 - get_child_count()
	var tween = chat_notification.create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(chat_notification, "position:y",  (get_child_count() - 1) * (chat_notification.size.y + 8), 0.45)

	last_notification_ = chat

	await get_tree().create_timer(9.0).timeout
	chat_notification.queue_free()

func _chat_notification_pressed() -> void:
	pass
