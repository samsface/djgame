shader_type spatial;

instance uniform vec3 albedo : source_color;
instance uniform float ttl : hint_range(0.0, 1.0);
instance uniform float scale : hint_range(0.0, 1.0);
instance uniform float tail_length;

void vertex()
{
	if(COLOR.g < 0.9)
	{
		VERTEX.y += tail_length;
	}

	VERTEX += pow(ttl, 2.0) * NORMAL * (UV.x + UV.y) * (scale * 3.0 + 0.5);
}

void fragment()
{
	ALBEDO = albedo;
	EMISSION = albedo;
}
