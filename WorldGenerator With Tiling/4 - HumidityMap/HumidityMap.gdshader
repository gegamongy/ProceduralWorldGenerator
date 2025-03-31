shader_type canvas_item;

uniform sampler2D noise;

uniform int tile_count;
uniform vec2 current_tile;


void fragment() {
	vec2 tile_offset = current_tile / float(tile_count);
	vec2 tiled_uv = (UV / float(tile_count)) + tile_offset;
	
	COLOR = texture(noise, tiled_uv);
	
	
}
