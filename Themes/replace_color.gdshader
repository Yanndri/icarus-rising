shader_type canvas_item;

uniform vec4 chosen_color : source_color = vec4(0.933, 0.765, 0.604, 1.0);
uniform vec4 replacement_color : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform float tolerance = 0.04;

void fragment() {
	vec4 original = texture(TEXTURE, UV);

	float match = 1.0 - step(
		tolerance,
		distance(original.rgb, chosen_color.rgb)
	);

	COLOR = vec4(
		mix(original.rgb, replacement_color.rgb, match),
		original.a
	);
}