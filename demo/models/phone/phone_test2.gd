extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var stream := preload("res://models/phone/stream/live_stream_app.tscn").instantiate()
	$Phone.get_phone_gui().start_app(stream)
	
	
	for i in 100:
		await get_tree().create_timer(randf()).timeout
		stream.add_message(preload("res://game/livestream_service/profile_pictures/46e89f7fcf1db7c2d29565707b497855.webp"), "sam", "hey")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
