shader_type spatial;

uniform vec3 hit_position;
uniform vec4 set_color;
uniform vec4 base_color;
uniform float radius = 0.02;
uniform float fade = 0.01;


varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float dist = distance(world_position, hit_position);

	float strength = 1.0 - smoothstep(radius - fade, radius, dist);

	ALBEDO = base_color.rgb;
	ALBEDO = mix(ALBEDO, set_color.rgb, strength);
}