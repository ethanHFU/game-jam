shader_type spatial;

uniform float tex_scroll_speed = .05;
uniform float tex_reapeater = 1.;
uniform vec3 col_1 : source_color = vec3(0.0, .54, 1.);
uniform vec3 col_2 : source_color = vec3(.21, .74, 1.);
uniform sampler2D noise_tex;
uniform sampler2D noise_tex2;

void fragment() {
	vec2 uv = fract(UV)*tex_reapeater;
	uv.y = uv.y * 2. + sin(TIME*.5)*.25;
	uv.x = uv.x * 2. + TIME*tex_scroll_speed;
	vec3 noise = texture(noise_tex, uv).rgb;
	noise = length(noise) < .8 ? col_1 : col_2;
	
	vec2 uv2 = UV;
	uv2.y = uv2.y - sin(TIME*.25)*.25;
	uv2.x = uv2.x *2. + TIME*tex_scroll_speed*.9;
	vec3 noise2 = texture(noise_tex2, uv2).rgb;
	noise2 = length(noise2) < .6 ? col_2 : col_1;
	
	vec3 col = noise*.5 + noise2*.5;
	ALBEDO = col;
}

