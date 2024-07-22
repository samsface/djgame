shader_type spatial;

uniform float edge_thickness : hint_range(0.0, 0.1) = 0.01;
uniform float smoothness : hint_range(0.0, 0.1) = 0.005;
instance uniform vec4 border_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	float c = 1.0;

    vec2 uv = UV;

    // Create the edges of the rectangle
    float left = smoothstep(edge_thickness, edge_thickness + smoothness, uv.x);
    float right = smoothstep(c - edge_thickness, c - edge_thickness - smoothness, uv.x);
    float bottom = smoothstep(edge_thickness, edge_thickness + smoothness, uv.y);
    float top = smoothstep(c - edge_thickness, c - edge_thickness - smoothness, uv.y);

    // Combine edges to create a border
    float border = left * right * bottom * top;

    // Output color
    ALBEDO = mix(vec3(0.0), border_color.rgb, 1.0 - border);
	ALPHA = 1.0 - border;
	ALPHA *= border_color.a;

}