shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform sampler2D tex : source_color, repeat_disable;
uniform sampler2D map : source_color;
instance uniform float emission_scale : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D emission_map : source_color;
uniform float smudge_scale : hint_range(0.0, 10.0);
uniform sampler2D smudges : source_color;
uniform vec3 color : source_color;
uniform vec3 color2 : source_color;
uniform bool debug_uv1 = false;
uniform bool debug_uv2 = false;
uniform float ambient_occlusion : hint_range(0.0, 10.0, 0.0) = 1.0;
uniform sampler2D DEPTH_TEXTURE : source_color, hint_depth_texture;

instance uniform float rand : hint_range(0.0, 1.0);
instance uniform float highlight = 0.0;

uniform float metalic : hint_range(0.0, 10.0, 0.0) = 0.5;

uniform vec4 edge_color : source_color;

void fragment() 
{
	float b = texture(tex, UV2).g;
	b = round(b);

	vec3 alb =  mix(color, color2, UV2.x);

	alb = mix(vec3(b), alb, b);

	vec2 uv = UV;

	vec3 vec = texture(map, uv).rgb;
	
	float r = texture(smudges, UV * smudge_scale + rand).r;

	if(edge_color.a >= 1.0)
	{
		alb = mix(alb, edge_color.rgb, round(pow(vec.g, 0.5)));
	}
	else 
	{
		alb = mix(alb, alb * edge_color.a, round(pow(vec.g, 0.5)));
	}
	
	alb = mix(alb, vec3(r), r);


	// ambient oc
	alb.rgb *= pow(vec.r, ambient_occlusion);
	//
	
	ALBEDO.rgb = alb;
	METALLIC = metalic;
	ROUGHNESS = 0.6;
	SPECULAR = 0.5;

	// emission
	vec3 t = texture(emission_map, UV2).rgb;
	t = round(t);
	
	vec3 lt = vec3(0);

	EMISSION = t * 1000.0 * pow(emission_scale, 8.0);
	ALBEDO = mix(ALBEDO, EMISSION, length(EMISSION));
	//

	if(debug_uv1) 
	{
		ALBEDO.r = UV.x;
		ALBEDO.g = UV.y;
		ALBEDO.b = 0.0;
	}
	
	if(debug_uv2) 
	{
		ALBEDO.r = UV2.x;
		ALBEDO.g = UV2.y;
		ALBEDO.b = 0.0;
	}
}
