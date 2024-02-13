class_name VerletBody
extends Node3D

@export var gravity := 1.0

var atoms_ := []
var bonds_ := []

func _ready() -> void:
	for child in get_children():
		if child is VerletAtom:
			atoms_.push_back(child)
		elif child is VerletBond:
			bonds_.push_back(child)
	
	#VerletPhysicsServer.push(self)
