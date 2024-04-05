extends Node
class_name HyperRandom

static func fruity_color() -> Color:
	# Generate random values for red, green, and blue components
	var red = randf()
	var green = randf()
	var blue = randf()

	# Boost the brightness of the color
	var brightness_factor = 0.1  # Adjust this value to control brightness
	red = clamp(red + brightness_factor, 0.0, 1.0)
	green = clamp(green + brightness_factor, 0.0, 1.0)
	blue = clamp(blue + brightness_factor, 0.0, 1.0)

	# Create and return the Color
	var fruity_color = Color(red, green, blue)
	return fruity_color

static func random_vector3() -> Vector3:
	# Generate random values for red, green, and blue components
	var red = randf() - 0.5
	var green = randf() - 0.5
	var blue = randf() - 0.5

	return Vector3(red, green, blue)

static func random_vector2() -> Vector2:
	# Generate random values for red, green, and blue components
	var red = randf() - 0.5
	var green = randf() - 0.5

	return Vector2(red, green)

static func call_recursive(node:Node, depth:int, callable:Callable, stack_depth := 0):
	callable.call(node)
	
	if stack_depth >= depth:
		return

	for child in node.get_children():
		call_recursive(child, depth, callable, stack_depth + 1)
		call_recursive(child, depth, callable, stack_depth + 1)
