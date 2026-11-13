shader_type spatial;

uniform float powder_amount : hint_range(0.0, 1.0) = 0.0;
uniform float max_height = 0.04;
uniform vec4 powder_color : source_color = vec4(0.85, 0.80, 0.68, 1.0);

void vertex() {
    float amount = clamp(powder_amount, 0.0, 1.0);

    float scale = pow(max(amount, 0.0001), 1.0 / 3.0);

    float radius = length(UV * 2.0 - vec2(1.0));
    float r = radius / scale;

    float profile = max(1.0 - r * r, 0.0) * amount;
    VERTEX.y += max_height * scale * pow(profile, 1.5);
}

void fragment() {
    float amount = clamp(powder_amount, 0.0, 1.0);
    float scale = pow(max(amount, 0.0001), 1.0 / 3.0);

    float radius = length(UV * 2.0 - vec2(1.0));

    if (amount <= 0.001 || radius > scale) {
        discard;
    }

    float grain = fract(
        sin(dot(floor(UV * 350.0), vec2(12.9898, 78.233)))
        * 43758.5453
    );
	
	float edgeShading = mix(0.55, 1.0, sqrt(radius));
	float grainShading = mix(0.95, 1.05, grain);

    float shading = edgeShading * grainShading;

    ALBEDO = powder_color.rgb * shading;
    ROUGHNESS = 1.0;
}