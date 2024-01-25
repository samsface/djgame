shader_type spatial;

uniform sampler2D button_top : source_color;
uniform vec3 color : source_color;
instance uniform float light : hint_range(0.0, 1.0);

void fragment() {
	vec3 albedo = color;
	
	vec3 t = texture(button_top, UV2).rgb;
	t = round(t);
	
	vec3 lt = vec3(0);
	
	albedo = mix(albedo, lt, length(t));
	
	EMISSION = t * 255.0 * pow(light, 8.0);

	ALBEDO = albedo;
}
