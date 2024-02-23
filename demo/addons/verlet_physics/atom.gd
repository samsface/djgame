class_name VerletAtom
extends Marker3D

@onready var last_position := position
@export var mass := 1.0
@export var density := 0.1
@export var dynamic := 1.0
@export var grav := 0.0
@export var red := 0.0
@export var blood := 0.0
@export var lock := 0.0
@export var friction_scale := 0.0


var friction := 0.0
var max_move_radius_ := 0.0
var max_move_radius_position_ := Vector3.ZERO
var debug = false

func _ready() -> void:
	if debug:
		var x = CSGSphere3D.new()
		x.radius = 0.0025
		add_child(x)

func tick(delta:float) -> void:
	if lock:
		return

	var tmp = position
	position += (position - last_position)
	last_position = tmp
	
	#if max_move_radius_ > 0.0:
	#	position = position.clamp(max_move_radius_position_ - Vector3.ONE * max_move_radius_, max_move_radius_position_ + Vector3.ONE * max_move_radius_)

func stop() -> void:
	last_position = position

func get_velocity() -> Vector3:
	return position - last_position

func move(v:Vector3) -> void:
	position += v
	
func add_impulse(impulse) -> void:
	last_position -= impulse

func set_velocity(p:Vector3, v:Vector3) -> void:
	position = p
	last_position = p - v

func _physics_process(delta: float) -> void:
	DebugDraw.point(self, global_position)

func lock_move_radius(position:Vector3, radius:float) -> void:
	max_move_radius_position_ = position
	max_move_radius_ = radius
