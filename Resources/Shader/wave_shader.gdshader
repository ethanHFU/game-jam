shader_type spatial;
render_mode unshaded;
//render_mode wireframe;

global uniform vec3 wave_origin;
global uniform float expand_wave;

uniform float debug_time = 0.0;

uniform float world_scaling = 1.;
uniform float tex_scroll_speed = .05;
uniform float tex_reapeater = 1.;
uniform vec3 col_1 : source_color = vec3(0.0, .54, 1.);
uniform vec3 col_2 : source_color = vec3(.21, .74, 1.);
uniform sampler2D noise_tex;
uniform sampler2D noise_tex2;

varying float d;
varying float foam;

void vertex() {
	vec3 world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; // use world space
	vec3 wave_center = world_vertex - wave_origin;
	
	d = length(vec2(VERTEX.x, VERTEX.z))*(1./world_scaling);
	
	float w1 = abs(d - debug_time - expand_wave + 2.);
	w1 = smoothstep(0.0, 1.0, w1 * .5); // scalar makes waves more flat
	w1 -= .6;
	
	float w2 = abs(d - debug_time - expand_wave + 6.5);
	w2 = smoothstep(0.0, 1., w2 * .5) * 2.;
	
	float w = w1 * w2;
	
	VERTEX.y = -w +.75;
	foam = smoothstep(.0, 1., VERTEX.y);
}

void fragment() {
	vec2 uv = fract(UV)*tex_reapeater;
	uv.y = uv.y * 1. + sin(TIME*.5)*.25;
	uv.x *= .1;
	uv.x += TIME*tex_scroll_speed;
	vec3 noise = texture(noise_tex, uv).rgb;
	noise = length(noise) < .8 ? col_1 : col_2;
	
	vec2 uv2 = UV;
	uv2.y = uv.y - sin(TIME*.25)*.25;
	uv2.x *= .1;
	uv2.x += TIME*tex_scroll_speed*.9;
	vec3 noise2 = texture(noise_tex2, uv2).rgb;
	noise2 = length(noise2) < .6 ? col_2 : col_1;
	
	vec3 col = noise*.5 + noise2*.5 + (noise+noise2)*foam;
	ALBEDO = col;
	ALPHA = 1.-smoothstep(.0, 10., d);
}
