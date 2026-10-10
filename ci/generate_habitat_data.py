from pathlib import Path
import json,base64,struct
from PIL import Image
root=Path(__file__).resolve().parents[1]; result={}
lut=[struct.unpack('<f',struct.pack('<f',i/255.0))[0] for i in range(256)]
for kind,path in [('farm','farm-environment-v10-wide.png')]+[(k,'map-'+k+'-approved-v1.png') for k in ['town','harbor','mountain','historic','tea']]:
 path={'map-town-approved-v1.png':'map-town-open-v3.png','map-mountain-approved-v1.png':'map-mountain-open-v2.png','map-harbor-approved-v1.png':'map-harbor-open-v2.png','map-tea-approved-v1.png':'map-tea-open-v2.png'}.get(path,path)
 im=Image.open(root/'assets'/path).convert('RGB');w,h=im.size
 bits={key:bytearray((w*h+7)//8) for key in ['path','grass','water']}
 for i,(red,green,blue) in enumerate(im.getdata()):
  r,g,b=lut[red],lut[green],lut[blue]
  for key,valid in [('path',r>.55 and g>.45 and r>g*.97),('grass',r>.4 and g>.52 and g>r*1.12 and g>b*1.2),('water',b>.3 and b>r*1.2 and b>g*1.12)]:
   if valid:bits[key][i>>3]|=1<<(i&7)
 result[kind]={'width':w,'height':h,**{k:base64.b64encode(v).decode() for k,v in bits.items()}}
(root/'data/map_habitats.json').write_text(json.dumps(result,separators=(',',':')))
print('Saved map classifications without changing artwork:',len(result), 'regions')
