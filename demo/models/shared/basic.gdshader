shader_type spatial;

uniform sampler2D tex : source_color, repeat_disable;
uniform sampler2D map : source_color;
uniform sampler2D smudges : source_color;
uniform vec3 color : source_color;

void fragment() 
{
	float b = texture(tex, UV2).g;
	b = round(b);

	vec3 alb = color;
	alb = mix(vec3(b), alb, b);

	vec2 uv = UV;

	vec3 vec = texture(map, uv).rgb;
	
	float r = texture(smudges, UV * 2.0).r;
	
	
	//alb -= min(0.2, pow(vec.g, 1.0));
	
	alb = mix(alb, vec3(1.0), round(pow(vec.g, 0.5)));
	
	
	alb = mix(alb, vec3(r), r);
	
	
	ALBEDO.rgb = alb;
	METALLIC = 0.5;
	ROUGHNESS = 0.6;
	SPECULAR = 0.5;

}
