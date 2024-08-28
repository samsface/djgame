shader_type spatial;

uniform vec3 color_a : source_color;
uniform vec3 color_b : source_color;
uniform sampler2D color_ramp : source_color;
uniform sampler2D texture_t : source_color;


uniform vec4 middle_line_color : source_color;
uniform vec4 side_line_color : source_color;

const float line_widths = 0.007;

uniform sampler2D texture_road;
uniform sampler2D texture_road_edge;
uniform sampler2D texture_detail : filter_linear_mipmap_anisotropic;

vec2 rotate(vec2 v, float angle) {
    // Calculate the sine and cosine of the angle
    float s = sin(angle);
    float c = cos(angle);

    // Apply the rotation matrix
    return vec2(
        c * v.x - s * v.y,
        s * v.x + c * v.y
    );
}

void fragment() {

	vec2 uv = UV;
	uv.y *= 8.0;




	ALBEDO = texture(texture_road, uv).rgb;

	vec4 road_edge_color = texture(texture_road_edge, uv);

	ALBEDO = mix(ALBEDO, road_edge_color.rgb, road_edge_color.a);

	SPECULAR = 0.9;
	ROUGHNESS = 0.1;
	METALLIC = 0.3;

}
