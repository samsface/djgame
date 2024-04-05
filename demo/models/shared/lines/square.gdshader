shader_type spatial;

instance uniform float line_width : hint_range(0.0, 1.0);
uniform vec4 outline_color;
instance uniform vec2 size = vec2(0.1);
instance uniform float fill_line_spacing : hint_range(0.0, 1.0);
instance uniform float fill_line_width : hint_range(0.0, 1.0);
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
	
	
	// 0.4 = *10
	// draw line
    float y = fract(UV.y / fill_line_spacing);
	lineWidth = fill_line_width;
	float line = step(lineWidth, y) - step(1.0 - lineWidth, y);
	

	alpha = max(line * mask, alpha);
	
	ALBEDO = vec3(0.0);
	ALPHA_SCISSOR_THRESHOLD = 1.0;
	ALPHA = alpha;
}
