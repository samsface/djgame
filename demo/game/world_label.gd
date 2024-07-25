@tool
extends MeshInstance3D

@export var text:String :
	set(v):
		text = v
		mesh.text = text 
