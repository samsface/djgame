shader_type spatial;
render_mode cull_disabled;

uniform vec3 color : source_color;
uniform vec3 color2 : source_color;
uniform sampler2D noise;
uniform float noise_scale;

uniform vec3 player_pos;
uniform float radius;
uniform float interact_power : hint_range(0.0, 10.0);
uniform bool debug;

uniform sampler2D memory;

varying vec3 world_position;
varying vec4 memory_;

uniform sampler2D wind_noise;




uniform vec4 color_top:source_color = vec4(1,1,1,1);
uniform vec4 color_bottom:source_color = vec4(0,0,0,1);

uniform float deg_sway_pitch = 80.0;
uniform float deg_sway_yaw = 45.0;

uniform float wind_scale = 4.0;
uniform float wind_speed = 1.0;

varying float wind;

const vec3 UP = vec3(0,1,0);
const vec3 RIGHT = vec3(1,0,0);

//const float PI = 3.14159;
const float DEG2RAD = (PI / 180.0);

uniform vec3 wind_direction = vec3(0,0,-1);

mat3 mat3_from_axis_angle(float angle, vec3 axis) {
	float s = sin(angle);
	float c = cos(angle);
	float t = 1.0 - c;
	float x = axis.x;
	float y = axis.y;
	float z = axis.z;
	return mat3(
		vec3(t*x*x+c,t*x*y-s*z,t*x*z+s*y),
		vec3(t*x*y+s*z,t*y*y+c,t*y*z-s*x),
		vec3(t*x*z-s*y,t*y*z+s*z,t*z*z+c)
	);
}


vec2 random2(vec2 p) {
	return fract(sin(vec2(
		dot(p, vec2(127.32, 231.4)),
		dot(p, vec2(12.3, 146.3))
	)) * 231.23);
}


float worley2(vec2 p) {
	float dist = 1.0;
	vec2 i_p = floor(p);
	vec2 f_p = fract(p);
	for(int y=-1;y<=1;y++) {
		for(int x=-1;x<=1;x++) {
			vec2 n = vec2(float(x), float(y));
			vec2 diff = n + random2(i_p + n) - f_p;
			dist = min(dist, length(diff));
		}
	}
	return dist;
}


void vertex()
{


	vec3 world_vert = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; // model space to world space




	memory_ = texture(memory, world_vert.xz / 40.0);

	vec3 direction = world_vert - player_pos;
	direction.y = 0.0;
	direction = normalize(direction);
	float dist = distance(player_pos, world_vert);
	float power = smoothstep(radius, 0.0, dist);
	direction = (vec4(direction, 1.0) * MODEL_MATRIX).xyz; // world space direction to model space

	if(length(memory_) > 0.0)
	{
		VERTEX += vec3(0.0, -1.0, 0.0) * interact_power * (1.0 - UV.y);
	}
	else
	{
		VERTEX += direction * power * interact_power * (1.0 - UV.y);
	}



	NORMAL = UP;
	vec3 vertex = VERTEX;
	vec3 wind_direction_normalized = normalize(wind_direction);
	float time = TIME * wind_speed;
	vec2 uv = (MODEL_MATRIX * vec4(vertex,-1.0)).xz * wind_scale;
	uv += wind_direction_normalized.xz * time;
	wind = pow(worley2(uv),2.0) * (1.0 - UV.y);

	mat3 to_model = inverse(mat3(MODEL_MATRIX));
	vec3 wind_forward = to_model * wind_direction_normalized;
	vec3 wind_right = normalize(cross(wind_forward, UP));

	float sway_pitch = ((deg_sway_pitch * DEG2RAD) * wind);// + INSTANCE_CUSTOM.z;
	float sway_yaw = ((deg_sway_yaw * DEG2RAD) * sin(time) * wind);// + INSTANCE_CUSTOM.w;

	mat3 rot_right = mat3_from_axis_angle(sway_pitch, wind_right);
	mat3 rot_forward = mat3_from_axis_angle(sway_yaw, wind_forward);

	//vertex.xz *= INSTANCE_CUSTOM.x;
	//vertex.y *= INSTANCE_CUSTOM.y;

	VERTEX = rot_right * rot_forward * vertex;

	COLOR = mix(color_bottom, color_top, 1.0 - UV.y);

	VERTEX *= 0.5;
}

void fragment() {
	float side = FRONT_FACING ? 1.0 : -1.0;
	NORMAL = NORMAL * side;
	ALBEDO = COLOR.rgb;
	SPECULAR = 0.5;
	ROUGHNESS = clamp(1.0 - (wind * 1.2), 0.0, 1.0);


	if(debug)
	{
	//	ALBEDO.r = 1.0;
	}

//	ALPHA = round(1.0 - memory_.r);
}
