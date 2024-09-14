shader_type spatial;

instance uniform float freq;
instance uniform float amp;
instance uniform float tail_length2;

varying float yy;

void vertex()
{
	// uvs of godot primitives are strange
	float y = mod(UV.y * 2.0, 1.0);
	yy = y;
	
	y *= PI;

	float form = sin((y + tail_length2) * freq);
	form = form * 0.5 + 0.5;
	form = round(form);
	form -= 0.5;

	VERTEX.x += form * amp;

	
}


void fragment() {
	ALBEDO = vec3(0.0, 1.0, 0.0);
	EMISSION = ALBEDO * 2.0;
	
	if(yy < (1.0 - tail_length2))
	{
		discard;
	}

}
