shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_toon, specular_toon;

uniform vec3 albedo : source_color;
uniform sampler2D fresnel_gradient;
uniform sampler2D color_gradient;
uniform sampler2D screen_texture : hint_screen_texture;
uniform float energy;

varying vec3 v;

float fresnsel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment()
{


	float basic_fresnel = fresnsel(4.0, NORMAL, VIEW);
	ALBEDO = albedo.rgb + (basic_fresnel * texture(fresnel_gradient, vec2(basic_fresnel, 0.0)).rgb * 1.0);


	if(v.y < 0.2) discard;


	if(!FRONT_FACING) {
	//	ALBEDO = vec3(1.0, 0.2, 1.0);
	}
}

void light()
{
	vec3 normal = NORMAL;
	normal.y += sin(TIME * 10.0) * 0.2 * cos(v.y * 10.0) * energy;

	float dotproduct = clamp(dot(normal, LIGHT), -0.9, 0.9);
	float sample = clamp((dotproduct + 1.0) * ATTENUATION / 2.1, 0.05, 0.95);
	vec4 shaded = texture(color_gradient, vec2(sample, 0.0));
	DIFFUSE_LIGHT += clamp(shaded.rgb * LIGHT_COLOR, 0.0, 1.0);
}

void vertex()
{
	VERTEX -= NORMAL * 0.1;

	v = VERTEX;
}

