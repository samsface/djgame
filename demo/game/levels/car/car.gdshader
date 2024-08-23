shader_type spatial;
render_mode unshaded;

uniform sampler2D texture_gradient;

void fragment() {
	vec2 uv = UV;
	uv.y *= 8.0;
	uv.y = mod(uv.y, 1.0);

	ALBEDO = texture(texture_gradient, uv).rgb;
}

