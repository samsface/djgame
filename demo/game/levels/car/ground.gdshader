shader_type spatial;

uniform sampler2D texture_height;
uniform float texture_height_amplitude;
uniform sampler2D texture_road_distance;
uniform vec3 albedo : source_color;
uniform sampler2D test;
void vertex()
{

	float distance_to_road = texture(texture_road_distance, UV).r;
	distance_to_road = 1.0;

	float height = texture(texture_height, UV).r;
	height *= texture_height_amplitude;
	height *= pow(distance_to_road, 6.0);

	VERTEX.y += height;
}

void fragment()
{
	ALBEDO = round(texture(texture_height, UV).rgb);
	//ALBEDO.r = texture(texture_road_distance, UV).r;

}
