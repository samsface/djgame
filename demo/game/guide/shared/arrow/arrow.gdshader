shader_type spatial;

instance uniform vec3 albedo : source_color;
instance uniform float ttl : hint_range(0.0, 1.0);
instance uniform float scale : hint_range(0.0, 1.0);
instance uniform float tail_length;
instance uniform float spin;

void vertex()
{
	if(COLOR.g < 0.9)
	{
		VERTEX.y += tail_length;
	}

	float angle = TIME * spin;

	 mat3 rotation_matrix = mat3(
       vec3(cos(angle), 0.0, sin(angle)),
         vec3(0.0, 1.0, 0.0),
         vec3(-sin(angle), 0.0, cos(angle))
    );

    VERTEX = rotation_matrix * VERTEX;
}

void fragment()
{
	ALBEDO = albedo;
	EMISSION = albedo;
}
