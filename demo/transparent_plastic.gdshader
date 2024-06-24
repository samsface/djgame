shader_type spatial;
render_mode cull_disabled;


uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//ALPHA = 0.99;
	vec4 screen_tex = texture(SCREEN_TEXTURE, SCREEN_UV, 5);

	ALBEDO = mix(vec3(1.0), screen_tex.rgb, 0.5);

	ROUGHNESS = 0.5;
	METALLIC = 0.0;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
