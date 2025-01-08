/* 
Simplified version of Blur Vignette (Post Processing / ColorRect) [Godot 4.2.1]
made by paitorocxon on Dec 29, 2023, modified by SirInfinity on Jan 7, 2025
(godotshaders.com/shader/blur-vignette-post-processing-colorrect-godot-4-2-1/)
*/

shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float blur_amount : hint_range(0, 5) = 1.0; // Strength of the blur effect

void fragment() {
    // Original color of the pixel from the screen
    vec4 pixelColor = texture(screen_texture, UV);
    
    // Color with blur effect from the screen
    vec4 blurColor = textureLod(screen_texture, SCREEN_UV, blur_amount);

    // Set the final color to the blur effect (no distance-based blending)
    COLOR = blurColor;
}