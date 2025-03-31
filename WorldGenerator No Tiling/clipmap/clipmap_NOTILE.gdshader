shader_type spatial;

uniform sampler2D heightmap;
uniform sampler2D biome_colors;
uniform float tile_size = 2048.0;
uniform float amplitude = 130;

varying vec3 world_vertex;


void vertex() {
	// Get Texture Coordinates
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 tex_pos = ((world_vertex.xz + 0.5) + (0.5 * tile_size)) / tile_size;
	float height = 0.0;
	if (world_vertex.x > (-0.5 * tile_size) &&
		world_vertex.x < (0.5 * tile_size) - 0.5 && //THE EXTRA 0.5 is because of texture wrapping after adding 0.5 to world coord
		world_vertex.z > (-0.5 * tile_size) &&
		world_vertex.z < (0.5 * tile_size) - 0.5) {
			height = texture(heightmap, tex_pos).r;
		}
	
	VERTEX.y = height * amplitude;
	
}

void fragment() {
	vec2 tex_pos = ((world_vertex.xz + 0.5) + (0.5 * tile_size)) / tile_size;
	vec3 color = vec3(0.0);
	if (world_vertex.x > (-0.5 * tile_size) &&
		world_vertex.x < (0.5 * tile_size) - 0.5 && //THE EXTRA 0.5 is because of texture wrapping after adding 0.5 to world coord
		world_vertex.z > (-0.5 * tile_size) &&
		world_vertex.z < (0.5 * tile_size) - 0.5) {

			color = texture(heightmap, tex_pos).rgb * 0.2;
		}
	
	ALBEDO = color;
}

