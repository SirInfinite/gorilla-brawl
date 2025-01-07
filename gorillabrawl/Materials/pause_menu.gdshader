shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_size : hint_range(0.0, 20.0);

void fragment() {
	vec4 color = textureLod(screen_texture, SCREEN_UV, blur_size);
	COLOR = color;
}
