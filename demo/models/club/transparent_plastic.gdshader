shader_type spatial;


uniform sampler2D texture_aoe : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//ALPHA = 0.99;
	vec4 screen_tex = texture(SCREEN_TEXTURE, SCREEN_UV, 1);

	ALBEDO = mix(vec3(1.0), screen_tex.rgb, 0.0);

	AO = pow(texture(texture_aoe, UV).r, 1.0);
	AO_LIGHT_AFFECT = 1.0;

	ROUGHNESS = 0.5;
	METALLIC = 0.0;
	ALPHA = 0.8;
}
