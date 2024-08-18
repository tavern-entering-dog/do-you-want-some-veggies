shader_type canvas_item;

uniform float wiggleness;

void vertex() {
	VERTEX.x += wiggleness*sin(TIME);
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
