shader_type spatial;
render_mode unshaded;

uniform float time_scale = 1.0;
uniform float detail1 = 3.0;
uniform float power1 = 2.5;
uniform float color_mul1 = 1.15;
uniform float glow_rate1 = 1.5;
uniform float noise_amt1 = 1.5;
uniform vec4 lava_color : source_color = vec4(1.2, 0.4, 0.0, 1.0);
uniform vec3 rock_color : source_color = vec3(0.6, 0.2, 0.0);
uniform float rock_color_change_intensity = 0.;
uniform float rock_color_change_speed = 0.;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec2 random2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)),
                          dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

float value_noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(mix(dot(random2(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
                   dot(random2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
               mix(dot(random2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
                   dot(random2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
}

float magma_layer(vec2 uv, vec3 color, float detail, float power, float colorMul, float glowRate, float noiseAmount) {
    float t = TIME * time_scale;
    uv *= detail;

    vec2 cell = floor(uv);
    vec2 frac = fract(uv);
    float min_dist = 1.0;

    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            vec2 offset = vec2(float(i), float(j));
            vec2 rand_point = random2(cell + offset);
            rand_point += value_noise(uv) * noiseAmount;

            float dist = length(offset + rand_point - frac);
            min_dist = min(min_dist, dist);
        }
    }

    float pow_add = sin(uv.x * 2.0 + t * glowRate) + sin(uv.y * 2.0 + t * glowRate);
    return pow(min_dist, power + pow_add * 0.95) * colorMul;
}

void fragment() {
    vec2 uv = UV;
    uv.x *= 1.0; // Keep aspect ratio if needed

    // First layer (base cracks)
    float m1 = magma_layer(uv, vec3(1.5, 0.45, 0.0), detail1, power1, color_mul1, glow_rate1, noise_amt1);

    // Rock color with subtle animation
	vec3 background_color = (sin(TIME * time_scale * rock_color_change_speed) / 2. + 1.) * rock_color_change_intensity * rock_color + rock_color;
    
    vec3 lava = m1 * lava_color.rgb;

    lava = mix(background_color, lava, clamp(m1, 0.0, 1.0));

    ALBEDO = lava;
    EMISSION = lava;
}
