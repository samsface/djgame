shader_type spatial;

uniform float ttl : hint_range(0.0, 1.0) = 0.0;

float customHash(float a, float b, float c) {
    // Normalize the values to the range [0, 1]
    a = mod(a, 1.0f);
    b = mod(b, 1.0f);
    c = mod(c, 1.0f);

    // Combine the values
    float result = a * 0.33f + b * 0.33f + c * 0.33f;

    // Ensure the result is in the range [0, 1]
    result = mod(result, 1.0f);

    return result * 2.0 - 1.0;
}

void vertex() {
	
	VERTEX += ttl * NORMAL;
}

void fragment() {
	// Called for every pixel the material is visible on.
}
