shader_type spatial;

uniform sampler2D texture_height;
uniform float texture_height_amplitude;
uniform sampler2D texture_road_distance;
uniform vec3 albedo : source_color;

void vertex() 
{
	
	float distance_to_road = texture(texture_road_distance, UV).r;
		
	float height = texture(texture_height, UV).r;
	height *= texture_height_amplitude;
	height *= pow(distance_to_road, 6.0);
	
	VERTEX.y += height;
}

void fragment()
{
	ALBEDO = albedo;
	//ALBEDO.r = texture(texture_road_distance, UV).r;
	
}

