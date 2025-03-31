shader_type canvas_item;

//CURRENT NUMBER OF BIOMES: 13

uniform sampler2DArray rainfall_maps;
uniform sampler2DArray humidity_maps;
uniform sampler2DArray altitude_maps;

uniform bool display_biome_colors;
uniform int biome_weight_image = 0;

uniform int tile_count;
uniform ivec2 current_tile;

//Biome Colors
uniform vec3 lake_color = vec3(0, 0, 1); 
uniform vec3 swamp_color= vec3(0, 0.21, 0.21);
uniform vec3 wetlands_color = vec3(0, 0.55, 0.66);
uniform vec3 rainforest_color = vec3(0, 0.53, 0.23);
uniform vec3 dryforest_color = vec3(0.24, 0.35, 0);
uniform vec3 grasslands_color = vec3(0.74, 0.61, 0);
uniform vec3 tundra_color = vec3(0.9, 0.43, 0.38);
uniform vec3 desert_color = vec3(0.81, 0.38, 0);

uniform vec3 ocean_color = vec3(0.1, 0.1, 1);
uniform vec3 beach_color = vec3(0.4, 0.3, 0.0);
uniform vec3 alpine_grassland_color = vec3(0.5);
uniform vec3 alpine_tundra_color = vec3(0.75);
uniform vec3 alpine_desert_color = vec3(0.9);


uniform float hum_desert_tundra_flag = 0.27;
uniform float hum_tundra_grass_flag = 0.33;
uniform float hum_grass_dryf_flag = 0.55;
uniform float hum_dryf_rainf_flag = 0.77;
uniform float hum_wetland_swamp_flag = 0.55;
uniform float hum_swamp_lake_flag = 0.77;

uniform float rain_water_biome_flag = 0.77;

// Biome thresholds
uniform float ocean_alt_threshold = 0.1214; //Sea Level 85/700
uniform float beach_alt_threshold = 0.14; //This doesnt do anything rn
uniform float regular_biomes_threshold = 0.14;
uniform float alpine_grass_alt_threshold = 0.35;
uniform float alpine_tundra_alt_threshold = 0.429;
uniform float alpine_desert_alt_threshold = 0.48;

const float desert_rf_min = 0.0;
const float desert_rf_max = 0.77;
const float desert_hum_min = 0.0;
const float desert_hum_max = 0.22;

const float tundra_rf_min = 0.0;
const float tundra_rf_max = 0.77;
const float tundra_hum_min = 0.22;
const float tundra_hum_max = 0.33;

const float grasslands_rf_min = 0.0;
const float grasslands_rf_max = 0.77;
const float grasslands_hum_min = 0.33;
const float grasslands_hum_max = 0.55;

const float dryforest_rf_min = 0.0;
const float dryforest_rf_max = 0.77;
const float dryforest_hum_min = 0.55;
const float dryforest_hum_max = 0.77;

const float rainforest_rf_min = 0.0;
const float rainforest_rf_max = 0.77;
const float rainforest_hum_min = 0.77;
const float rainforest_hum_max = 1.0;

const float wetlands_rf_min = 0.77;
const float wetlands_rf_max = 1.0;
const float wetlands_hum_min = 0.0;
const float wetlands_hum_max = 0.55;

const float swamp_rf_min = 0.77;
const float swamp_rf_max = 1.0;
const float swamp_hum_min = 0.55;
const float swamp_hum_max = 0.77;

const float lake_rf_min = 0.77;
const float lake_rf_max = 1.0;
const float lake_hum_min = 0.77;
const float lake_hum_max = 1.0;

uniform float blend_radius = 0.02;

const float rf_min = 0.54;
const float hum_min = 0.82;


