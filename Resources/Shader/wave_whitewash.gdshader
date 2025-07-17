shader_type spatial;
render_mode unshaded;

global uniform vec3 wave_origin;
instance uniform float i_radius;
instance uniform float expand_wave;

uniform float radius = 0.0;
uniform float crest_ratio = 0.9;  // Defines where along the radius the crest will lie.
// Crest position also defines transition from wave to whitewash
uniform float max_radius = 10.0;  // Of wave + whitewash

uniform float world_scaling = 1.0;

uniform vec3 col_1 : source_color = vec3(0.0, 0.54, 1.0);  // Base water
uniform vec3 col_2 : source_color = vec3(0.21, 0.74, 1.0); // Wave crest

varying float d;
varying float crest_factor;

void vertex() {
    vec3 world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec3 wave_center = world_vertex - wave_origin;

	//d = length(world_vertex.xz - wave_origin.xz);
    d = length(vec2(VERTEX.x, VERTEX.z)) * (1.0 / world_scaling);

    float wave = 0.0;
	float wave_radius = max_radius * crest_ratio;
    if (d <= wave_radius) {
        // Distance from center to wave peak (middle of wave)
        //float wave_dist = abs(d - radius);
		//float crest_position = radius * crest_ratio;
		float crest_position = expand_wave * crest_ratio;
		
		float wave_dist = abs(d - crest_position);
        wave = 1.0 - smoothstep(0.0, 1.0, wave_dist * 0.5);

        // Add envelope: peak at half max_radius, fall off toward 0 and max_radius
        float envelope = 1.0 - abs((d - wave_radius * 0.5) / (wave_radius * 0.5));
        envelope = clamp(envelope, 0.0, 1.0);

        wave *= envelope;
    }

    VERTEX.y = wave * 1.5;
    crest_factor = wave;
}

void fragment() {
    vec2 uv = UV;
	uv.x -= 0.5;
	uv.y -= 0.5;
	vec3 color = mix(col_1, col_2, crest_factor);
	//float _radius = min(radius, max_radius);
	float _radius = min(expand_wave, max_radius);
 	float angle = atan(uv.x, uv.y);
	// More irregular, layered wobble
    float wobble = (
        sin(angle * 7.0 + TIME * 1.3) +
        cos(angle * 11.0 - TIME * 0.7) +
        sin(angle * 5.0 + cos(angle * 3.0 + TIME))
    ) * 0.25;
	
	float waviness_fac = smoothstep(0., 0.75, 1.0/(max_radius-_radius));
	if (d < _radius + wobble * waviness_fac) {
		float wave_radius = max_radius * crest_ratio;
		float _radius = min(radius, wave_radius);
		
		float white_factor = smoothstep(_radius*.8, _radius + wobble * waviness_fac, d);
    	white_factor = pow(white_factor, 8.0);
		color = mix(color, vec3(1.0), white_factor);
	}
	else {
		discard;
	}

    ALBEDO = color;

    // Optional fade out at distance (can help fade the whole effect)
	//ALPHA = 1.0 - smoothstep(0.0, radius + 2.0, d);
}

