shader_type canvas_item;

uniform vec4 foreground_color : source_color = vec4(1, 1, 1, 1);
uniform vec4 background_color : source_color = vec4(0, 0, 0, 1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.

	vec2 uv = UV;
	
	vec2 size = vec2(textureSize(TEXTURE, 0));
	vec2 pixel = vec2(1.0) / size;
	uv -= pixel * vec2(0.5);
	
	vec2 uv_pixels = uv * size;
	vec2 delta_pixel = fract(uv_pixels) - vec2(0.5);
	vec2 ddxy = fwidth(uv_pixels);
	vec2 mip = log2(ddxy) - 0.5;
	vec4 color = textureLod(TEXTURE, uv + (clamp(delta_pixel / ddxy, 0.0, 1.0) - delta_pixel) * pixel, min(mip.x, mip.y));

	if (color.r == 0.0) {
		COLOR = background_color;
	} else {
		COLOR = foreground_color;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
