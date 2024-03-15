extends Node

signal replied

@export var chat:PhoneChat

@onready var chat_ = get_node("%Chat")
@onready var replies_ = get_node("%Replies")
@onready var status_ = get_node("%Status")
@onready var input_ = get_node("%TextEdit")

var clear_replies_on_reply_ := true

func _ready():
	get_node("%ContactName").text = chat.contact_name
	get_node("%ContactImage").texture = chat.contact_image
	
	for reply_button in replies_.get_children():
		reply_button.pressed.connect(_reply_pressed.bind(reply_button))

	if not chat.messages.is_empty():
		for message in chat.messages:
			add_message_(message, false, message == chat.messages.back())
		
	chat.unread_count = 0

	chat.new_message.connect(_new_message)
	chat.status_changed.connect(func(): status_.text = chat.status)

	scroll_to_bottom_()
	
	await get_tree().create_timer(0.1).timeout
	
	#input_.grab_focus()
	#get_node("%Send").pressed.connect(_send_pressed)
	
	%ScrollContainer.custom_minimum_size.y = 200

func add_message_(message:PhoneChatMessage, animate := false, show_replies := false):
	var x = preload("res://models/phone/bubble.tscn").instantiate()
	x.text = message.message
	x.animate = animate
	x.left_aligned = message.contact_name != "me"
	x.image = message.image
	x.color = Color.WHITE if x.left_aligned else Color.MEDIUM_SPRING_GREEN
	chat_.add_child(x)
	
	if not message.click.is_empty():
		x.clicked.connect(_message_clicked.bind(message))
	
	if  message.contact_name != "me":
		clear_replies_on_reply_ = message.clear_replies_on_reply
	
	if clear_replies_on_reply_:
		pass
	
	if show_replies:
		await x.finished

		for i in message.replies.size():
			replies_.get_child(i).text = message.replies[i]

func scroll_to_bottom_() -> void:
	#await get_tree().process_frame
	#await get_tree().process_frame
	chat_.get_parent().scroll_vertical = 9999999999999

func _new_message(message:PhoneChatMessage) -> void:
	add_message_(message, true, true)
	chat.unread_count = 0
	scroll_to_bottom_()

func _input(event) -> void:
	pass
	#if Input.is_action_just_pressed("back"):
	#	_back_pressed()

func _reply_pressed(reply_button) -> void:
	if reply_button.disabled:
		return

	var new_message := PhoneChatMessage.new()
	new_message.contact_name = "me"
	new_message.message = reply_button.text
	new_message.sent_time = GameTime.now

	if clear_replies_on_reply_:
		for reply in replies_.get_children():
			#reply.disabled = true
			reply.text = ""

	chat.messages.push_back(new_message)
	chat.new_message.emit(new_message)

func _back_pressed():
	queue_free()

func _send_pressed() -> void:
	_text_submitted(input_.text)

func _text_submitted(new_text):
	if new_text.is_empty():
		return

	var new_message := PhoneChatMessage.new()
	new_message.contact_name = "me"
	new_message.message = new_text
	new_message.sent_time = GameTime.now
	chat.messages.push_back(new_message)
	chat.new_message.emit(new_message)
	
	input_.clear()

func _message_clicked(message:PhoneChatMessage) -> void:
	input_.text = message.click
	
	if message.click_auto_send:
		_send_pressed()
	else:
		input_.grab_focus()
		input_.caret_column = message.click_caret

func _exit_tree() -> void:
	pass
