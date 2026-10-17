from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageFont

out=Path(__file__).parent
slots=[('Town Hall',0,0),('Library',1,0),('Police',2,0),('Fire',3,0),('Hospital',0,1),('Store',2,1),('Cafe',3,1),('Inn',0,2),('Restaurant',1,2),('Carpenter',2,2),('Blacksmith',3,2),('Ranch',0,3),('Vet',1,3)]
buildings=[(name,1050+col*290,420+row*280,210,130,'S') for name,col,row in slots]
roads=[[150,860,2060,100],[1260,280,80,1320],[950,580,1260,100],[950,1140,1260,100],[950,1420,680,100],[950,580,80,940],[1550,580,80,940],[1840,580,80,660],[310,370,100,590]]
aprons=[[x+w/2-40,y+h,80,30] for name,x,y,w,h,side in buildings]
labels=[['SHRINE',360,320],['HARBOR',270,1070],['RIVER',840,390],['FARM ↓',1300,1570],['HIGHLANDS ↑',1300,320],['Tea country · Mountains · Mine',1650,100],['Lake & waterfall · Onsen',1650,160],['Shared highlands region',1650,220],['Coastal district',320,120]]
data={'size':[2400,1600],'buildings':buildings,'roads':roads,'aprons':aprons,'plaza':[620,580,380,380],'fountain':[655,620,50,50],'start':[1300,900],'labels':labels,'water':[[0,0,150,1600]],'river':[[720,0],[720,340],[780,490],[920,490],[1020,330],[1020,0]],'river_width':60,'groups':{'Civic':['Town Hall','Library','Hospital'],'Safety':['Police','Fire'],'Market':['Store','Cafe'],'Hospitality':['Inn','Restaurant'],'Crafts':['Carpenter','Blacksmith'],'Animals':['Ranch','Vet']},'note':'Proposed schematic only. Thirteen buildings including new restaurant beside inn. River bends immediately north of Festival Square at its southernmost point, then runs through the western highlands. No river beside the harbor or south of the square. Live maps unchanged.'}
(out/'layout.json').write_text(json.dumps(data,indent=2),encoding='utf-8')
im=Image.new('RGB',(1600,1240),'#f6f3e9');d=ImageDraw.Draw(im)
font=lambda n: ImageFont.truetype('C:/Windows/Fonts/arial.ttf',n)
d.text((60,30),'TEA BLOSSOM HILLS / TOWN SCHEMATIC 04',font=font(32),fill='#273d39')
d.text((60,76),'Related buildings together · New restaurant · Inland river & riverside festival square',font=font(23),fill='#52645d')
s=.6;ox=80;oy=150
def rect(r,color,outline=None):
 x,y,w,h=r;d.rectangle((ox+x*s,oy+y*s,ox+(x+w)*s,oy+(y+h)*s),fill=color,outline=outline,width=2)
rect([0,0,2400,1600],'#dce6cc')
for r in data['water']:rect(r,'#a8d5df')
rect([580,30,1550,220],'#c4d6b4','#829b71')
river_points=[(ox+x*s,oy+y*s) for x,y in data['river']]
d.line(river_points,fill='#a8d5df',width=int(data['river_width']*s),joint='curve')
for x,y in river_points:
 r=data['river_width']*s/2;d.ellipse((x-r,y-r,x+r,y+r),fill='#a8d5df')
for r in roads+aprons:rect(r,'#e9d2a5')
rect(data['plaza'],'#d7d6cc')
for r in roads[0:2]:rect(r,'#eadfbe')
for name,x,y,w,h,side in buildings:
 rect([x,y,w,h],'#b4c8bd','#536f63')
 d.text((ox+(x+w/2)*s,oy+(y+h/2)*s),name,font=font(19),fill='#253d34',anchor='mm')
 door={'S':(x+w/2,y+h),'N':(x+w/2,y),'E':(x+w,y+h/2),'W':(x,y+h/2)}[side]
 dx,dy=door;rect([dx-13,dy-13,26,26],'#bf714a')
rect(data['fountain'],'#8dbec9','#487d89')
d.text((ox+810*s,oy+790*s),'FESTIVAL SQUARE',anchor='mm',font=font(18),fill='#566458')
for label,x,y in labels:
 d.text((ox+x*s,oy+y*s),label,font=font(18),fill='#294d4a',anchor='mm')
px,py=data['start'];d.ellipse((ox+px*s-9,oy+py*s-9,ox+px*s+9,oy+py*s+9),fill='#d4783a',outline='white',width=2)
d.text((60,1134),'Tan = streets & door approaches     Gray = plaza     Green = buildings     Orange = doors / player',font=font(21),fill='#3d554b')
d.text((60,1175),'Prototype: walking space first. Final angled artwork, scenery, NPC positions and live-game integration follow.',font=font(21),fill='#3d554b')
im.save(out/'town-schematic.png')
template=(out/'preview-template.html').read_text(encoding='utf-8')
(out/'preview.html').write_text(template.replace('__LAYOUT__',json.dumps(data)),encoding='utf-8')
print('Created schematic image, shared layout data, and interactive preview')
