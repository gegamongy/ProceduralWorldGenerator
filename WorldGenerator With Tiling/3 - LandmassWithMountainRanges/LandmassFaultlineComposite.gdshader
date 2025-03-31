shader_type canvas_item;
uniform sampler2DArray landmass_map;
uniform sampler2DArray faultline_map;
uniform sampler2D mountain_range_texture;
uniform sampler2D rolling_hills_texture;
uniform float mountain_amplitude;
uniform float hills_amplitude;
uniform float threshold = 0.77;
uniform float blend_radius = 0.1;

uniform int tile_count;
uniform ivec2 current_tile;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	vec2 tiled_uv = (UV / float(tile_count)) + (vec2(current_tile) / float(tile_count));
	
	float current_tile_index = (float(current_tile.x) * float(tile_count)) + float(current_tile.y);
	
	float landmass = texture(landmass_map, vec3(UV, current_tile_index)).r;
	float faultline = texture(faultline_map, vec3(UV, current_tile_index)).r;
	float mountain_range = texture(mountain_range_texture, tiled_uv).r * mountain_amplitude;
	float rolling_hills = texture(rolling_hills_texture, tiled_uv).r * hills_amplitude;
	
	float mountain_range_mask = smoothstep(threshold-blend_radius, threshold, faultline);
	float rolling_hills_mask = faultline * (1.0 - mountain_range_mask);
	
	float composite = landmass + (rolling_hills * rolling_hills_mask) + (mountain_range * mountain_range_mask);
	
	COLOR.rgb = vec3(composite);

}

