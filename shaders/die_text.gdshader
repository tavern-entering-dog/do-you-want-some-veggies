shader_type canvas_item;

uniform float amplitude = 25.;

void vertex() {
	VERTEX.y = amplitude*sin(2.*TIME + 1.5*UV.x) + VERTEX.y; 
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
