shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform sampler2D ao_map : source_color;
uniform sampler2D scratches : source_color;

void fragment() 
{
	vec3 aoe =texture(ao_map, UV, 0).rgb;
	float ao = aoe.r;
	float edge = aoe.g;
	
	ALBEDO = albedo;
	ALBEDO = mix(ALBEDO, albedo2, UV2.x);
	
	ALBEDO *= pow(ao, 2.0);
	
	//ALBEDO = mix(ALBEDO, vec3(0.1), round(edge));
	
	ALBEDO =  mix(ALBEDO, vec3(0.1), round(texture(scratches, UV * 0.15).rgb));
	
	ROUGHNESS = 0.5;
	METALLIC = 0.5;
}
