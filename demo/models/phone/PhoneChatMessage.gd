class_name PhoneChatMessage
extends Resource

signal reply

@export var contact_name:String
@export var message:String
@export var image:Texture
@export var sent_time:float
@export var read := false
@export var replies:Array[String]
@export var click:String
@export var click_caret:int
@export var click_auto_send:bool
@export var clear_replies_on_reply := true
@export var notification_timeout := 10
