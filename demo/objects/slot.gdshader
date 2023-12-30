shader_type canvas_item;

uniform bool up = false;
uniform vec3 color : source_color;

void vertex() {
	VERTEX.y += up ? 2.0 : -2.0;
}

void fragment() {
	
	vec2 uv = UV;
	
	if(up) {
		uv.y = 1.0 - uv.y;
	}
	
	uv.y += 0.5;
	
	float a = 1.0 - distance(uv, vec2(0.5, 0.5));
	float b = 0.9 - distance(uv, vec2(0.5, 0.5));

	COLOR.rgb = vec3(1.0, 0.0, 0.0);
	COLOR.a = smoothstep(a, b, 0.6);
	
	float d = 1.0 - distance(uv, vec2(0.5, 0.5));
	float c = 0.9 - distance(uv, vec2(0.5, 0.5));
	
	//COLOR.a *= round(uv.y);
	COLOR.rgb = mix(vec3(0.0, 0.0, 0.0), color, 1.0 - smoothstep(a, b, 0.7));
	
	
}
