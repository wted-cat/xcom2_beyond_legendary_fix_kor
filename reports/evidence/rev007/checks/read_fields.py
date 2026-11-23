from pathlib import Path
from collections import Counter,defaultdict
import re,json,sys
def events(path):
 b=path.read_bytes()
 txt=b.decode('utf-16' if b[:2] in (b'\xff\xfe',b'\xfe\xff') else 'utf8','replace')
 meta={};groups=[];case=None
 for line in txt.splitlines():
  m=re.search(r'ScriptLog: (R[67]\|.+)$',line)
  if not m:continue
  a=m.group(1).split('|');t=a[1]
  if t=='CASE':case=int(a[3])
  elif t=='WORLD':case=int(a[2])
  if t=='SPAWN':meta[a[4]]=a[2]
  yield case,t,a
def inspect(f):
 cases={};nows={};overall=Counter()
 for c,t,a in events(f):
  u=cases.setdefault(c,{'world':[],'actors':{},'actions':[],'nodes':[],'before':[],'target':[],'special':[],'scope':[],'shot':[],'end':[]})
  overall[t]+=1
  if t=='WORLD':u['world'].append(a[2:])
  if t=='ACTOR':u['actors'][a[4]]=[a[5],a[7],a[8].split(',')]
  if t=='ACT' and a[3]!='0':u['actions'].append([a[2],a[3],a[6],a[7],a[8],a[9],a[10],a[-1]])
  if t=='NODE':
   v=[a[4],a[3],a[5],a[6]]
   if v not in u['nodes']:u['nodes'].append(v)
  if t in ('BEFORE','SHOT','TARGET','SCOPED'):
   key={'BEFORE':'before','SHOT':'shot','TARGET':'target','SCOPED':'scope'}[t];v=a[2:]
   if v not in u[key]:u[key].append(v)
  if t in ('CASEFINISHED','FINISHED','MISSIONEND'):u['end'].append([t]+a[2:])
  if t in ('COVER','RUSHNEXT','BOUNDSTATE','RANGED','NORANGED','PLACED','GRIDFAILED','ROLE','PODROLES','VIPSTEP','FIELDROOT','EVAC','OBJVIP','VIPOBJECTIVE','XCOMFLUSH','BINDVISIBLE','MERCYEND','BURROWRESULT','REVEAL'):
   v=[t]+a[2:]
   if v not in u['special']:u['special'].append(v)
 return cases,overall
if __name__=='__main__':
 for arg in sys.argv[1:]:
  f=Path(arg);cases,n=inspect(f);print(f.stem)
  for c,q in cases.items():
   actions=[v[4]for v in q['actions']]
   print(c,len(q['nodes']),dict(Counter(actions)),q['end'][-1:] if q['end'] else [])
