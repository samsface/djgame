extends Node

var camera_service:CameraService
var crowd_service
var level:Level
var guide_service:GuideService
var audio_service:AudioService
var points_service
var input_service:InputService

func _ready() -> void:
	input_service = InputService.new()
	add_child(input_service)
