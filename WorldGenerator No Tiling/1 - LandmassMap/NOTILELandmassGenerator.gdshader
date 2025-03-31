shader_type canvas_item;

//Saved as resource in landmass_shader_material
uniform sampler2D continent_noise;
uniform sampler2D island_noise;
uniform sampler2D continent_falloff;
uniform sampler2D island_outer_falloff;
uniform sampler2D island_inner_falloff;

//Landmass constants
uniform float outer_falloff_distortion = -0.206;
uniform float inner_falloff_distortion = 0.0;


//Set in LandmassGenerator script
uniform float continent_amplitude = 1.0;
uniform float island_amplitude = 0.5;


float evaluate(float value) {
	float a = 2.0;
	float b = 2.0;
	return pow(value, a) / (pow(value, a) + pow(b - b * value, a));
}

vec2 distort(vec2 coord, float value) {
	float continent_noise_val = texture(continent_noise, coord).r;
	vec2 direction = normalize(coord - vec2(0.5));
	vec2 offset = (direction * continent_noise_val * value);
	coord += offset;
	return coord;
}


void vertex() {

}

void fragment() {
	
	float continent = 1.0 - evaluate(texture(continent_falloff, UV).r);
	float continent_noise_val = texture(continent_noise, UV).r;
	float island_inner = evaluate(texture(island_outer_falloff, distort(UV, outer_falloff_distortion)).r);
	float island_outer = evaluate(texture(island_inner_falloff, distort(UV, inner_falloff_distortion)).r);
	float island_noise_val = texture(island_noise, UV).r;
	float island_mask = (1.0-island_inner) * (island_outer);
	COLOR.rgb =  vec3((island_mask*island_noise_val * island_amplitude) + continent*continent_noise_val * continent_amplitude);
}
