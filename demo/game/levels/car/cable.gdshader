shader_type spatial;
render_mode unshaded;

instance uniform float total_length = 0.0;

void vertex()
{
	// uvs of godot primitives are strange
	float y = mod(UV.y * 2.0, 1.0);
	y = abs(0.5 - y);

	y *= y;

	float droop = 2.0;

	VERTEX.x += y * droop;
	VERTEX.x -= droop * 0.25;
}

void fragment()
{
	ALBEDO = vec3(0);
}
