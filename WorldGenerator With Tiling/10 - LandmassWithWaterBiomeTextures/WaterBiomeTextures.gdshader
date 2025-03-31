shader_type canvas_item;

uniform float lake_scale;
uniform float swamp_scale;
uniform float wetland_scale;
uniform float water_biome_scale;

uniform sampler2DArray heightmap;
uniform sampler2DArray lake_depth_mask;
uniform sampler2DArray swamp_mask;
uniform sampler2DArray wetland_mask;

uniform sampler2D swamp_texture;
uniform sampler2D wetland_texture;

uniform int tile_count;
uniform ivec2 current_tile;

void vertex() {
	
}

void fragment() {
	vec2 f_current_tile = vec2(current_tile);
	vec2 tile_offset = f_current_tile / float(tile_count);
	vec2 tiled_uv = (UV / float(tile_count)) + tile_offset;
	
	//Get the TextureArray position from current_tile 2D Position
	float current_tile_index = (float(current_tile.x) * float(tile_count)) + float(current_tile.y);
	
	float height = texture(heightmap, vec3(UV, current_tile_index)).r;
	float lake = texture(lake_depth_mask, vec3(UV, current_tile_index)).r * lake_scale;
	float swamp = texture(swamp_mask, vec3(UV, current_tile_index)).r * swamp_scale;
	float wetland = texture(wetland_mask, vec3(UV, current_tile_index)).r * wetland_scale;
	
	float swamp_tex = texture(swamp_texture, tiled_uv).r;
	swamp_tex = (2.0 * swamp_tex - 1.0) * swamp_scale;
	float wetland_tex = texture(wetland_texture, tiled_uv).r;
	wetland_tex = (2.0 * wetland_tex - 1.0) * swamp_scale;
	
	float water_biome_mask = lake + (swamp * swamp_tex) + (wetland * wetland_tex);
	
	float composite = height - (water_biome_mask * water_biome_scale);
	COLOR.rgb = vec3(composite);

}
