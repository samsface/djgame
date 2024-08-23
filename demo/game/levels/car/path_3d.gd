@tool
extends Path3D

@export var texture:Texture
@export var invalidate:bool :
	set(v):
		invalidate = false
		invalidate_()

func invalidate_() -> void:
	var image := Image.create(1024, 1024, false, Image.FORMAT_R8)

	for y in 1024:
		for x in 1024:
			var pixel_point = Vector3(x - 512, 0, y - 512)
			var nearest_point := curve.get_closest_point(pixel_point)
			var distance_to_nearest_point := nearest_point.distance_squared_to(pixel_point)
			var normalized_distance_to_nearest_point = distance_to_nearest_point / 1024.0
			image.set_pixel(x, y, Color.RED * normalized_distance_to_nearest_point)
	
	texture = ImageTexture.create_from_image(image)
