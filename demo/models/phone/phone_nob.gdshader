shader_type spatial;
render_mode unshaded;

instance uniform float rand : hint_range(0.0, 1.0);
instance uniform vec4 electric_albedo : source_color;
uniform float outline_width = 1.0;
uniform sampler2D noise;
uniform sampler2D noise2;

void fragment() 
{
	float b = texture(noise2, UV + vec2(TIME, TIME) * 0.1).r;
	float a = texture(noise, UV + vec2(b, b) * 0.1).r;

    float distToEdge = min(min(abs(1.0 - abs(UV.x * 2.0 - 1.0)), abs(UV.y * 2.0)), min(abs(1.0 - abs(UV.y * 2.0 - 1.0)), abs(UV.x * 2.0)));
    float edgeSmooth = smoothstep(0.2, 0.0, distToEdge);
	edgeSmooth = round(edgeSmooth);
	
	ALBEDO = electric_albedo.rgb * 55.0 * electric_albedo.a;
	EMISSION = electric_albedo.rgb;

	ALPHA = clamp(a, 0.0, 1.0) * electric_albedo.a;
	ALPHA = round(ALPHA);
	
	ALPHA *= edgeSmooth;
}