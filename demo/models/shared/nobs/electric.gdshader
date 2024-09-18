shader_type spatial;
render_mode unshaded;

instance uniform float pad0;
instance uniform float rand : hint_range(0.0, 1.0);
instance uniform float pad2;
instance uniform vec4 electric_albedo : source_color;
uniform float outline_width = 1.0;
uniform sampler2D noise;
uniform sampler2D noise2;

varying float y;

void vertex()
{
	vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 clip_normal = mat3(PROJECTION_MATRIX) * (mat3(MODELVIEW_MATRIX) * NORMAL);

	vec2 offset = normalize(clip_normal.xy) / VIEWPORT_SIZE * clip_position.w * outline_width * 2.0;

	clip_position.xy += offset;

	POSITION = clip_position;

	y = VERTEX.y;
}

void fragment()
{
	float b = texture(noise2, SCREEN_UV + vec2(TIME, TIME) * 0.3).r;


	vec2 uv = SCREEN_UV * 0.5;
	uv += rand;

	ALBEDO = electric_albedo.rgb * 55.0 * electric_albedo.a;
	EMISSION = ALBEDO * 55.0 * electric_albedo.a;

	float aa = texture(noise, uv).r - b;
	float a = round(texture(noise, uv).r - b);

	float x = a;
	x = mix(x, 1.0, pow(electric_albedo.a, 128.0));


	ALPHA = clamp(x, 0.0, 1.0) * electric_albedo.a;

	if(y < 0.0015 + aa * 0.001)
	{
		ALPHA = 1.0 * electric_albedo.a;
	}
}