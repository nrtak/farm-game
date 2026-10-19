"""Original seasonal chamber-folk sketches; no source music or samples reused."""
from pathlib import Path
import json, wave
import numpy as np

ROOT = Path(__file__).resolve().parents[1] / 'assets/audio'
SR = 22050
# Eight independently written phrases, with rests and longer answering notes.
SCORES = {
 'spring': (98, [48,53,50,55,52,57,53,55], [[60,64,62,67],[65,64,60,57],[62,65,64,60],[59,62,67,62],[64,67,64,59],[60,64,69,64],[65,62,60,57],[59,62,60,None]]),
 'summer': (108, [43,48,45,50,47,48,50,43], [[59,62,67,64],[60,64,62,60],[57,60,64,62],[62,66,64,57],[59,62,66,62],[64,60,67,64],[66,62,60,57],[59,62,55,None]]),
 'autumn': (86, [45,53,48,55,50,45,53,52], [[57,60,64,60],[57,60,65,64],[60,55,59,60],[62,59,55,None],[57,62,65,62],[60,57,64,60],[57,60,62,60],[59,56,57,None]]),
 'winter': (74, [50,46,53,48,43,46,45,50], [[62,None,57,60],[58,62,None,65],[60,None,65,62],[60,55,58,None],[58,None,62,57],[58,53,57,None],[61,None,64,57],[62,57,50,None]])
}

def note(midi, duration, voice):
 t=np.arange(round(duration*SR))/SR
 phase=2*np.pi*440*2**((midi-69)/12)*t
 attack=.055 if voice=='lead' else .025
 envelope=np.minimum(t/attack,1)*np.minimum((duration-t)/.18,1)
 envelope*=np.exp(-t*(1.4 if voice=='guitar' else .42))
 # Fundamental-rich, soft reed/piano color, without piercing bell partials.
 y=(np.sin(phase)+.16*np.sin(phase*2)+.035*np.sin(phase*3))*envelope
 if voice=='bass':y=np.sin(phase)*envelope
 return y

records=[]
for season,(bpm,roots,phrases) in SCORES.items():
 beat=60/bpm;length=round(128*beat*SR);mix=np.zeros((length,2),dtype=np.float64)
 def place(sound,at,gain,pan=0):
  indexes=(round(at*SR)+np.arange(len(sound)))%length
  balance=np.array([np.sqrt((1-pan)/2),np.sqrt((1+pan)/2)])
  for channel in range(2):np.add.at(mix[:,channel],indexes,sound*gain*balance[channel])
 for bar in range(32):
  root=roots[bar%8]
  minor=season in ('autumn','winter') and bar%8 in (0,3,4,5)
  chord=[root,root+(3 if minor else 4),root+7]
  for offset in [0,2]:place(note(root-12,beat*1.8,'bass'),(bar*4+offset)*beat,.095,-.08)
  for index,pitch in enumerate(chord):
   place(note(pitch,beat*2.7,'guitar'),(bar*4+index*.16)*beat,.045,-.32)
   place(note(pitch+12,beat*1.1,'guitar'),(bar*4+2+index*.23)*beat,.022,.35)
  for i,pitch in enumerate(phrases[bar%8]):
   if pitch is None:continue
   if bar//8==2 and i==2:continue
   duration=beat*(1.65 if i==3 or season=='winter' else .87)
   sound=note(pitch,duration,'lead')
   at=(bar*4+i)*beat
   place(sound,at,.095,.12)
   place(sound,at+.17,.012,-.35)
   place(sound,at+.31,.007,.4)
 # Smooth the timbre once more, retaining a clean loop and a natural stereo field.
 kernel=np.hanning(23);kernel/=kernel.sum()
 for channel in range(2):
  pad=np.pad(mix[:,channel],(11,11),mode='wrap')
  mix[:,channel]=np.convolve(pad,kernel,mode='valid')
 peak=float(np.max(np.abs(mix)));mix*=min(1,.55/max(peak,.0001))
 path=ROOT/f'music-{season}.wav'
 with wave.open(str(path),'wb') as stream:
  stream.setnchannels(2);stream.setsampwidth(2);stream.setframerate(SR)
  stream.writeframes((mix*32767).astype('<i2').tobytes())
 records.append({'season':season,'file':path.name,'bpm':bpm,'seconds':round(length/SR,2),'peak':round(float(np.abs(mix).max()),4),'melody_midi_range':[min(n for p in phrases for n in p if n is not None),max(n for p in phrases for n in p if n is not None)]})
(ROOT/'seasonal-score-manifest.json').write_text(json.dumps({'author':'Original compositions for Tea Blossom Hills','source_audio_used':False,'sample_rate':SR,'channels':2,'tracks':records},indent=2),encoding='utf-8')
print(json.dumps(records,indent=2))
