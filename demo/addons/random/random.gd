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
