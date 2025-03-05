shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0);
uniform float flash_intensity = 0.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color = mix(color, flash_color, flash_intensity);
	COLOR.rgb = color.rgb;
}

