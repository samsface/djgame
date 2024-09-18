shader_type spatial;
render_mode cull_disabled;

instance uniform float freq;
instance uniform float amp;
instance uniform float tail_length;

varying float yy;

void vertex()
{
	// uvs of godot primitives are strange
	float y = mod(UV.y * 2.0, 1.0);
	yy = y;
	
	y *= PI;

	float form = sin((y + tail_length) * freq);
	form = form * 0.5 + 0.5;
	form = round(form);
	form -= 0.5;
	
	float factor = clamp((1.0 - yy) / tail_length, 0.0, 1.0);
	factor = pow(factor, 0.5);

 	float a = amp;
	float per = sin((tail_length - yy) * 8.0);
	per = sign(per) * max(0.5, abs(per));
	
	//a *= per;

	VERTEX.x += form * a * (1.0 - factor);

	
}


void fragment() {
	ALBEDO = vec3(0.0, 1.0, 0.0);
	EMISSION = ALBEDO * 2.0;
	
	if(yy < (1.0 - tail_length))
	{
		discard;
	}

}
