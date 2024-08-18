shader_type canvas_item;

uniform vec2 dimensions = vec2(2304, 1296);

uniform vec2 amplitude = vec2(100., 125.);
uniform vec2 frequency = vec2(3.14159265, 1.570796325);
uniform vec2 shift = vec2(1., 1.5);

float nsin(float t) { return (sin(t) + 1.)/2.; }

void vertex() {
	VERTEX += amplitude*sin(frequency*(TIME + shift*UV));
}

void fragment() {
	float saturation = float(int(UV.x*dimensions.x - 75.) ^ int(UV.y*dimensions.y + 187.5))/2047.;
	COLOR.rgb = saturation*vec3(nsin(TIME), nsin(TIME + PI/4.), nsin(TIME + PI/2.));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
