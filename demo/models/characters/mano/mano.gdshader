shader_type spatial;
render_mode unshaded;

uniform float scale = 1.0;
uniform float noise_scale = 1.0;
uniform sampler2D crayon_offset_texture;
uniform sampler2D texture_face;

uniform float fps = 4.0;

void fragment()
{
    float time_round = round(TIME * fps) / fps;
    vec4 crayon_offset = texture(crayon_offset_texture, UV / 30. * noise_scale + vec2(time_round * 1.1, time_round * .9));
    
    float zoom = 1.;
    vec2 uv = UV;
    uv.x += (crayon_offset.x - .5) * .01 * scale;
    uv.y += (crayon_offset.y - .5) * .01 * scale;
    
	vec4 color = texture(texture_face, uv);
	
    ALBEDO = color.rgb;
	ALPHA = color.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}