shader_type spatial;
render_mode blend_mul;

uniform vec2 upper_left_;
uniform vec2 width_height_;
uniform float corner_radius_ : hint_range(0.0, 1.0);
uniform sampler2D noise_texture;

float roundedBoxSDF(vec2 center, vec2 size, float radius) 
{
    return length(max(abs(center) - size + radius, 0.0)) - radius;
}

void fragment() 
{
	float edgeSoftness = 0.0f;
	
	vec2 uv = UV;
	// center the shape
	uv.x += width_height_.x * 0.5;
	uv.y -= width_height_.y * 0.5;
	
	// make the dirt wobbley
	uv.x += ((texture(noise_texture, UV).r * 2.0) - 1.0) * 0.002;

    vec2 lower_left = vec2(upper_left_.x, upper_left_.y - width_height_.y);
    float dis = roundedBoxSDF(uv.xy - lower_left - (width_height_ / 2.0f), width_height_ / 2.0f, corner_radius_);
    float smoothedAlpha = 1.0f - smoothstep(0.0f, edgeSoftness * 2.0f, dis);
    vec4 color = mix(vec4(1.0, 0.5, 0.7, 1.0), vec4(0.0, 0.0, 0.0, smoothedAlpha), smoothedAlpha);

	ALPHA_SCISSOR_THRESHOLD = 1.0;
    ALPHA = 1.0 - color.r;
	ALBEDO = vec3(0.8);
}
