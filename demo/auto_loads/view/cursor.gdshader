shader_type spatial;
render_mode depth_test_disabled;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	DEPTH = 0.0;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
