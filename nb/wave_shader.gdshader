shader_type spatial;
render_mode unshaded;
//render_mode wireframe;

global uniform vec3 wave_origin;
global uniform float expand_wave;

uniform float debug_time = 0.0;

uniform sampler2D noise_tex;

varying float d;
varying float foam;

void vertex() {
	vec3 world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; // use world space
	vec3 wave_center = world_vertex - wave_origin;
	
	d = length(vec2(wave_center.x, wave_center.z));
	
	float w1 = abs(d - debug_time - expand_wave + 2.);
	w1 = smoothstep(0.0, 2.0, w1);
	w1 -= .25;
	
	float w2 = abs(d - debug_time - expand_wave + 6.5);
	w2 = smoothstep(0.0, 3.5, w2);
	
	float w = w1 * w2;
	
	VERTEX.y = -w +.75;
	foam = smoothstep(.4, 1., VERTEX.y);
}

void fragment() {
	// threshhold , colors
	vec2 uv = UV;
	uv.y *= 2.;
	vec3 noise = texture(noise_tex, uv+TIME*.1).rgb;
	vec3 noise2 = texture(noise_tex, uv*.5+TIME*.1).rgb;
	vec3 col = noise*.5 + noise2*foam;
	ALBEDO = col;
	ALPHA = 1.-smoothstep(.0, 10., d);
}
