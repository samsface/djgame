shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_toon, specular_toon;

uniform vec3 albedo : source_color;
uniform vec3 albedo_surface : source_color;
uniform sampler2D fresnel_gradient;
uniform sampler2D color_gradient;
uniform sampler2D screen_texture : hint_screen_texture;
uniform float energy;
uniform float fill : hint_range(0.0, 1.0) = 0.0;
uniform float size;

varying vec3 v;
varying float b;

float fresnsel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}


void vertex()
{
	VERTEX -= NORMAL * 0.1;

	v = VERTEX;
}


void fragment()
{
	float factor = 1.0 - ((v.y / size) + 0.5);
	float fill_factor = factor - fill;


	float basic_fresnel = fresnsel(4.0, NORMAL, VIEW);
	ALBEDO = albedo.rgb + (basic_fresnel * texture(fresnel_gradient, vec2(basic_fresnel, 0.0)).rgb * 1.0);



	float s = smoothstep(factor + 0.1, factor, fill);
	ALBEDO = mix(ALBEDO, albedo_surface.rgb, s);
	if(!FRONT_FACING) {
		ALBEDO = albedo_surface;
		NORMAL = vec3(1.0, 0.0, 0.0);
	}

	if(factor > fill) discard;

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
