shader_type spatial;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void fragment() 
{
	ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV, 3).rgb;
	METALLIC = 0.5;
	ROUGHNESS = 0.5;
}
