extends Node3D

signal points_changed

@export var points:int :
	set(value):
		points = value
		points_changed.emit(points)
