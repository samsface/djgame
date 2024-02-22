@tool
extends Node3D

@export var size := 256
@export var resolution:float = 0.001 
@export var data := PackedFloat32Array()
@export var texture:ImageTexture
@export var reset:bool :
	set(value):
		scan_()

@onready var ray_cast_ := $RayCast3D

func smooth_array(input_array: PackedFloat32Array) -> Array:
	var smoothed_array = input_array.duplicate()

	for y in range(size):
		for x in range(size):
			var max = 0

			# Iterate over the neighboring cells
			for dy in [-1, 0, 1]:
				for dx in [-1, 0, 1]:
					var nx = x + dx
					var ny = y + dy

					if nx >= 0 and nx < size and ny >= 0 and ny < size:
						if input_array[ny * size + nx] > max:
							max = input_array[ny * size + nx]

			var current_cell_value = input_array[y * size + x]

			if current_cell_value < max:
				smoothed_array[y * size + x] = max * 0.99
			else:
				smoothed_array[y * size + x] = current_cell_value

	return smoothed_array

func scan_() -> void:
	data.clear()
	data.resize(size * size)
 
	for y in size:
		for x in size:
			ray_cast_.force_raycast_update()
			
			if ray_cast_.is_colliding():
				var point = ray_cast_.get_collision_point()
	
				data[y * size + x] = point.y + 0.01
			else:
				data[y * size + x] = 0

			ray_cast_.position.x = x * resolution
			ray_cast_.position.z = y * resolution

	for i in 10:
		data = smooth_array(data)
	
	var image := Image.create(size, size, false, Image.FORMAT_R8)
	
	for i in data.size():
		image.set_pixel(i % size, floor(i / size), Color.RED * data[i])

	texture = ImageTexture.create_from_image(image)
