extends Node

var chats := PhoneChats.new()
var chat_app_

var last_notification_

@onready var notifications_ = $"../CanvasLayer2/Notifications"

class ChatBuilder:
	static func transform_string(input_string: String) -> String:
		# Split the input string by underscores
		var words = input_string.split("_")
		
		# Initialize an empty array to hold the final words
		var final_words = []
		
		for word in words:
			# Handle contractions manually
			if word == "wouldnt":
				final_words.append("wouldn't")
			elif word == "didnt":
				final_words.append("didn't")
			elif word == "cant":
				final_words.append("can't")
			elif word == "dont":
				final_words.append("don't")
			elif word == "im":
				final_words.append("I'm")
			elif word == "ive":
				final_words.append("I've")
			elif word == "youre":
				final_words.append("you're")
			elif word == "theyre":
				final_words.append("they're")
			elif word == "hes":
				final_words.append("he's")
			elif word == "shes":
				final_words.append("she's")
			elif word == "its":
				final_words.append("it's")
			else:
				# For other words, add them as they are
				final_words.append(word)
		
		# Join the final words with spaces
		var final_string = " ".join(final_words)
		
		return final_string
		
	var m_ := PhoneChatMessage.new()
	var reply_callbacks_ := []
	var sent_callbacks_ := []
	var node_:Node

	func _init(node) -> void:
		node_ = node
		m_.sent_time = GameTime.now
		m_.reply.connect(func(idx):
			reply_callbacks_[idx].call())

	func from(who:String) -> ChatBuilder:
		m_.contact_name = who
		return self
	
	func text(message:String) -> ChatBuilder:
		m_.message = message
		return self
	
	func add_reply(callable:Callable) -> ChatBuilder:
		var reply_text = transform_string(callable.get_method())
		m_.replies.push_back(reply_text)
		reply_callbacks_.push_back(callable)
		return self

	func send() -> void:
		var chat = node_.chats.chats[m_.contact_name]
		
		await node_.get_tree().create_timer(1.0).timeout
		chat.status = "Typing..."
		await node_.get_tree().create_timer(1.0).timeout
		chat.status = "Online"

		chat.messages.push_back(m_)
	
		chat.unread_count += 1
		chat.new_message.emit(m_)
		
		for c in sent_callbacks_:
			c.call()
		

	func add_points(stat:String, points:int) -> ChatBuilder:
		sent_callbacks_.push_back(func():
			Bus.points_service.build_points(stat, points, node_.get_parent().position, 1.8))
		return self

func build_message() -> ChatBuilder:
	return ChatBuilder.new(self)

func giada(text:String) -> ChatBuilder:
	return ChatBuilder.new(self).from("Giada").text(text)

func _ready() -> void:
	chat_app_ = preload("res://models/phone/contacts.tscn").instantiate()
	
	chat_app_.chats = chats
	chat_app_.notification_service_node_path = $"../CanvasLayer2/MarginContainer/Notifications".get_path()

	$"../SubViewport/PhoneGui".start_app(chat_app_)
	
	setup_gf_chat_()
	setup_bf_chat_()
	setup_mm_chat_()

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
	chat.begin_viewing.connect(func():
		get_parent().look(1)
		Bus.points_service.show_bar("love", true))
		
	chat.end_viewing.connect(func():
		get_parent().look(0)
		Bus.points_service.show_bar("love", false))

	#(giada("Hey did you play yet?")
	#.add_reply(_yep_was_fun)
	#.add_reply(_if_you_came_youd_know)
	#.send())

func _yep_was_fun() -> void:
	(giada("That's great : )")
	.add_reply(_thanks)
	.add_points("hp", -10)
	.send())

func _if_you_came_youd_know() -> void:
	(giada("I wanted to go. But I go stuck in a hole.")
	.add_reply(_no_you_did_not)
	.add_reply(understandable)
	.add_points("hp", -10).send())

func _no_you_did_not() -> void:
	(giada("You never beleive me :(")
	.add_points("hp", -10).send())

func understandable() -> void:
	pass

func _thanks() -> void:
	(giada("As usual.")
	.add_reply(_i_can_go_home)
	.add_points("hp", -10)
	.send())

func _i_can_go_home() -> void:
	(giada("No it's fine.")
	.add_points("hp", -10)
	.send())

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
	chats.chats[chat.contact_name] = chat
	chats.new_chat.emit(chat)
		
	#(build_message()
	#.from("Mano")
	#.text("Hey, txt my when to keep going.")
	#.add_reply(_lets_go)
	#.send())

func _lets_go() -> void:
	Bus.beat_service.jump("scene", false)
	Bus.level.play()

func dialog(db:Object, length:float, who:String, value:String, db_name:String, replay_a:String, reply_b:String) -> void:
	var message := PhoneChatMessage.new()
	message.contact_name = who
	message.message = value
	message.sent_time = GameTime.now
	message.replies = [replay_a, reply_b]

	message.reply.connect(func(reply_idx:int):
		db.set(db_name, reply_idx)
		)

	var chat = chats.chats[who]
	chat.messages.push_back(message)
	chat.unread_count += 1
	chat.new_message.emit(message)
