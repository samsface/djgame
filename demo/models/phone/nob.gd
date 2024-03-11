extends Nob

var value := 0.0
var electric := Color.TRANSPARENT

@onready var path_follow = $Path/PathFollow
@onready var remote_transform = $Path/PathFollow/RemoteTransform
