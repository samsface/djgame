shader_type spatial;

instance uniform float line_width : hint_range(0.0, 1.0);
instance uniform vec4 color : source_color;
instance uniform vec2 size = vec2(0.1);
instance uniform int fill_line_count : hint_range(0.0, 100);
instance uniform float fill_line_width : hint_range(0.0, 1.0);
instance uniform int fill_line_accent : hint_range(0, 100);
instance uniform float fill_line_accent_width : hint_range(0.0, 1.0);
const vec2 position = vec2(0.5, 0.5);


void fragment()
{
// Calculate the half sizes of the rectangle
 	vec2 fragCoord = vec2(UV.x - position.x, UV.y - position.y);

 // Calculate the half sizes of the rectangle
    vec2 halfSize = size * 0.5;

    // Calculate the distance of the fragment from the center of the rectangle
    vec2 dist = abs(fragCoord) - halfSize;

    // Calculate the maximum distance from the fragment to the rectangle perimeter
    float maxDist = max(dist.x, dist.y);

	float lineWidth = line_width * 0.1;

	// mask of what's in the shape
	float mask = smoothstep(0.0, lineWidth, maxDist - lineWidth);
	mask = 1.0 - clamp(mask, 0.0, 1.0);

	// draw outline
    float alpha = smoothstep(-lineWidth, 0.0, maxDist) - smoothstep(0.0, lineWidth, maxDist - lineWidth);

	float line = 0.0;;

	// 0.4 = *10
	// draw line
	float line_count = float(fill_line_count);

	vec2 uv_scaled = (UV + position) / size;

	float segment = uv_scaled.y / (1.0/(line_count));
	float position_in_segment = fract(segment);

	float is_accent_enabled = float(clamp(fill_line_accent, 0, 1));
	float is_accent = float(int(segment-1.0) % fill_line_accent == 0 ? 1 : 0);
	float fill_line_thickness = mix(fill_line_width, fill_line_accent_width, is_accent);
	fill_line_thickness = fill_line_thickness * 0.1;
	// fixes the line thickness for count of lines and height
	fill_line_thickness *= line_count / size.y;

	// get distance from center of segment
	float half_thickness = fill_line_thickness * 0.5;
	float distance_from_segment_center = abs(0.5 - position_in_segment) <= half_thickness ? 1.0 : 0.0;
	float is_not_fill_line = distance_from_segment_center <= half_thickness ? 0.0 : 1.0;

	alpha = max(is_not_fill_line * mask, alpha);

	ALBEDO = color.rgb;
	ALPHA_SCISSOR_THRESHOLD = 1.0;
	ALPHA = alpha;
	ROUGHNESS = 0.0;
	SPECULAR = 1.0;
	METALLIC = 0.0;
}
