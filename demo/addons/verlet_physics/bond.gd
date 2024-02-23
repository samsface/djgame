class_name VerletBond
extends Node3D

@export var rest_distance_ := 0.0
@export var stretch := 0.1
@export var contract := 0.1
@export var atom_a:NodePath
@export var atom_b:NodePath
@export var debug_width = 1.0
@export var stretch_limit = INF

var atom_a_:VerletAtom
var atom_b_:VerletAtom
var debug_color_ := Color.WHITE

func _ready() -> void:
	atom_a_ = get_node(atom_a)
	atom_b_ = get_node(atom_b)
	
	if not Engine.is_editor_hint():
		if rest_distance_ == 0.0:
			rest_distance_ = atom_a_.position.distance_to(atom_b_.position)

func tick(delta:float) -> void:
	if atom_b_.dynamic == 0.0 and atom_a_.dynamic == 0.0:
		return

	var distance = atom_b_.position.distance_to(atom_a_.position)
	
	var diff = rest_distance_ - distance
	
	var direction = atom_b_.position.direction_to(atom_a_.position)
	
	
	
	var total_mass := atom_a_.mass + atom_b_.mass
	var a_diff = atom_a_.mass / total_mass
	var b_diff = atom_b_.mass / total_mass
	
	var ratio = 0.5
	if atom_a_.friction > 0.0 and atom_a_.friction_scale > 0.0:
		ratio = 0.0
	elif atom_b_.friction > 0.0 and atom_b_.friction_scale > 0.0:
		ratio = 1.0

	atom_a_.position += direction * diff * 0.5 * ratio
	atom_b_.position -= direction * diff * 0.5 * (1.0 - ratio)

	if distance < rest_distance_:
		debug_color_ = Color.RED
	else:
		debug_color_ = Color.GREEN

func _physics_process(delta: float) -> void:
	if atom_a_ and atom_b_:
		DebugDraw.line(self, atom_a_.global_position, atom_b_.global_position, debug_color_)
