shader_type spatial;
render_mode unshaded;

// --- Time and animation ---
uniform float time_scale = 1.0;

// --- Crack parameters ---
uniform float crack_detail = 4.0;
uniform float crack_power = 5.0;          // Higher = thinner cracks
uniform float crack_noise_amount = 0.3;   // Less noise = cleaner cracks

// --- Noise parameters (inside cracks) ---
uniform float noise_detail = 4.0;
uniform float noise_power = 5.0;
uniform float noise_color_multiplier = 2.5;
uniform float noise_glow_rate = 2.0;
uniform float noise_noise_amount = 0.3;

// --- Colors and visual settings ---
uniform vec4 lava_color : source_color = vec4(1.5, 0.5, 0.1, 1.0);
uniform vec3 rock_color : source_color = vec3(0.1, 0.05, 0.02);
uniform float rock_color_change_intensity = 0.1;
uniform float rock_color_change_speed = 1.0;
uniform float lava_falloff = 6.0;          // Controls blending sharpness (unused now)


// --- Utility functions ---

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


// --- Main procedural functions ---

float magma_layer(vec2 uv, float detail, float power, float noise_amount) {
    float t = TIME * time_scale;
    uv *= detail;

    vec2 cell = floor(uv);
    vec2 frac = fract(uv);
    float min_dist = 1.0;
    float second_min_dist = 1.0;

    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            vec2 offset = vec2(float(i), float(j));
            vec2 rand_point = random2(cell + offset);
            rand_point += value_noise(uv) * noise_amount;

            float dist = length(offset + rand_point - frac);

            if (dist < min_dist) {
                second_min_dist = min_dist;
                min_dist = dist;
            } else if (dist < second_min_dist) {
                second_min_dist = dist;
            }
        }
    }

    float edge_dist = second_min_dist - min_dist;
    float crack = smoothstep(0.0, 0.1, edge_dist);
    crack = 1.0 - crack;

    return crack;
}


// Generate a pseudo-random direction vector for each cell based on its position
vec2 drift_direction(vec2 cell) {
    float angle = hash(cell) * 6.2831853; // random angle in [0, 2pi)
    return vec2(cos(angle), sin(angle));
}



float noise_pattern(vec2 uv, float detail, float power, float color_mul, float glow_rate, float noise_amount) {
    float t = TIME * time_scale;

    // Add movement by drifting UV based on time and a random direction vector
    vec2 drift = drift_direction(floor(uv)) * t * 0.5; // 0.5 is speed factor; adjust as needed
    uv = uv * detail + drift;

    vec2 cell = floor(uv);
    vec2 frac = fract(uv);
    float min_dist = 1.0;

    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            vec2 offset = vec2(float(i), float(j));
            vec2 rand_point = random2(cell + offset);
            rand_point += value_noise(uv) * noise_amount;

            float dist = length(offset + rand_point - frac);
            min_dist = min(min_dist, dist);
        }
    }

    float pow_add = sin(uv.x * 2.0 + t * glow_rate) + sin(uv.y * 2.0 + t * glow_rate);
    return pow(min_dist, power + pow_add * 0.95) * color_mul;
}



// --- Fragment shader ---

void fragment() {
    vec2 uv = UV;

    // Calculate crack mask
    float crack_mask = magma_layer(uv, crack_detail, crack_power, crack_noise_amount);

    // Calculate animated noise
    float noise_val = noise_pattern(uv, noise_detail, noise_power, noise_color_multiplier, noise_glow_rate, noise_noise_amount);

    // Mask noise with crack pattern so noise only shows inside cracks
    float masked_noise = crack_mask * noise_val;

    // Calculate animated rock background color
    vec3 background_color = (sin(TIME * time_scale * rock_color_change_speed) / 2.0 + 1.0)
                            * rock_color_change_intensity * rock_color + rock_color;

    // Lava glow color scaled by masked noise
    vec3 lava = masked_noise * lava_color.rgb;

    // Add lava glow on top of background color (no black holes)
    vec3 final_color = background_color + lava;

    // Clamp final color to valid range
    final_color = clamp(final_color, 0.0, 1.0);

    ALBEDO = final_color;
    EMISSION = final_color;
}
