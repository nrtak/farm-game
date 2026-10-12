"""Original procedural score for Tea Blossom Hills. No external samples or melodies.
Run with Python and numpy to rebuild the committed PCM audio assets.
"""
from pathlib import Path
import json, wave
import numpy as np
ROOT=Path(__file__).resolve().parents[1]/'assets'/'audio'
SR=22050
rng=np.random.default_rng(10411)
def tone(midi,duration,voice='pluck'):
 t=np.arange(int(SR*duration))/SR;hz=440*2**((midi-69)/12);phase=2*np.pi*hz*t
 if voice=='flute':
  env=np.minimum(t/.09,1)*np.minimum((duration-t)/.13,1)
  y=np.sin(phase+.018*np.sin(2*np.pi*4.1*t))+.10*np.sin(phase*2)
 elif voice=='bell':
  env=(1-np.exp(-t*130))*np.exp(-t*2.7)
  y=np.sin(phase)+.2*np.sin(phase*2)+.08*np.sin(phase*3)
 else:
  env=(1-np.exp(-t*180))*np.exp(-t*(3.5 if voice=='pluck' else 1.8))
  y=np.sin(phase)+.28*np.sin(2*phase)+.09*np.sin(3*phase)
 return y*env*.45
def add(out,sound,at,gain):
 start=int(at*SR)%len(out);indices=(start+np.arange(len(sound)))%len(out);np.add.at(out,indices,sound*gain)
def write(name,out):
 peak=float(np.max(np.abs(out)));out=out*(.65/max(.65,peak))
 # Five millisecond boundary ramps prevent clicks in short effects and ambience.
 n=min(110,len(out)//2);out[:n]*=np.linspace(0,1,n);out[-n:]*=np.linspace(1,0,n)
 path=ROOT/(name+'.wav')
 with wave.open(str(path),'wb') as w:
  w.setnchannels(1);w.setsampwidth(2);w.setframerate(SR);w.writeframes((out*32767).astype('<i2').tobytes())
 return {'file':path.name,'seconds':round(len(out)/SR,2),'peak':round(float(np.max(np.abs(out))),4)}
# Each four-bar original phrase is answered by a second phrase, then varied once.
SCORES={
 'farm':(112,'flute',[[72,76,79,76],[74,77,81,79],[76,79,81,76],[74,71,67,72]]),
 'town':(120,'pluck',[[76,79,72,74],[77,81,79,77],[81,79,76,72],[74,79,71,72]]),
 'nature':(104,'flute',[[79,76,74,72],[77,74,72,69],[76,72,69,72],[74,71,67,71]]),
 'interior':(100,'piano',[[72,67,76,72],[69,72,77,74],[69,76,72,69],[71,74,67,72]]),
 'night':(84,'bell',[[76,72,67,72],[77,72,69,72],[76,72,69,64],[74,71,67,72]]),
 'rain':(96,'piano',[[72,76,74,67],[69,72,74,77],[76,72,69,64],[67,71,74,72]]),
 'falls':(84,'bell',[[84,79,76,79],[81,77,72,77],[81,76,72,76],[79,74,71,72]])}
ROOT.mkdir(exist_ok=True,parents=True);records=[]
for track_index,(name,(bpm,voice,phrase)) in enumerate(SCORES.items()):
 beat=60/bpm;out=np.zeros(round(64*beat*SR))
 percussion_rng=np.random.default_rng(10411+track_index)
 gentle=name in ['night','falls']
 for bar in range(16):
  root=[48,53,57,55][bar%4];third=3 if bar%4==2 else 4
  chord=[root,root+third,root+7,root+12]
  # Alternating bass and short offbeat chords give the daytime themes a bounce.
  for offset,note in [(0,root-12),(2,root-5)]:
   add(out,tone(note,beat*.85,'pluck'),(bar*4+offset)*beat,.20)
  for i,note in enumerate(chord):
   add(out,tone(note,beat*.65,'pluck'),(bar*4+i+.5)*beat,.14)
  if not gentle:
   for offset in [1.5,3.5]:
    for note in chord[1:3]:
     add(out,tone(note+12,beat*.35,'pluck'),(bar*4+offset)*beat,.065)
  for i,note in enumerate(phrase[bar%4]):
   if bar%4==3 and i==3: continue
   if gentle and i%2==1: continue
   if bar>=8 and i==2: note+=12 if name=='town' else -12
   add(out,tone(note,beat*.68,voice),(bar*4+i+.08)*beat,.27)
   # A light eighth-note answer adds movement without crowding the melody.
   if not gentle and bar%2==0 and i==2:
    add(out,tone(phrase[bar%4][3],beat*.34,'pluck'),(bar*4+i+.65)*beat,.13)
  for offset in ([1,3] if gentle else [0,.5,1,1.5,2,2.5,3,3.5]):
   t=np.arange(int(.055*SR))/SR
   noise=percussion_rng.normal(0,.10,len(t))
   brush=(noise-np.roll(noise,1))*np.exp(-t*75)*(1-np.exp(-t*1200))
   add(out,brush,(bar*4+offset)*beat,.035 if gentle else .075)
 record=write('music-'+name,out);record['bpm']=bpm;records.append(record)
# Preserve the original effects/ambience noise sequence independently of the score.
rng.normal(0,.10,32*int(.075*SR))
for name,notes in {'wake':[72,76,79,84],'sleep':[79,76,72],'purchase':[76,79],'save':[72,79],'door':[55,62]}.items():
 out=np.zeros(int(SR*(len(notes)*.17+.7)))
 for i,note in enumerate(notes): add(out,tone(note,.55,'bell' if name!='door' else 'pluck'),i*.17,.45)
 records.append(write('sfx-'+name,out))
t=np.arange(int(.10*SR))/SR
records.append(write('sfx-step',rng.normal(0,.08,len(t))*np.exp(-t*50)+np.sin(t*2*np.pi*130)*np.exp(-t*60)*.08))
# Soft filtered rain, wind and night insects; loops are baked, not synthesized at runtime.
for name in ['rain','nature','night']:
 out=np.zeros(SR*8);t=np.arange(len(out))/SR
 if name=='rain': out=np.convolve(rng.normal(0,.16,len(out)),np.ones(6)/6,mode='same')
 elif name=='nature':
  out=np.convolve(rng.normal(0,.05,len(out)),np.ones(30)/30,mode='same')
  for at in [1.2,1.48,5.0,5.28]:
   q=np.arange(int(SR*.12))/SR
   add(out,np.sin(2*np.pi*(1800*q+1600*q*q))*np.sin(np.pi*q/.12)**2,at,.025)
 else: out=np.sin(2*np.pi*2800*t)*np.maximum(0,np.sin(2*np.pi*1.5*t))**10*.015
 records.append(write('ambience-'+name,out))
(ROOT/'score-manifest.json').write_text(json.dumps({'author':'Original procedural composition created for Tea Blossom Hills','sample_rate':SR,'channels':1,'tracks':records},indent=2),encoding='utf-8')
print('Generated',len(records),'original audio assets;',round(sum((ROOT/r['file']).stat().st_size for r in records)/1048576,2),'MiB')
