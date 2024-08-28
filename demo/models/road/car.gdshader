// NOTE: Shader automatically converted from Godot Engine 4.3.dev5's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec3 albedo : source_color = vec3(0.0);
uniform sampler2D texture_albedo : source_color, hint_default_transparent;
uniform vec3 wear_albedo : source_color = vec3(0.0);
uniform sampler2D aoe_texture : filter_linear_mipmap, repeat_enable;

uniform float roughness : hint_range(0.0, 1.0) = 0.0;
uniform float specular : hint_range(0.0, 1.0);
uniform float metallic : hint_range(0.0, 1.0);
uniform float ao_light_affect : hint_range(0.0, 1.0, 0.01);

uniform vec2 detail_scale = vec2(1.0);
uniform sampler2D texture_detail : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform float wear : hint_range(0.0, 1.0);


void fragment()
{
	vec2 base_uv = UV;

	vec4 aoe_tex = texture(aoe_texture, base_uv);
	vec4 detail_tex = texture(texture_detail, base_uv * detail_scale);

	vec4 albedo_color = texture(texture_albedo, UV);

    ALBEDO = albedo;
	ALBEDO = mix(ALBEDO, albedo_color.rgb, albedo_color.a);



	float e = aoe_tex.g;
	e = round(e - wear * 0.5);

	ALBEDO = mix(ALBEDO, wear_albedo.rgb, e);
	ALBEDO = mix(ALBEDO, wear_albedo.rgb, round(detail_tex.r - 0.04));



	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;

	AO = pow(aoe_tex.r, 1.0);
	AO_LIGHT_AFFECT = ao_light_affect;
}
