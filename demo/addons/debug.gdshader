shader_type spatial;

uniform sampler2D height_map;

void vertex()
{
	VERTEX.y += texture(height_map, UV).r;
}

void fragment()
{
	ALBEDO.rgb = vec3(0.0);
	ALBEDO.r = texture(height_map, UV).r;
}
