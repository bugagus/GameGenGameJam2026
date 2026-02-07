shader_type spatial;
render_mode unshaded, cull_disabled; 

uniform vec3 color : source_color = vec3(0.0, 1.0, 0.0);
uniform float cantidad_rayas = 20.0;

void fragment() {
	ALBEDO = color;
	float patron = sin(UV.x * 3.14159 * cantidad_rayas);
	
	if (patron < 0.0) {
		discard;
	}
	ALPHA = 0.8; 
}