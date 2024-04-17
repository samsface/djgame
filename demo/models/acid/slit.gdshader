shader_type spatial;
render_mode unshaded;

varying vec3 nomral;

instance uniform float size;
instance uniform float position;

void vertex() {
	nomral = NORMAL;
	
	VERTEX.y *= size;
	VERTEX.xz *= 1.001;
	
	VERTEX.y -= position;
	
}

void fragment() {
	ALBEDO = vec3(0.0);
}
