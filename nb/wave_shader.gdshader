shader_type spatial;
render_mode unshaded;
//render_mode wireframe;

global uniform vec3 wave_origin;
global uniform float ampl_decrement;

uniform vec4 water_col: source_color;
uniform sampler2D noise_tex;

varying float d;

void vertex() {
	vec3 world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; // use world space
	vec3 wave_center = world_vertex - wave_origin;
	
	d = length(vec2(wave_center.x, wave_center.z));
	
	VERTEX.y += sin(d*2. - TIME*8.) * ampl_decrement*exp(-d*.25);
}

void fragment() {
	vec3 noise = texture(noise_tex, UV).rgb;
	vec3 noise2 = texture(noise_tex, UV*2.+4.).rgb;
	ALBEDO = (noise * noise2) / 2.;
	ALPHA = 1.-smoothstep(.0, 10., d);
}
