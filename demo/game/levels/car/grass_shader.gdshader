shader_type particles;

uniform float rows = 4.0;
uniform float spacing = 1.0;

uniform sampler2D height_map : repeat_disable;
uniform float height_map_amplitude = 1.0;
uniform vec2 height_map_size = vec2(1024, 1024);
uniform sampler2D texture_noise;
uniform sampler2D texture_height;
uniform vec2 texture_height_size = vec2(1024, 1024);
uniform float texture_height_amplitude = 1.0;

float get_density(vec2 pos)
{
	pos /= height_map_size;
	pos += 0.5;

	return height_map_amplitude * texture(height_map, pos).r;
}

float get_height(vec2 pos)
{
	pos /= texture_height_size;
	pos += 0.5;

	return texture_height_amplitude * texture(texture_height, pos).r;
}

vec2 get_noise(vec2 pos)
{
	pos -= 0.5 * height_map_size;
	pos /= height_map_size;

	return (height_map_amplitude * texture(texture_noise, pos).rg - vec2(0.5, 0.5)) * 2.0;
}

uint smart_index(uint index)
{
	return index;
}


vec3 get_position(uint index, mat4 emission_transform)
{
	vec3 pos = vec3(0.0);
	pos.z = float(index);
	pos.x = mod(pos.z, rows);
	pos.z = (pos.z - pos.x) / rows;

	pos.x -= rows * 0.5;
	pos.z -= rows * 0.5;

	pos *= spacing;

	pos.x += emission_transform[3][0] - mod(emission_transform[3][0], spacing);
	pos.z += emission_transform[3][2] - mod(emission_transform[3][2], spacing);

	pos.xz += get_noise(vec2(pos.x, pos.z)) * 5.0;


	return pos;
}

void start()
{
	vec3 pos = get_position(INDEX, EMISSION_TRANSFORM);

	float distance_to_road = get_density(vec2(pos.x, pos.z));


	if(distance_to_road <= 0.35)
	{
		pos.y = -1000.0;
	}
	else
	{
		float height = get_height(vec2(pos.x, pos.z));
		height *= pow(distance_to_road, 6.0);
		pos.y += height;
	}

	TRANSFORM[3][0] = pos.x;
	TRANSFORM[3][1] = pos.y;
	TRANSFORM[3][2] = pos.z;
}

/*
void process()
{
	vec3 pos = get_position(INDEX, EMISSION_TRANSFORM);

	float scale = max(0.0001, get_density(vec2(pos.x, pos.z)));

	TRANSFORM[0].xyz = normalize(TRANSFORM[0].xyz);
	TRANSFORM[1].xyz = normalize(TRANSFORM[1].xyz);
	TRANSFORM[2].xyz = normalize(TRANSFORM[2].xyz);
	TRANSFORM[0].xyz *= sign(scale) * max(abs(scale), 0.0001);
	TRANSFORM[1].xyz *= sign(scale) * max(abs(scale), 0.0001);
	TRANSFORM[2].xyz *= sign(scale) * max(abs(scale), 0.0001);

}
*/