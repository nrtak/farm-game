from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageFont

out=Path(__file__).parent
buildings=[
 ('Hospital',400,250,260,200,'S'),('Town Hall',780,220,280,230,'S'),
 ('Library',1400,250,260,200,'S'),('Vet',1780,250,260,200,'S'),
 ('Store',400,620,280,170,'E'),('Cafe',400,1010,280,170,'E'),
 ('Blacksmith',1720,620,300,170,'W'),('Carpenter',1720,1010,300,170,'W'),
 ('Ranch',400,1370,260,170,'N'),('Inn',780,1370,280,170,'N'),
 ('Police',1400,1370,260,170,'N'),('Fire',1780,1370,260,170,'N')]
roads=[[200,850,2200,100],[1100,0,200,1600],[300,470,1800,100],[300,1220,1800,100],[750,470,150,850],[1500,470,150,850],[300,0,100,570]]
aprons=[]
for name,x,y,w,h,side in buildings:
 if side=='S': aprons.append([x+w/2-50,y+h,100,570-y-h])
 elif side=='N': aprons.append([x+w/2-50,1220,100,y-1220])
 elif side=='E': aprons.append([x+w,y+h/2-50,900-x-w,100])
 else: aprons.append([1500,y+h/2-50,x-1500,100])
data={'size':[2400,1600],'buildings':buildings,'roads':roads,'aprons':aprons,'plaza':[900,600,600,600],'fountain':[970,640,65,65],'start':[1200,1100],'note':'Schematic prototype only. Ground coordinates stay orthogonal; angled artwork comes later. Existing game maps unchanged.'}
(out/'layout.json').write_text(json.dumps(data,indent=2),encoding='utf-8')
im=Image.new('RGB',(1600,1240),'#f6f3e9');d=ImageDraw.Draw(im)
font=lambda n: ImageFont.truetype('C:/Windows/Fonts/arial.ttf',n)
d.text((60,30),'TEA BLOSSOM HILLS / TOWN SCHEMATIC 01',font=font(32),fill='#273d39')
d.text((60,76),'Straight streets · Square plaza · Clear door approaches · All 12 buildings retained',font=font(23),fill='#52645d')
s=.6;ox=80;oy=150
def rect(r,color,outline=None):
 x,y,w,h=r;d.rectangle((ox+x*s,oy+y*s,ox+(x+w)*s,oy+(y+h)*s),fill=color,outline=outline,width=2)
rect([0,0,2400,1600],'#dce6cc');rect([0,0,190,1600],'#a8d5df')
for r in roads+aprons:rect(r,'#e9d2a5')
rect(data['plaza'],'#d7d6cc')
for r in roads[0:2]:rect(r,'#eadfbe')
for name,x,y,w,h,side in buildings:
 rect([x,y,w,h],'#b4c8bd','#536f63')
 d.text((ox+(x+w/2)*s,oy+(y+h/2)*s),name,font=font(21),fill='#253d34',anchor='mm')
 door={'S':(x+w/2,y+h),'N':(x+w/2,y),'E':(x+w,y+h/2),'W':(x,y+h/2)}[side]
 dx,dy=door;rect([dx-13,dy-13,26,26],'#bf714a')
rect(data['fountain'],'#8dbec9','#487d89')
d.text((ox+1200*s,oy+780*s),'FESTIVAL SQUARE',anchor='mm',font=font(22),fill='#566458')
for label,x,y in [('MOUNTAINS / LAKE',1200,45),('SHRINE',350,40),('TEA COUNTRY →',2180,895),('← HARBOR',310,895),('FARM ↓',1200,1555)]:
 d.text((ox+x*s,oy+y*s),label,font=font(18),fill='#294d4a',anchor='mm')
px,py=data['start'];d.ellipse((ox+px*s-9,oy+py*s-9,ox+px*s+9,oy+py*s+9),fill='#d4783a',outline='white',width=2)
d.text((60,1134),'Tan = streets & door approaches     Gray = plaza     Green = buildings     Orange = doors / player',font=font(21),fill='#3d554b')
d.text((60,1175),'Prototype: walking space first. Final angled artwork, scenery, NPC positions and live-game integration follow.',font=font(21),fill='#3d554b')
im.save(out/'town-schematic.png')
template=(out/'preview-template.html').read_text(encoding='utf-8')
(out/'preview.html').write_text(template.replace('__LAYOUT__',json.dumps(data)),encoding='utf-8')
print('Created schematic image, shared layout data, and interactive preview')
