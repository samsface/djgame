shader_type spatial;
render_mode cull_back;

const int bone_count = 32;
uniform vec3 bones[bone_count];
const vec3 up_vector = vec3(0.0, 1.0, 0.0);

vec3 rotate_vector(vec3 original_vector, vec3 rotation_angles) {
    // Rotation matrix around X-axis
    mat3 rotation_matrix_x = mat3(
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, cos(rotation_angles.x), -sin(rotation_angles.x)),
        vec3(0.0, sin(rotation_angles.x), cos(rotation_angles.x))
    );

    // Rotation matrix around Y-axis
    mat3 rotation_matrix_y = mat3(
        vec3(cos(rotation_angles.y), 0.0, sin(rotation_angles.y)),
        vec3(0.0, 1.0, 0.0),
        vec3(-sin(rotation_angles.y), 0.0, cos(rotation_angles.y))
    );

    // Rotation matrix around Z-axis
    mat3 rotation_matrix_z = mat3(
        vec3(cos(rotation_angles.z), -sin(rotation_angles.z), 0.0),
        vec3(sin(rotation_angles.z), cos(rotation_angles.z), 0.0),
        vec3(0.0, 0.0, 1.0)
    );

    // Apply rotations successively
    vec3 rotated_vector = rotation_matrix_x * original_vector;
    rotated_vector = rotation_matrix_y * rotated_vector;
    rotated_vector = rotation_matrix_z * rotated_vector;

    return rotated_vector;
}

void vertex() 
{
	float f = (VERTEX.y + 0.5) * float(bone_count - 1);
	
	VERTEX.y = 0.0;
	
	int bone_idx = int(floor(f));
	VERTEX += bones[bone_idx];

	
	/*
	float f = (VERTEX.y + 0.5) * float(bone_count - 1);
	
	int bone_1_idx = int(floor(f));
	int bone_2_idx = clamp(bone_1_idx + 1, 0, bone_count);
	int bone_0_idx = clamp(bone_1_idx - 1, 0, bone_count);

	float ratio = fract(f);

	vec3 bone_0 = bones[bone_0_idx];
	vec3 bone_1 = bones[bone_1_idx];
	vec3 bone_2 = bones[bone_2_idx];
	
	vec3 offset = vec3(0);
	offset = bone_1 * (1.0 - ratio);
	offset = bone_2 * ratio;

	//VERTEX.y = 0.0;

	//VERTEX = rotate_vector(VERTEX, vec3(2.3, 0.0, 0.0));

	VERTEX += offset;
	*/
}

void fragment() 
{
	ALBEDO = vec3(0.0, 0.0, 0.0);
	METALLIC = 0.1;
	SPECULAR = 0.9;
	ROUGHNESS = 0.5;
}





