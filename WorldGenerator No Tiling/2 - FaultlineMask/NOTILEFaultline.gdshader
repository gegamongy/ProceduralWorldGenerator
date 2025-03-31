shader_type canvas_item;
uniform sampler2D noise;

uniform float fault1_center = -0.19;
uniform float fault1_gradient_offset = -0.93;
uniform float fault1_gradient_scale = 8.5;
uniform float fault1_distortion = 0.09;
uniform float fault1_uv_rotation = -3.59;
uniform float fault1_curve_factor = 0.81;

uniform float fault2_center = 0.0;
uniform float fault2_gradient_offset = -0.93;
uniform float fault2_gradient_scale = 8.5;
uniform float fault2_distortion = 0.09;
uniform float fault2_uv_rotation = 0.0;
uniform float fault2_curve_factor = 0.0;

vec2 rotate_uv(vec2 uv, float angle) {
    // Rotate UV coordinates around the fault1_center
    float cos_theta = cos(angle);
    float sin_theta = sin(angle);
    return vec2(
        cos_theta * uv.x - sin_theta * uv.y,
        sin_theta * uv.x + cos_theta * uv.y
    );
}

vec2 warp_uv(vec2 uv, vec2 tex_coord, float uv_rotation, float center, float curve_factor, float distortion) {
	uv = rotate_uv(uv, uv_rotation);
	float curve = uv.x * uv.x * curve_factor + center;
	float noise_val = (texture(noise, tex_coord).r * 2.0) - 1.0;
	float offset = (noise_val) * distortion;
	uv.y += curve - offset + center;
	return uv;
}

float gradient(vec2 uv, float gradient_offset, float gradient_scale) {
	
	float dist = 1.0 - abs(uv.y);
	dist += gradient_offset;
	dist *= gradient_scale;
	return dist;
}



void fragment() {
	
	vec2 uv = UV - 0.5;

	float fault1 = gradient(warp_uv(uv, UV, fault1_uv_rotation, fault1_center, fault1_curve_factor, fault1_distortion), fault1_gradient_offset, fault1_gradient_scale);
	float fault2 = gradient(warp_uv(uv, UV, fault2_uv_rotation, fault2_center, fault2_curve_factor, fault2_distortion), fault2_gradient_offset, fault2_gradient_scale);


	COLOR.rgb = vec3(max(fault1, fault2));
	
}
