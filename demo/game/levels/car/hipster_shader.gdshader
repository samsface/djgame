shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D screen : hint_screen_texture;

void fragment() {
	float dist = distance(UV, vec2(0.5));
	vec2 off = vec2(0.001, 0) * (0.5 + dist) * 0.5;
	vec3 left = texture(screen, SCREEN_UV - off).rgb;
	vec3 right = texture(screen, SCREEN_UV + off).rgb;
	COLOR.rgb = (left * vec3(1, 0.5, 0) + right * vec3(0, 0.5, 1)) * clamp(1.5 - dist, 0, 1);
}