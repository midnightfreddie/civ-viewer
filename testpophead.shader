shader_type canvas_item;

render_mode unshaded;

uniform vec4 color:hint_color;

//varying float foo;
varying mat3 rotatecolor;

// doing matrix calculations in the vertex instead of each pixel to save compute time
void vertex(){
//	foo = sin(TIME) / 2.0 + 0.5;
	// adapted from https://stackoverflow.com/questions/8507885/shift-hue-of-an-rgb-color
	float myradians = TIME;
//	float myradians = radians(180);
	float sinA = sin(myradians);
	float cosA = cos(myradians);
	float oneminuscosA = 1.0 - cosA;
	float onethird = 1.0 / 3.0;
	float sqrtthird = sqrt(onethird);
	rotatecolor[0][0] = cosA + oneminuscosA / 3.0;
	rotatecolor[0][1] = onethird * oneminuscosA - sqrtthird * sinA;
	rotatecolor[0][2] = onethird * oneminuscosA + sqrtthird * sinA;
	rotatecolor[1][0] = onethird * oneminuscosA + sqrtthird * sinA;
	rotatecolor[1][1] = cosA + onethird * oneminuscosA;
	rotatecolor[1][2] = onethird * oneminuscosA - sqrtthird * sinA;
	rotatecolor[2][0] = onethird * oneminuscosA - sqrtthird * sinA;
	rotatecolor[2][1] = onethird * oneminuscosA + sqrtthird * sinA;
	rotatecolor[2][2] = cosA + onethird * oneminuscosA;
}

void fragment(){
	vec4 mycolor = texture(TEXTURE, UV);
	// Keying on alpha == 0.1, but really it seems to be about 0.1016
	if (abs(mycolor.a - 0.1) < 0.002) {
		// COLOR = vec4(foo, mycolor.g, mycolor.b, 1.0);
		COLOR = vec4(
			clamp(mycolor.r * rotatecolor[0][0] + mycolor.g * rotatecolor[0][1] + mycolor.b * rotatecolor[0][2], 0.0, 1.0),
			clamp(mycolor.r * rotatecolor[1][0] + mycolor.g * rotatecolor[1][1] + mycolor.b * rotatecolor[1][2], 0.0, 1.0),
			clamp(mycolor.r * rotatecolor[2][0] + mycolor.g * rotatecolor[2][1] + mycolor.b * rotatecolor[2][2], 0.0, 1.0),
			1.0
		);
	} else {
		COLOR = mycolor;
	}
}
