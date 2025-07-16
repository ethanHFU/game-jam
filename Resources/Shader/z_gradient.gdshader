shader_type spatial;

uniform vec4 top_color : source_color;
uniform vec4 bottom_color : source_color;

uniform float z_min = -50.0;
uniform float z_max = 50.0;

varying float local_z;

void vertex() {
    local_z = VERTEX.z;
}

void fragment() {
    float z = clamp((local_z - z_min) / (z_max - z_min), 0.0, 1.0);
    ALBEDO = mix(bottom_color.rgb, top_color.rgb, z);
}