void fragment(){
	
	vec2 tile_offset = vec2(current_tile) / float(tile_count);
	vec2 tiled_uv = (UV / float(tile_count)) + tile_offset;
	
	float current_tile_index = (float(current_tile.x) * float(tile_count)) + float(current_tile.y);
	
	float rainfall = texture(rainfall_maps, vec3(UV, current_tile_index)).r;
	float humidity = texture(humidity_maps, vec3(UV, current_tile_index)).r;
	float altitude = texture(altitude_maps, vec3(UV, current_tile_index)).r;
	
	vec3 colors[13] = vec3[13](
        desert_color, tundra_color, grasslands_color, dryforest_color, 
        rainforest_color, wetlands_color, swamp_color, lake_color, 
		ocean_color, beach_color, alpine_grassland_color, alpine_tundra_color, alpine_desert_color
    );
    
	float min_rf[13] = float[13](
        desert_rf_min, tundra_rf_min, grasslands_rf_min, dryforest_rf_min,
        rainforest_rf_min, rain_water_biome_flag, rain_water_biome_flag, rain_water_biome_flag,
		0.0, 0.0, 0.0, 0.0, 0.0
    );
    
	float max_rf[13] = float[13](
        rain_water_biome_flag, rain_water_biome_flag, rain_water_biome_flag, rain_water_biome_flag,
        rain_water_biome_flag, wetlands_rf_max, swamp_rf_max, lake_rf_max,
		1.0, 1.0, 1.0, 1.0, 1.0
    );
    
	float min_hum[13] = float[13](
        desert_hum_min, hum_desert_tundra_flag, hum_tundra_grass_flag, hum_grass_dryf_flag,
        hum_dryf_rainf_flag, wetlands_hum_min, hum_wetland_swamp_flag, hum_swamp_lake_flag,
		0.0, 0.0, 0.0, 0.0, 0.0
    );
    
	float max_hum[13] = float[13](
        hum_desert_tundra_flag, hum_tundra_grass_flag, hum_grass_dryf_flag, hum_dryf_rainf_flag,
        rainforest_hum_max, hum_wetland_swamp_flag, hum_swamp_lake_flag, lake_hum_max,
		1.0, 1.0, 1.0, 1.0, 1.0
    );
	
	float min_altitude[13] = float[13](
		regular_biomes_threshold, 
		regular_biomes_threshold, 
		regular_biomes_threshold, 
		regular_biomes_threshold, 
		regular_biomes_threshold,
		regular_biomes_threshold, 
		regular_biomes_threshold, 
		regular_biomes_threshold, 
		0.0, 
		ocean_alt_threshold,
		alpine_grass_alt_threshold,
		alpine_tundra_alt_threshold,
		alpine_desert_alt_threshold
	);
	
	float max_altitude[13] = float[13](
		alpine_grass_alt_threshold,
		alpine_grass_alt_threshold,
		alpine_grass_alt_threshold,
		alpine_grass_alt_threshold,
		alpine_grass_alt_threshold,
		alpine_grass_alt_threshold,
		alpine_grass_alt_threshold,
		alpine_grass_alt_threshold,
		ocean_alt_threshold,
		regular_biomes_threshold,
		alpine_tundra_alt_threshold,
		alpine_desert_alt_threshold,
		1.0
	);
	
	float weights[13];
	
	for (int i = 0; i < 13; i++) {
		
		float rf_weight = 0.0;
		float hum_weight = 0.0;
		float alt_weight = 0.0;
		// Check for ocean biome separately
	    if (i == 8) { // Assuming ocean is at index 8
	        if (altitude < ocean_alt_threshold) {
	            weights[i] = 1.0; // Fully assign weight to ocean
	            // Set all other weights to 0.0
	            for (int j = 0; j < 13; j++) {
	                if (j != i) {
	                    weights[j] = 0.0;
	                }
	            }
	            break; // Exit loop early if ocean biome takes precedence
	        }
	    }
		
		if (
			rainfall < min_rf[i] - blend_radius || 
			rainfall > max_rf[i] + blend_radius || 
			humidity < min_hum[i] - blend_radius || 
			humidity > max_hum[i] + blend_radius ||
			altitude < min_altitude[i] - blend_radius ||
			altitude > max_altitude[i] + blend_radius) {
			
			weights[i] = 0.0;
		} else {
			if (altitude < min_altitude[i]) {
				alt_weight = smoothstep(min_altitude[i]-blend_radius, min_rf[i], altitude);
			} else if (altitude > max_altitude[i]) {
				alt_weight = smoothstep(max_altitude[i]+blend_radius, min_rf[i], altitude);
			} else {
				alt_weight = 1.0;
			}
			
			
			if (rainfall < min_rf[i]) {
				rf_weight = smoothstep(min_rf[i] - blend_radius, min_rf[i], rainfall);
			} else if (rainfall > max_rf[i]) {
				rf_weight = smoothstep(max_rf[i] + blend_radius, max_rf[i], rainfall);
			} else {
				rf_weight = 1.0;
			}
			
			if (humidity < min_hum[i]) {
                hum_weight = smoothstep(min_hum[i] - blend_radius, min_hum[i], humidity);
            } else if (humidity > max_hum[i]) {
                hum_weight = smoothstep(max_hum[i] + blend_radius, max_hum[i], humidity);
            } else {
                hum_weight = 1.0;
            }
			
			weights[i] = (rf_weight + hum_weight + alt_weight) / 2.0;
		}
	}
	
	//Normalize weights to a sum of 1.0
	float total_weight = 0.0;
	for (int i = 0; i < 13; i++) {
		total_weight += weights[i];
	}
	if (total_weight > 0.0) {
		for (int i = 0; i < 13; i++) {
			weights[i] /= total_weight;
		}
	}
	weights[8] = floor(weights[8]); //Prevent ocean biome blending.
	
	vec3 blended_color = vec3(0.0);
	for (int i = 0; i < 13; i++) {
		blended_color += colors[i] * weights[i];
	}
	
	// For lake biome areas, create a gradient based on rainfall and humidity
    vec3 lake_depth_gradient = vec3(0.0);
	if (weights[7] > 0.99) { // If lake biome is dominant
        float rain = (rainfall - 0.72) / (1.0 - 0.72);
		float hum = (humidity - 0.54) / (1.0 - 0.54);
		float alt = 2.0 *(altitude - 0.14) / (0.35 - 0.14) - 1.0;
       
        float gradient = rain * hum * (1.0 - abs(alt));
		gradient = smoothstep(0.0, 1.0, gradient* 5.0);
      
		lake_depth_gradient = vec3(gradient);
	}
	
	// For swamp biome areas, create a gradient based on rainfall and humidity
    vec3 swamp_gradient = vec3(0.0);
	if (weights[6] > 0.99) { // If lake biome is dominant
        float rain = (rainfall - 0.72) / (1.0 - 0.72);
		float hum = 2.0 * (humidity - 0.42) / (0.54 - 0.42) - 1.0;
		float alt = 2.0 * (altitude - 0.14) / (0.35 - 0.14) - 1.0;
       
        float gradient = rain *  (1.0 - abs(hum)) * (1.0 - abs(alt));
		gradient = smoothstep(0.0, 1.0, gradient* 7.0);
      
		swamp_gradient = vec3(gradient);
	}
	
	// For swamp biome areas, create a gradient based on rainfall and humidity
    vec3 wetland_gradient = vec3(0.0);
	if (weights[5] > 0.99) { // If lake biome is dominant
        float rain = (rainfall - 0.72) / (1.0 - 0.72);
		float hum = 2.0 * (humidity - 0.00) / (0.42 - 0.00) - 1.0;
		float alt = 2.0 * (altitude - 0.14) / (0.35 - 0.14) - 1.0;
       
        float gradient = rain *  (1.0 - abs(hum)) * (1.0 - abs(alt));
		gradient = smoothstep(0.0, 1.0, gradient* 9.0);
      
		wetland_gradient = vec3(gradient);
	}
	
	
	vec3 water_biomes = vec3(weights[5], weights[6], weights[7]); //
	vec3 biome_weights_0 = vec3(weights[0], weights[1], weights[2]);
	vec3 biome_weights_1 = vec3(weights[3], weights[4], weights[5]);
	vec3 biome_weights_2 = vec3(weights[6], weights[7], weights[8]);
	vec3 biome_weights_3 = vec3(weights[9], weights[10], weights[11]);
	vec3 biome_weights_4 = vec3(weights[12], 0.0, 0.0);
	
	if (display_biome_colors) {
		COLOR.rgb = blended_color;
	}
	else if (biome_weight_image == 0) {
		COLOR.rgb = biome_weights_0;
	}
	else if (biome_weight_image == 1) {
		COLOR.rgb = biome_weights_1;
	}
	else if (biome_weight_image == 2) {
		COLOR.rgb = biome_weights_2;
	}
	else if (biome_weight_image == 3) {
		COLOR.rgb = biome_weights_3;
	}
	else if (biome_weight_image == 4) {
		COLOR.rgb = biome_weights_4;
	}
	else if (biome_weight_image == 5) {
		COLOR.rgb = water_biomes;
	}
	else if (biome_weight_image == 6) {
		COLOR.rgb = lake_depth_gradient;
	}
	else if (biome_weight_image == 7) {
		COLOR.rgb  = swamp_gradient;
	}
	else if (biome_weight_image == 8) {
		COLOR.rgb  = wetland_gradient;
	}
}
