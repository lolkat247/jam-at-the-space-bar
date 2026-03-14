shader_type canvas_item;

uniform float pixel_size : hint_range(1.0, 8.0) = 3.0;

void fragment() {
	vec2 snapped_uv = floor(UV / TEXTURE_PIXEL_SIZE / pixel_size) * pixel_size * TEXTURE_PIXEL_SIZE;
	COLOR = texture(TEXTURE, snapped_uv) * COLOR;
}
