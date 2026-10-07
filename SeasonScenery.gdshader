shader_type canvas_item;
uniform float season = 0.0;
void fragment() {
	vec4 original = texture(TEXTURE, UV) * COLOR;
	vec3 c = original.rgb;
	float green = smoothstep(0.015,0.12,c.g-c.r) * smoothstep(0.015,0.12,c.g-c.b);
	float brightness = dot(c,vec3(0.299,0.587,0.114));
	float water = smoothstep(0.05,0.18,c.b-c.r);
	if (season < 0.5) c = mix(c,c*vec3(1.02,1.035,0.98),green*0.65);
	else if (season < 1.5) c = mix(c,c*vec3(0.96,1.01,0.93),green*0.65);
	else if (season < 2.5) {
		vec3 autumn = vec3(brightness*1.3,brightness*0.84,brightness*0.46);
		c = mix(c,autumn,green*0.78);
	} else {
		float exposed = smoothstep(0.22,0.55,brightness);
		float snow = max(green*0.86,exposed*0.28)*(1.0-water);
		c = mix(c,vec3(0.90,0.94,0.94),snow);
	}
	COLOR = vec4(c,original.a);
}
