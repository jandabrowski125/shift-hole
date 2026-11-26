shader_type canvas_item;

uniform float percentage = 0.0;

void fragment() {
	if (UV.x > (percentage)) {
		COLOR = vec4(0,0,0,0);
	}
	else {
		COLOR = texture(TEXTURE, UV);
	}
}
