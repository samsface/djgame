shader_type spatial;
render_mode cull_front, unshaded;

instance uniform float ttl2 : hint_range(0.0, 1.0) = 0.0;

void vertex() 
{
	VERTEX *= 1.1;
}

void fragment()
{
	ALPHA = floor(1.0 - ttl2);
	ALBEDO = vec3(0.0);
}