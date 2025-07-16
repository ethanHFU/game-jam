shader_type fog;

uniform float density = 3.;
uniform sampler2D noise_tex;
uniform float noise_scale = 0.5;
uniform float falloff = 3.;
uniform float emission_strength = 0.;
uniform vec3 fog_color : source_color = vec3(1., 1., 1.);
uniform float total_speed = 0.;
uniform float scroll_speed = 0.;

// Parameters for Z-direction distortion
uniform float wave_amplitude = 0.02;
uniform float wave_frequency = 30.0;
uniform float wave_speed = 0.8;

// Parameters for falloff modulation
uniform float falloff_wave_amplitude = 0.2;
uniform float falloff_wave_frequency = 2.0;
uniform float falloff_wave_speed = 1.0;

// Color variation
uniform float color_variation_strength = 0.2;
uniform float color_noise_scale = 0.3; // NEW: controls size of color variation patches

void fog() {
	// Z-direction distortion
	float z_offset = sin(UVW.x * wave_frequency + TIME * wave_speed * total_speed) * wave_amplitude;

	// Sample noise texture with scrolling and distorted Z
	float noise = texture(
		noise_tex,
		vec2(
			fract((UVW.x + TIME * scroll_speed * total_speed) * noise_scale),
			(UVW.z + z_offset) * noise_scale
		)
	).r;

	// Modulate falloff with sine wave
	vec2 falloff_noise_uv = vec2(
		fract((UVW.x + TIME * falloff_wave_speed * total_speed / 10.) * noise_scale),
		fract((UVW.z + UVW.y + TIME * falloff_wave_speed * total_speed / 10.) * noise_scale)
	);
	
	float falloff_noise = texture(noise_tex, falloff_noise_uv).r;
	float falloff_mod = mix(1.0 - falloff_wave_amplitude, 1.0 + falloff_wave_amplitude, falloff_noise);

	// Compute final density
	DENSITY = mix(1.0, noise, UVW.y * falloff * falloff_mod) * density;

	// Add color variation
	vec2 color_noise_uv = vec2(
		fract(UVW.x * color_noise_scale),
		fract(UVW.z * color_noise_scale)
	);
	float color_noise = texture(noise_tex, color_noise_uv).r;

	vec3 color_variation = fog_color + (color_noise - 0.5) * 2.0 * color_variation_strength;
	color_variation = clamp(color_variation, 0.0, 1.0); // Prevent over/underflow

	ALBEDO = color_variation;
	EMISSION = color_variation * emission_strength;
}
