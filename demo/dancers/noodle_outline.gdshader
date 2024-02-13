shader_type spatial;
render_mode cull_front, depth_draw_always, unshaded;

instance uniform vec4 outline_color : source_color;
const float outline_width = 2.0;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture;

const int bone_count = 3;
uniform vec3 bones[bone_count];

void vertex() 
{
	float f = (VERTEX.y + 0.25) * float(bone_count - 1);
	
	int bone_1_idx = int(floor(f));
	int bone_2_idx = int(ceil (f));
	
	float ratio = fract(f);

	vec3 bone_1 = bones[bone_1_idx];
	vec3 bone_2 = bones[bone_2_idx];
	
	vec3 offset = vec3(0);
	offset = bone_1 * (1.0 - ratio);
	offset = bone_2 * ratio;

	VERTEX.y = 0.0;
	VERTEX += offset;
	
	
	
	
	vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 clip_normal = mat3(PROJECTION_MATRIX) * (mat3(MODELVIEW_MATRIX) * NORMAL);
	
	vec2 offsets = normalize(clip_normal.xy) / VIEWPORT_SIZE * clip_position.w * outline_width * 2.0;
	
	clip_position.xy += offsets;
	
	POSITION = clip_position;
}

void fragment() 
{
	ALBEDO = outline_color.rgb;
	if (outline_color.a < 1.0) 
	{
		ALPHA = outline_color.a;
	}
	
	
}
