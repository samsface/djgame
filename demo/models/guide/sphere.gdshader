shader_type spatial;


instance uniform float danger : hint_range(0.0, 1.0) = 0.0;
instance uniform float bang : hint_range(0.0, 1.0) = 0.0;
instance uniform float ttl : hint_range(0.0, 1.0) = 0.0;
instance uniform vec3 albedo : source_color;

void vertex() 
{
	VERTEX += pow(ttl, 2.0) * NORMAL * (UV.x + UV.y) * 3.0;
}

void fragment() 
{
	ALPHA = 1.0;
	ALPHA = 1.0 - pow(ttl, 2.0);
	ALPHA = clamp(ALPHA, 0.0, 1.0);
	ALBEDO = albedo;
	METALLIC = 0.0;
	ROUGHNESS = 0.5;
}
	