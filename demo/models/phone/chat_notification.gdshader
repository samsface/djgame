shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	COLOR = mix(vec4(0.0, 0.0, 0.0, 0.0), texture(screen_texture, SCREEN_UV, 5), 0.5);
//	COLOR.r = 0.0;
}
