shader_type canvas_item;
uniform sampler2D landmass_map;
uniform sampler2D faultline_map;
uniform sampler2D mountain_range_texture;
uniform sampler2D rolling_hills_texture;
uniform float mountain_amplitude = 1.0;
uniform float hills_amplitude = 1.0;
uniform float threshold = 0.757;
uniform float blend_radius = 0.447;


void fragment() {
	
	float landmass = texture(landmass_map, UV).r;
	float faultline = texture(faultline_map, UV).r;
	
	float mountain_range = texture(mountain_range_texture, UV).r * mountain_amplitude;
	float rolling_hills = texture(rolling_hills_texture, UV).r * hills_amplitude;
	
	float mountain_range_mask = smoothstep(threshold - blend_radius, threshold, faultline);
	float rolling_hills_mask = faultline * (1.0 - mountain_range_mask);
	
	float composite = landmass + (rolling_hills * rolling_hills_mask) + (mountain_range * mountain_range_mask);
	
	COLOR.rgb = vec3(composite);

}
