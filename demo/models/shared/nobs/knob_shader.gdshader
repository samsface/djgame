// NOTE: Shader automatically converted from Godot Engine 4.3.dev5's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

instance uniform vec3 albedo : source_color = vec3(0.0);
instance uniform vec3 wear_albedo : source_color = vec3(0.0);
uniform sampler2D aoe_texture : filter_linear_mipmap, repeat_enable;

uniform float roughness : hint_range(0.0, 1.0) = 0.0;
uniform float specular : hint_range(0.0, 1.0);
uniform float metallic : hint_range(0.0, 1.0);
uniform float max_y;
uniform float ao_light_affect : hint_range(0.0, 1.0, 0.01);

uniform vec2 detail_scale = vec2(1.0);
uniform sampler2D texture_detail : hint_default_white, filter_linear_mipmap, repeat_enable;
instance uniform float wear : hint_range(0.0, 1.0);

instance uniform vec4 electric_albedo : source_color;
uniform sampler2D electric_noise;

varying float y;

void vertex()
{
	y = VERTEX.y;
}

void fragment()
{
	vec2 base_uv = UV;

	vec4 aoe_tex = texture(aoe_texture, base_uv);
	vec4 detail_tex = texture(texture_detail, base_uv * detail_scale);

	ALBEDO = albedo;

	float e = aoe_tex.g;
	e = round(e - wear * 0.5);

	ALBEDO = mix(ALBEDO, wear_albedo.rgb, e);

	ALBEDO = mix(ALBEDO, wear_albedo.rgb, round(detail_tex.r - 0.04));

	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;

	AO = pow(aoe_tex.r, 1.0);
	AO_LIGHT_AFFECT = ao_light_affect;


	// Electric Effect
	float b = texture(electric_noise, SCREEN_UV + vec2(TIME, 0) * 0.3).r;
	b *= 0.005;

	if((y + b) < electric_albedo.a * max_y)
	{
		ALBEDO = electric_albedo.rgb;
		EMISSION = electric_albedo.rgb;
	}
}
