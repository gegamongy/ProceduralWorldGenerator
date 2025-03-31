shader_type spatial;

uniform sampler2DArray height_images: repeat_disable, filter_nearest;
uniform sampler2DArray biome_color_images: repeat_disable;

uniform int tile_size; //Size of each image tile in world coordinates. Ex: if each image tile is 512 px, the world size of the tile might be 1024m, resulting in 1 image sample per 2m.
uniform int row_size; //Size of each row, equal to sqrt(image_layer_amount). Set in script.

uniform float terrain_scale;

uniform float normal_scale;

uniform float amplitude;
varying vec2 texture_position;

varying vec3 world_vertex;
varying vec2 world_position;
varying float height;

vec2 get_local_uv(vec2 uv) {
	vec2 local_uv = fract(uv/ float(tile_size));
	//local_uv = clamp(local_uv, 0.0, float(row_size * row_size));
	
	return local_uv;
}

vec3 get_array_tex_pos(vec2 uv) {
	ivec2 tile_index = (ivec2(uv)/(tile_size));
	tile_index = clamp(tile_index, ivec2(0), ivec2(row_size - 1));
	int layer_index = tile_index.x * row_size + tile_index.y;
	
	vec2 local_uv = get_local_uv(uv); //Fract locks it in at being 1:1 with world meters
	
	return vec3(local_uv, float(layer_index));
}


vec3 get_normal(vec2 uv) {
	
	float offset = 1.0;
	
	vec3 hL_uvw = get_array_tex_pos(uv - vec2(offset, 0.0));
	vec3 hR_uvw = get_array_tex_pos(uv + vec2(offset, 0.0));
	vec3 hU_uvw = get_array_tex_pos(uv - vec2(0.0, offset));
	vec3 hD_uvw = get_array_tex_pos(uv + vec2(0.0, offset));
	
	float hL = texture(height_images, hL_uvw).r * normal_scale; 
	float hR = texture(height_images, hR_uvw).r * normal_scale;
	float hU = texture(height_images, hU_uvw).r * normal_scale;
	float hD = texture(height_images, hD_uvw).r * normal_scale;
	
	float hC = texture(height_images, get_array_tex_pos(uv)).r;
	
	vec3 normal;
	// Compute the normal
	normal.x = hL - hR;
	normal.z = hD - hU;
	normal.y = 2.0;  //must be 2x offset
    //vec3 normal = normalize(cross(tangentZ, tangentX));
	
	return normalize(normal);
}




void vertex() {
	//Get World position of vertex
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	vec2 tex_pos = ((world_vertex.xz) / terrain_scale) + 0.5 + (0.5 * (float(tile_size) * float(row_size)));
	world_position = (world_vertex.xz) / terrain_scale;
	
	float world_size = float(tile_size * row_size);
	height = 0.0;
	vec3 normal = vec3(0.0);
	
	
	if (world_position.x > (-0.5 * world_size) &&
		world_position.x < (0.5 * world_size) - 0.5 && //THE EXTRA 0.5 is because of texture wrapping after adding 0.5 to world coord
		world_position.y > (-0.5 * world_size) &&
		world_position.y < (0.5 * world_size) - 0.5) {
			
			
			vec3 array_tex_pos = get_array_tex_pos(tex_pos);
			
			height = texture(height_images, array_tex_pos).r; // instead of just getting height, use bicubic interpolation function to sample height 
			//height = bicubic_interpolate(tex_pos.x, tex_pos.y);
			normal = get_normal(tex_pos);
			
		}
	
	VERTEX.y = (height * amplitude) * terrain_scale;
	NORMAL = normal;
}

void fragment() {
	float world_size = float(tile_size * row_size);
	vec3 color = vec3(0.0);
	vec3 normal = vec3(0.0);
	float heightmap = 0.0;
	
	vec2 tex_pos = ((world_vertex.xz + 0.5)/terrain_scale) + 0.5 * (float(tile_size) * float(row_size)); // Position of vertex on Full World-Space Texture Coordinates
	
	if (world_position.x > -0.5 * world_size &&
		world_position.x < 0.5 * world_size &&
		world_position.y > -0.5 * world_size &&
		world_position.y < 0.5 * world_size) {
		
		vec3 array_tex_pos = get_array_tex_pos(tex_pos);
		//If world position is in world bounds (tile_size * row_size), show texture
		
		
		color = texture(biome_color_images, array_tex_pos).rgb;
		//heightmap = bicubic_interpolate(tex_pos.x, tex_pos.y);
		heightmap = texture(height_images, array_tex_pos).r * 0.5;
		normal = get_normal(tex_pos);
	} 
	
	
	ALBEDO.rgb = vec3(heightmap) ;
	//ALBEDO.rgb = color;
	
	
	//ALBEDO.rgb = texture(height_images, vec3(texture_position, layer)).rgb * 0.4; //texture(falloff_map, texture_position).rgb; //texture(clipmap_noise, texture_position).rgb;
	//NORMAL_MAP = texture(clipmap_normal, texture_position).rgb;
}


