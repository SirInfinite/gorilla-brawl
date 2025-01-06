shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float blur_size : hint_range(0.0, 20.0);

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 color = vec4(0.0);

    float total = 0.0;
    float blur_step = 1.0 / float(textureSize(screen_texture, 0).y);

    for (float y = -blur_size; y <= blur_size; y++) {
        float weight = (1.0 - abs(y) / blur_size);
        color += texture(screen_texture, uv + vec2(0.0, y * blur_step)) * weight;
        total += weight;
    }

    color /= total;
    COLOR = color;
}