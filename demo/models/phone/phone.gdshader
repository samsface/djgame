shader_type spatial;

uniform sampler2D albedo : source_color, repeat_disable;
uniform sampler2D scuff : source_color;
uniform sampler2D ao : source_color;
uniform sampler2D marc : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = vec3(0.0);
	ROUGHNESS = 0.01;
	METALLIC = 0.5;
	SPECULAR = 0.4;

	
	vec2 uv = UV2;

	
	vec3 c = texture(albedo, uv).rgb;
	ALBEDO = c;
	
	ALBEDO = mix(ALBEDO, texture(marc, SCREEN_UV * 0.4).rgb, 0.004);

	
	float scratches = texture(scuff, UV).r;
	ALBEDO = mix(ALBEDO, vec3(1.0 - scratches), scratches * 0.02);
	
	
	vec2 aoc = texture(ao, UV).rg;
	
	ALBEDO.rgb *= aoc.r;

	ALBEDO = mix(ALBEDO, vec3(0.02), aoc.g);
}
