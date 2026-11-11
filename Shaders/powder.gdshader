shader_type spatial;
render_mode cull_disabled;

group_uniforms PhysicsSetByScript;
uniform vec2 coeff; // Coefficients of the linear function for the surface.
uniform float vel; // Rate of change of the coefficients.

uniform vec3 bounds_center;
uniform vec3 bounds_half_extent;

group_uniforms Visuals;
uniform vec4 powder_color     : source_color = vec4(0.4, 0.4, 0.4, 1.0);
uniform float fill_amount     : hint_range(0.0, 1.0, 0.001) = 0.5;
uniform vec2 size             = vec2(1.0, 1.0);
uniform float scale           = 1.0;
uniform float wave_intensity  = 0.05f;
uniform sampler2D waves_noise;

varying lowp vec3 pos;
varying lowp float rot_scale;
varying lowp vec3 world_vec_up_to_model;
varying lowp vec3 weights;

varying vec3 local_pos;

uniform float grain_scale = 80.0;
uniform float grain_strength = 0.3;

float hash31(vec3 p) {
    p = fract(p * 0.1031);
    p += dot(p, p.yzx + 33.33);

    return fract((p.x + p.y) * p.z);
}

void vertex() {
	local_pos = VERTEX;
	/* Position inside container rotated to world. */
	pos                   = mat3(MODEL_MATRIX)*VERTEX;
	/* Lerp between height and width depending on world orientation of z axis. */
	world_vec_up_to_model = vec3(0.0f, 1.0f, 0.0f)* mat3(MODEL_MATRIX);
	rot_scale             = mix(size.x, size.y, abs(dot(world_vec_up_to_model, vec3(0.0f, 1.0f, 0.0f))));
	weights               = mat3(MODEL_MATRIX)*NORMAL; 
	weights*=weights;
}

void fragment() {
	/* Set liquid line to fill amount, add noise waves and incline. */
	lowp float wave_noise_1 = texture(waves_noise, (2.0 * pos.xz + 0.5 * TIME * vec2(1.0, 1.0)) * scale).r;
	lowp float wave_noise_2 = texture(waves_noise, (2.0 * pos.xz - 0.5 * TIME * vec2(1.0, 1.0)) * scale).g;
	lowp float wave = wave_intensity * length(coeff) * (wave_noise_1 - 0.5f + wave_noise_2 - 0.5f) + dot(pos.xz, coeff);
	wave *= smoothstep(0.05, 0.25, fill_amount);
	
	mat3 model = mat3(MODEL_MATRIX);
	
	float center_y = (model * bounds_center).y;
	
	float vertical_half_extent =
		abs(model[0].y) * bounds_half_extent.x +
		abs(model[1].y) * bounds_half_extent.y +
		abs(model[2].y) * bounds_half_extent.z;
	
	lowp float liquid_line = center_y + (fill_amount * 2.0 - 1.0 + wave) * vertical_half_extent;
	if (pos.y > liquid_line) discard;// Discard all vertices above the liquid line. */
	
	float grain = hash31(floor(local_pos * grain_scale));

	float grainShading = 1.0 + (grain - 0.5) * grain_strength;

	vec2 radial_pos = (local_pos.xz - bounds_center.xz) / max(bounds_half_extent.xz, vec2(0.001));

	float radius = length(radial_pos);
	float edge = smoothstep(0.65, 1.0, radius);

	float edgeShading = mix(1.0, 0.7, edge);

	ALBEDO = powder_color.rgb * edgeShading * grainShading;
	ROUGHNESS = 1.0;
}

/* void light() 
{
	// Liquid "glow" when held against light. 
	lowp float d  = dot(-VIEW, LIGHT);
	lowp float dd = smoothstep(0.0, 1.0, d);
	dd *= dd;
	DIFFUSE_LIGHT = (dd -BACKLIGHT.z * d) * liquid_color.rgb;
}
*/