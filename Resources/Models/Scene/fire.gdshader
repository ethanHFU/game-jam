shader_type spatial;

uniform vec4 emission_color : source_color = vec4(1.0, 0.5, 0.0, 1.0); // fiery orange
uniform float base_strength : hint_range(0.0, 100.0) = 1.0;
uniform float flicker_strength : hint_range(0.0, 100.0) = 2.0;
uniform float flicker_speed : hint_range(0.1, 10.0) = 5.0;


float rand(float x) {
    return fract(sin(x * 12.9898) * 43758.5453);
}

void fragment() {
	float t = TIME * flicker_speed;
	float randomness = rand(floor(t)); // step noise
	float strength = sin(t) + 0.1 + randomness; // adds chaotic variation

	float emission_strength = base_strength + base_strength * strength;
	EMISSION = emission_color.rgb * emission_strength;
}
