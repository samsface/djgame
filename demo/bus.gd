extends Node

var camera_service:CameraService
var crowd_service
var level:Level
var guide_service:GuideService
var audio_service:AudioService
var points_service:PointsService
var input_service:InputService
var config_service:ConfigService
var beat_service

func _ready() -> void:
	input_service = InputService.new()
	add_child(input_service)
