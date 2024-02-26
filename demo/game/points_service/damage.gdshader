shader_type canvas_item;

uniform float damage : hint_range(0.0, 1.0) = 0.0;

void fragment() 
{
	float dc = pow(distance(UV, vec2(0.5, 0.5)), 4.0);

	COLOR = vec4(1.0, 0.0, 0.0, 0.0);
	COLOR.a = damage * dc;
}
