shader_type canvas_item;

uniform sampler2DArray heightmaps;
uniform sampler2DArray water_biome_masks: filter_nearest;
uniform sampler2DArray water_biome_altitudes : filter_nearest;

uniform int tile_count;
uniform ivec2 current_tile;



void fragment() {
	vec2 f_current_tile = vec2(current_tile);
	vec2 tile_offset = f_current_tile / float(tile_count);
	vec2 tiled_uv = (UV / float(tile_count)) + tile_offset;
	
	//Get the TextureArray position from current_tile 2D Position
	float current_tile_index = (float(current_tile.x) * float(tile_count)) + float(current_tile.y);
	
	float height = texture(heightmaps, vec3(UV, current_tile_index)).r;
	float wetland = texture(water_biome_masks, vec3(UV, current_tile_index)).r;
	float swamp = texture(water_biome_masks, vec3(UV, current_tile_index)).g;
	float lake = texture(water_biome_masks, vec3(UV, current_tile_index)).b;
	float water_altitude = texture(water_biome_altitudes, vec3(UV, current_tile_index)).r;
	
	float water_mask = clamp(wetland + swamp + lake, 0.0, 1.0);
	
	float composite = mix(height, water_altitude, water_mask);
	
	float water_full_mask = step(water_mask, 1.0) * step(1.0, water_mask);
	
	
	COLOR.rgb = vec3(composite);
	
}
