shader_type spatial;
render_mode cull_front, unshaded;

uniform sampler2D curve;
uniform float squash_bottom : hint_range(0.0, 1.0);
uniform float squash_top : hint_range(0.0, 1.0);

void vertex() 
{
	VERTEX.y += 0.5;
	
	VERTEX.xz *= texture(curve, vec2(VERTEX.y, 0.0)).r;

	if(VERTEX.y <= 0.04) 
	{
		VERTEX.y = squash_bottom;
	}
	
	if(VERTEX.y >= 0.95) 
	{
		VERTEX.y = squash_top;
	}

	VERTEX.y *= 0.7;
	
	VERTEX *= 1.05;
	VERTEX.y -= 0.015;
}

void fragment()
{
	ALBEDO.rgb = vec3(0.0);
}