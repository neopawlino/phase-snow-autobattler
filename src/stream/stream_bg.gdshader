shader_type canvas_item;

const mat4 bayerIndex = mat4(
    vec4(00.0/16.0, 12.0/16.0, 03.0/16.0, 15.0/16.0),
    vec4(08.0/16.0, 04.0/16.0, 11.0/16.0, 07.0/16.0),
    vec4(02.0/16.0, 14.0/16.0, 01.0/16.0, 13.0/16.0),
    vec4(10.0/16.0, 06.0/16.0, 09.0/16.0, 05.0/16.0));

void vertex() {
	// Called for every vertex the material is visible on.
}

float checker(vec2 coord) {
	return mod(coord.x + coord.y, 1.0);
}

void fragment() {
	const float SIZE = 8.0;
	
	
	vec3 color1 = vec3(0.28, 0.85, 1);
	vec3 color2 = vec3(0.75f, 0.49f, 0.82f);
	
	vec2 uv = SCREEN_UV;
	
	
	float pxAmt = 20.0;
    
	vec2 pixelFragcoord = floor(FRAGCOORD.xy * pxAmt) / pxAmt;
	
    float bayerValue = bayerIndex[int(pixelFragcoord.x) % 4][int(pixelFragcoord.y) % 4];
  
	vec3 col = mix(color1, color2, smoothstep(.25, .75, uv.y));
	//col += (bayerValue - 0.5)/SIZE*2.0;
	//col = (floor(col*SIZE)+0.5)/SIZE;

    // Output to screen
    COLOR = vec4(col,1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
