shader_type spatial;

uniform sampler2D noise_tex;


void vertex() {
	vec3 world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	float h = texture(noise_tex, fma(world_vertex.xz, vec2(.1), vec2(TIME*.1))).x * 4.;
	
	VERTEX.y += h -.35;
}

void fragment() {
	vec3 col = texture(noise_tex, UV-TIME*.05).rgb;
	ALBEDO = col;
	ROUGHNESS = .25;
}
