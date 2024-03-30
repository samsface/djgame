shader_type spatial;
render_mode unshaded;

varying vec3 n;

void vertex() {
	n = NORMAL;
}

void fragment() {
	//ALBEDO = UV
	
	
	ALBEDO = n;
}

