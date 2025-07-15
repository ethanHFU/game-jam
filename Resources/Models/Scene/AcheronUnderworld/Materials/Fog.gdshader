shader_type fog;

uniform float density = 3.;
uniform sampler2D noise_tex;
uniform float noise_scale = .5;
uniform float falloff = 3.;
uniform float emission_strength = 0.;
uniform vec3 fog_color = vec3(1., 1., 1.);
uniform float scroll_speed = 0.01;

void fog() {
	float noise = texture(noise_tex, vec2(fract((UVW.x + TIME * scroll_speed) * noise_scale), UVW.z * noise_scale)).r;
	DENSITY = mix(1., noise, UVW.y * falloff) * density;
	ALBEDO = fog_color;
	EMISSION = fog_color * emission_strength;
}