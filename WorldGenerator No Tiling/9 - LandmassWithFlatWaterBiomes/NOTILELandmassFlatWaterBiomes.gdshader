shader_type canvas_item;

uniform sampler2D heightmap;
uniform sampler2D water_biome_mask: filter_nearest;
uniform sampler2D water_biome_altitude : filter_nearest;


void fragment() {

	float height = texture(heightmap, UV).r;
	float wetland = texture(water_biome_mask, UV).r;
	float swamp = texture(water_biome_mask, UV).g;
	float lake = texture(water_biome_mask, UV).b;
	float water_altitude = texture(water_biome_altitude, UV).r;
	
	float water_mask = clamp(wetland + swamp + lake, 0.0, 1.0);
	
	float composite = mix(height, water_altitude, water_mask);
	
	COLOR.rgb = vec3(composite);
	
}
