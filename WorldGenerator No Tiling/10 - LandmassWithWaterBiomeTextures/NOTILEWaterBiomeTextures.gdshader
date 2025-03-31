shader_type canvas_item;

uniform float lake_scale;
uniform float swamp_scale;
uniform float wetland_scale;
uniform float water_biome_scale;

uniform sampler2D heightmap;
uniform sampler2D lake_depth_mask;
uniform sampler2D swamp_mask;
uniform sampler2D wetland_mask;

uniform sampler2D swamp_texture;
uniform sampler2D wetland_texture;


void vertex() {
	
}

void fragment() {
	
	float height = texture(heightmap, UV).r;
	float lake = texture(lake_depth_mask, UV).r * lake_scale;
	float swamp = texture(swamp_mask, UV).r * swamp_scale;
	float wetland = texture(wetland_mask, UV).r * wetland_scale;
	
	float swamp_tex = texture(swamp_texture, UV).r;
	swamp_tex = (2.0 * swamp_tex - 1.0) * swamp_scale;
	float wetland_tex = texture(wetland_texture, UV).r;
	wetland_tex = (2.0 * wetland_tex - 1.0) * wetland_scale;
	
	float water_biome_mask = lake + (swamp * swamp_tex) + (wetland * wetland_tex);
	
	float composite = height - (water_biome_mask * water_biome_scale);
	COLOR.rgb = vec3(composite);
	
}
