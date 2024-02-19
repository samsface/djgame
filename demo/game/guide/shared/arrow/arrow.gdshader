shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform vec3 albedo : source_color;
instance uniform float ttl : hint_range(0.0, 1.0);
instance uniform float scale : hint_range(0.0, 1.0);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void vertex() 
{
	VERTEX += pow(ttl, 2.0) * NORMAL * (UV.x + UV.y) * (scale * 3.0 + 0.5);
}

void fragment() 
{
	ALBEDO = albedo;
	EMISSION = albedo * 2.0;
	ALPHA = clamp(1.0 - ttl * 1.0, 0.0, 1.0);
}
