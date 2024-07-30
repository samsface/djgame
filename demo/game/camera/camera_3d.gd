extends Camera3D

@export var noise:NoiseTexture2D

var noise_:Noise
var idx_ := 0.0

func _ready():
	noise_ = noise.noise

func _process(delta):

	position.x = 0
	position.z = 0
	position.y = sin(idx_) * 0.0005

	idx_ += delta
