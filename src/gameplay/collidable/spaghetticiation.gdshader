shader_type canvas_item;

uniform float proximity_factor : hint_range(0.0, 0.2) = 0.0;
uniform vec2 stretch_direction = vec2(0,0);
const vec2 center = vec2(0.5,0.5);

void vertex()
{
	vec2 ver = VERTEX;
	float distance = dot(ver, stretch_direction);
	if (distance > 0.0) {
		//corners are stretched more due to bigger distance to center, but maybe enough for now
		ver += stretch_direction * proximity_factor * distance;
		VERTEX = ver;
	}
}

void fragment() {
	vec2 uv = UV;
	float distance = dot(uv - center, stretch_direction);
	if (distance > 0.0) {
		uv += (stretch_direction * -1.0) * distance * proximity_factor;
	}
	COLOR = texture(TEXTURE, uv) * COLOR;
}