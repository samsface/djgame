extends RefCounted
class_name InspectorPreview

static func generate_icon(property_class_name, value) -> Texture:
	if value is Gradient:
		var g := GradientTexture2D.new()
		g.gradient = value
		g.height = 16
		g.width = 64.0

		return g

	if value is Texture:
		return value
		
	return null
