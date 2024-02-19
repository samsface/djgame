shader_type spatial;

uniform sampler2D curve;
uniform float squash_bottom : hint_range(0.0, 1.0);
uniform float squash_top : hint_range(0.0, 1.0);
uniform float eye_gap : hint_range(0.0, 1.0);
uniform float eye_size : hint_range(0.0, 1.0);
uniform float eye_width : hint_range(0.0, 1.0);
uniform float eye_white_size : hint_range(0.0, 1.0);
uniform vec3 albedo : source_color;

// Define the draw_oval "function"
float draw_oval(vec2 frag_coord, vec2 center, vec2 radii) {
    // Calculate the distance from the center
    vec2 distance = abs(frag_coord - center);

    // Normalize the distance to get values between 0 and 1
    vec2 normalized_distance = distance / radii;

    // Calculate the length of the normalized distance vector
    float length_normalized = length(normalized_distance);

    // Define the smoothness of the oval edges
    float smoothness = 0.01;

    // Use smoothstep to create a smooth transition at the oval edges
    return smoothstep(1.0 - smoothness, 1.0 + smoothness, length_normalized);
}

void vertex() {
	VERTEX.y += 0.5;
	
	VERTEX.xz *= texture(curve, vec2(VERTEX.y, 0.0)).r;
	
	
	if(VERTEX.y <= 0.04) 
	{
		VERTEX.y = squash_bottom;
	}
	
	if(VERTEX.y >= 0.95) 
	{
		VERTEX.y = squash_top;
	}
	
	VERTEX.y *= 0.7;
}

void fragment()
{
	vec2 uv = UV;

	vec2 left_eye_pos = vec2(0.5 - eye_gap * 0.15, 0.5);
	vec2 right_eye_pos = vec2(0.5 + eye_gap * 0.15, 0.5);
	
	
	vec2 eye_size2 = vec2(0.01 + eye_width, 0.1) * eye_size;
	vec2 eye_white_size2 = eye_size2 * eye_white_size;

	float left_eye         = draw_oval(uv, left_eye_pos,  eye_size2);
	float left_eye_whites  = draw_oval(uv, left_eye_pos,  eye_white_size2);
	float right_eye        = draw_oval(uv, right_eye_pos, eye_size2);
	float right_eye_whites = draw_oval(uv, right_eye_pos, eye_white_size2);

	float eye = clamp(left_eye + right_eye, 0.0, 1.0);

	METALLIC = 0.1;
	ROUGHNESS = 0.5;

	ALBEDO.rgb = albedo;
	ALBEDO.rgb = mix(vec3(0.0), ALBEDO.rgb, left_eye);
	ALBEDO.rgb = mix(vec3(1.0), ALBEDO.rgb, left_eye_whites);
	ALBEDO.rgb = mix(vec3(0.0), ALBEDO.rgb, right_eye);
	ALBEDO.rgb = mix(vec3(1.0), ALBEDO.rgb, right_eye_whites);
	
	ROUGHNESS = mix(0.0, ROUGHNESS, eye);
	METALLIC = mix(1.0, METALLIC, eye);
}

