from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageFont

out=Path(__file__).parent
names=['Hospital','Town Hall','Library','Store','Cafe','Vet','Inn','Police','Fire','Ranch','Carpenter','Blacksmith']
buildings=[(name,1000+(i%3)*350,420+(i//3)*260,230,140,'S') for i,name in enumerate(names)]
roads=[[130,850,1920,80],[1250,280,100,1320],[850,590,1200,80],[850,1110,1200,80],[850,1370,1200,80],[850,590,100,880],[1600,590,100,880],[750,300,100,650],[400,300,450,100]]
aprons=[[x+w/2-45,y+h,90,40] for name,x,y,w,h,side in buildings]
labels=[['SHRINE',500,255],['HARBOR',85,810],['RIVER',230,520],['FARM ↓',1300,1550],['HIGHLANDS ↑',1300,320],['Tea country · Mountains · Mine',1650,100],['Lake & waterfall · Onsen',1650,160],['Shared highlands region',1650,220],['Harbor & shrine district',520,120]]
data={'size':[2400,1600],'buildings':buildings,'roads':roads,'aprons':aprons,'plaza':[300,600,500,500],'fountain':[340,640,55,55],'start':[1300,900],'labels':labels,'water':[[0,0,150,1600],[190,0,80,1600]],'note':'Proposed schematic, not live game. West: harbor and shrine, riverside festival square. Northeast: tea country, mountains, lake/waterfall, mine and existing onsen. Compact town grid. Map transitions must be updated together during integration.'}
(out/'layout.json').write_text(json.dumps(data,indent=2),encoding='utf-8')
im=Image.new('RGB',(1600,1240),'#f6f3e9');d=ImageDraw.Draw(im)
font=lambda n: ImageFont.truetype('C:/Windows/Fonts/arial.ttf',n)
d.text((60,30),'TEA BLOSSOM HILLS / TOWN SCHEMATIC 02',font=font(32),fill='#273d39')
d.text((60,76),'Compact town · Riverside festival square · Two grouped destination regions',font=font(23),fill='#52645d')
s=.6;ox=80;oy=150
def rect(r,color,outline=None):
 x,y,w,h=r;d.rectangle((ox+x*s,oy+y*s,ox+(x+w)*s,oy+(y+h)*s),fill=color,outline=outline,width=2)
rect([0,0,2400,1600],'#dce6cc')
for r in data['water']:rect(r,'#a8d5df')
rect([990,30,1140,220],'#c4d6b4','#829b71')
for r in roads+aprons:rect(r,'#e9d2a5')
rect(data['plaza'],'#d7d6cc')
for r in roads[0:2]:rect(r,'#eadfbe')
for name,x,y,w,h,side in buildings:
 rect([x,y,w,h],'#b4c8bd','#536f63')
 d.text((ox+(x+w/2)*s,oy+(y+h/2)*s),name,font=font(19),fill='#253d34',anchor='mm')
 door={'S':(x+w/2,y+h),'N':(x+w/2,y),'E':(x+w,y+h/2),'W':(x,y+h/2)}[side]
 dx,dy=door;rect([dx-13,dy-13,26,26],'#bf714a')
rect(data['fountain'],'#8dbec9','#487d89')
d.text((ox+550*s,oy+1030*s),'FESTIVAL SQUARE',anchor='mm',font=font(22),fill='#566458')
for label,x,y in labels:
 d.text((ox+x*s,oy+y*s),label,font=font(18),fill='#294d4a',anchor='mm')
px,py=data['start'];d.ellipse((ox+px*s-9,oy+py*s-9,ox+px*s+9,oy+py*s+9),fill='#d4783a',outline='white',width=2)
d.text((60,1134),'Tan = streets & door approaches     Gray = plaza     Green = buildings     Orange = doors / player',font=font(21),fill='#3d554b')
d.text((60,1175),'Prototype: walking space first. Final angled artwork, scenery, NPC positions and live-game integration follow.',font=font(21),fill='#3d554b')
im.save(out/'town-schematic.png')
template=(out/'preview-template.html').read_text(encoding='utf-8')
(out/'preview.html').write_text(template.replace('__LAYOUT__',json.dumps(data)),encoding='utf-8')
print('Created schematic image, shared layout data, and interactive preview')
