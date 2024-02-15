shader_type spatial;

uniform sampler2D albedo : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = vec3(0.0);
	ROUGHNESS = 0.0;
	METALLIC = 0.5;
	
	vec2 uv = UV;
	
	vec3 c = texture(albedo, uv).rgb;
	ALBEDO = c;

}
