shader_type spatial;

//render_mode unshaded, cull_disabled, blend_add;

void fragment() {
    ALBEDO = vec3(2.0, 2.0, 1.0); // solid red
    ROUGHNESS = 0.5;
    METALLIC = 0.0;
	RIM = 2.0;
	RIM = 2.0;
}