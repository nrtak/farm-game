shader_type canvas_item;
// Blend the portrait sheet's neutral paper into the dialogue parchment.
// This is a display treatment: source artwork and pale character details stay intact.
void fragment() {
 vec4 color = texture(TEXTURE, UV);
 float neutral = 1.0 - smoothstep(0.08, 0.20, max(color.r,max(color.g,color.b))-min(color.r,min(color.g,color.b)));
 float paper = smoothstep(0.80, 0.88, min(color.r,min(color.g,color.b))) * neutral;
 COLOR = vec4(mix(color.rgb, vec3(0.953, 0.894, 0.737), paper), color.a);
}
