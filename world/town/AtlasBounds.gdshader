shader_type canvas_item;
uniform int clipping_shape = 0;
void fragment(){
 vec2 p=UV*vec2(textureSize(TEXTURE,0));
 // Explicit atlas boundaries exclude the neighboring sprite's tower/roof tips.
 if(clipping_shape==1 && p.x>1100.0 && p.y>620.0) discard;
 if(clipping_shape==2 && p.x>610.0 && p.y>620.0) discard;
 if(clipping_shape==3 && p.x<1080.0 && p.y<680.0) discard;

}
