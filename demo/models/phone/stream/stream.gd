extends Control

@export var profile_pictures:Array[Texture]

var user_names := [
	"GamerGuy123",
	"StarryNight21",
	"PixelQueen",
	"EpicVoyager",
	"CodeMaster",
	"DragonSlayer88",
	"MusicManiac",
	"VirtualDreamer",
	"SpeedDemon",
	"WonderWatcher",
	"CraftyCreator",
	"ShadowHunter",
	"MysticWizard",
	"CosmicTraveller",
	"SavvyScholar",
	"NatureLover",
	"TechGuru",
	"SportsFanatic",
	"BookWorm",
	"TravelBug",
	"GalacticGamer",
	"CreativeSoul",
	"VirtualNomad",
	"FantasyFreak",
	"LegendaryHero",
	"SereneSeeker",
	"AdventureAwaits",
	"QuickSilver",
	"StarGazer",
	"MindfulMeditator",
	"ArtisticMind",
	"CyberPunk",
	"MysterySolver",
	"RhythmRider",
	"HighFlyer",
	"OceanBreeze"
]

func _ready() -> void:
	if Bus.livestream_service:
		set_video_texture(Bus.livestream_service.get_texture())

func set_video_texture(texture:Texture) -> void:
	%VideoTexture.texture = texture

func add_message(profile_picture:Texture, user_name:String, text:String) -> void:
	var msg := preload("res://game/livestream_service/live_stream_app_comment.tscn").instantiate()
	msg.profile_picture = profile_picture
	msg.user_name = user_name
	msg.text = text
	%Comments.add_child(msg)

func add_message_from_random_user(text:String) -> void:
	var msg := preload("res://game/livestream_service/live_stream_app_comment.tscn").instantiate()
	msg.profile_picture = profile_pictures.pick_random()
	msg.user_name = user_names.pick_random()
	msg.text = text
	%Comments.add_child(msg)

func set_reply(reply_idx:int, text:String) -> void:
	if reply_idx == 0:
		%ReplyText0.text = text
	if reply_idx == 1:
		%ReplyText1.text = text

func _reply_0_pressed() -> void:
	add_message(preload("res://game/livestream_service/profile_pictures/24a0277cfbc26f6c714aa3ebbca07a3c.webp"), "DJ Hero", "thanks so much guys :)")
	
	await get_tree().create_timer(randf() + 1.5).timeout
	add_message_from_random_user("no thank you!")
	await get_tree().create_timer(randf()).timeout
	add_message_from_random_user("was awesome! great job!")
	await get_tree().create_timer(randf()).timeout
	add_message_from_random_user("so humble")
	await get_tree().create_timer(randf()).timeout
	add_message_from_random_user("the best new dj this summer")
	await get_tree().create_timer(randf()).timeout
	add_message_from_random_user("thanks DJ HERO!")
	await get_tree().create_timer(randf()).timeout
	add_message_from_random_user("what a nice guy")

func _reply_1_pressed() -> void:
	add_message(preload("res://game/livestream_service/profile_pictures/24a0277cfbc26f6c714aa3ebbca07a3c.webp"), "DJ Hero", "fuck all of you")

