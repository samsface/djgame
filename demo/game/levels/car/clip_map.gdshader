shader_type spatial;
render_mode unshaded;

uniform sampler2D texture_height : repeat_enable;
uniform float texture_height_amplitude;
uniform sampler2D texture_road_distance : repeat_enable;

uniform sampler2D test : repeat_enable;

uniform float x = 0.0;

varying vec2 uvv;

void vertex()
{
	vec2 uv = UV;

	uv += NODE_POSITION_WORLD.xz * (1024.0 / 181.0) * 0.001;



	//uv *= x * 0.001;

	uv -= 0.5;

	uv *= (181.0 / 1024.0);

	uv += 0.5;

	uvv = uv;

	float distance_to_road = texture(texture_road_distance, uv).r;
	//distance_to_road = 1.0;

	float height = texture(texture_height, uv).r;
	height *= texture_height_amplitude;
	height *= pow(distance_to_road, 6.0);

	VERTEX.y += height;


}

void fragment()
{
	//ALBEDO.rgb = round(texture(texture_height, uvv).rgb);
	ALBEDO.rgb = texture(test, UV).rgb;
}