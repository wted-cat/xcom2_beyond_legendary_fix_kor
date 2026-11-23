from pathlib import Path
from collections import Counter,defaultdict
import json,re,sys
A=Path(__file__).resolve().parent;P='CoarseEnemyAIAndEncounters'
V=A/'Baseline'/P
if __name__=="__main__" and len(sys.argv)>2:V=Path(sys.argv[2])
def text(p):
 b=p.read_bytes()
 return b.decode('utf-16' if b[:2] in (b'\xff\xfe',b'\xfe\xff') else 'utf-8-sig','replace').replace('\r','')
def atom(s):
 s=s.strip().strip('"').strip()
 if re.fullmatch(r'-?\d+(\.\d+)?',s):return float(s)
 return s.casefold()
def unstruct(s):
 s=s.strip()
 if s.startswith('('):s=s[1:-1]
 m={};pieces=[];q=False;level=0;start=0
 for i,c in enumerate(s):
  if c=='"':q=not q
  if q:continue
  if c=='(':level+=1
  elif c==')':level-=1
  elif c==',' and level==0:pieces.append(s[start:i]);start=i+1
 pieces.append(s[start:])
 for it in pieces:
  if '=' not in it:continue
  k,v=it.split('=',1);k=k.strip().lower();v=v.strip()
  m[k]=unstruct(v) if v.startswith('(') else atom(v)
 return m
def arr(m,k):
 pairs=[(int(i),v)for key,v in m.items()for i in re.findall('^'+k+r'\[(\d+)\]$',key)]
 return [v for i,v in sorted(pairs)]
def loaddecl():
 out=defaultdict(list)
 for f in (V/'Config').glob('*.ini'):
  if f.stem not in ['XComEncounterLists','XComSchedules','XComEncounters','XComLW_Overhaul','XComMissionDefs']:continue
  raw=re.sub(r'\\+\s*\n\s*',' ',text(f))
  for l in raw.splitlines():
   if not l.startswith('+') or '=('+'' not in l:continue
   k,v=l[1:].split('=',1)
   if k.lower() not in ('configurableencounters','encounterbuckets','replacementencounterbuckets','missionschedules','spawndistributionlists','arrmissions'):continue
   end=v.rfind(')');out[k.lower()].append(unstruct(v[:end+1]))
 return out
def collect(path):
 out=defaultdict(list)
 for l in text(path).splitlines():
  if 'ScriptLog: R7|' in l:
   a=l.split('ScriptLog: R7|',1)[1].strip().split('|');out[a[0]].append(a[1:])
 return out
def words(s):return [x.casefold()for x in s.split(',')if x]
def tablecheck(log):
 real=collect(log);assert real['TABLEEND'],'missing end of table dump'
 expected=loaddecl()
 removals={(k.casefold(),a.casefold()) for a,k in re.findall(r'Removing nonexistant unit (\w+) From encounter list (\w+)',text(log),re.I)}
 protected={'etp_original_terrorleaders':'terrorleaders_lw','etp_original_defaultleaders_lw':'defaultleaders_lw','etp_original_adventleaders_lw':'adventleaders_lw'}
 omega={}
 for dst,src in protected.items():
  def omega_rows(key):
   return Counter(v for _,k,ls in real['LIST']if k.lower()==key for v in words(ls)if v.startswith('berserkeromega:'))
  left=omega_rows(src);right=omega_rows(dst);omega[dst]=[dict(left),dict(right),left==right]
 mismatch=defaultdict(list);counts={};verified={};slots={};dr=defaultdict(list)
 for typ,tag,idf in [('configurableencounters','ENC','encounterid'),('encounterbuckets','BUCKET','encounterbucketid'),('spawndistributionlists','LIST','listid'),('missionschedules','SCHED','scheduleid')]:
  by=defaultdict(list)
  for a in real[tag]:by[a[1].casefold()].append(a[2:])
  decl=expected[typ];counts[tag]=[len(decl),len({x[idf]for x in decl})];good=0;ss=0
  for row in decl:
   key=row[idf]
   if typ in ('configurableencounters','missionschedules') and row.get('maxrequiredforcelevel',0)>=20:row['maxrequiredforcelevel']=99
   if typ=='spawndistributionlists':
    for e in arr(row,'spawndistribution'):
     if e.get('maxforcelevel')==20:e['maxforcelevel']=99
   if typ=='configurableencounters':
    fs=arr(row,'forcespawntemplatenames');ss+=len(fs)
    def match(x):return all(row[k]==atom(v)for k,v in zip(['maxspawncount','minrequiredforcelevel','maxrequiredforcelevel','minrequiredalertlevel','maxrequiredalertlevel','encounterleaderspawnlist','encounterfollowerspawnlist'],x[:7])if k in row) and fs==[v.split(':')[0]for v in words(x[7])]
   elif typ=='encounterbuckets':
    ar=arr(row,'encounterids');ss+=len(ar);w=[(v['encounterid'],v.get('includetacticaltag','none'),v.get('excludetacticaltag','none'))for v in ar]
    def match(x):return ('randomizedselection' not in row or row['randomizedselection']==atom(x[0])) and w==[tuple(v.split(':'))for v in words(x[1])]
   elif typ=='spawndistributionlists':
    rawar=arr(row,'spawndistribution');ss+=len(rawar);ar=[x for x in rawar if (key,x['template']) not in removals]
    def match(x):
     a=words(x[0])
     if key in protected and len(a)>len(ar) and all(v.startswith('berserkeromega:') for v in a[len(ar):]) and omega[key][-1]:a=a[:len(ar)]
     return len(a)==len(ar) and all(all(atom(v)==e[k] for k,v in zip(['template','minforcelevel','maxforcelevel','maxcharacterspergroup','spawnweight'],s.split(':')) if k in e)for e,s in zip(ar,a))
   else:
    ar=arr(row,'preplacedencounters');ss+=len(ar);w=[v.get('encounterid','none')for v in ar]
    def match(x):return all(row[k]==atom(v)for k,v in zip(['minrequiredforcelevel','maxrequiredforcelevel','minrequiredalertlevel','maxrequiredalertlevel','includetacticaltag','excludetacticaltag'],x[:6])if k in row) and w+['opnx2_standard','opnx2_standard','opnx3_standard','opnx3_standard','opnx4_standard','arfm_overwhelmdoctrine']==words(x[6])
   pick=next((i for i,x in enumerate(by[key]) if match(x)),None)
   if pick is not None:
    good+=1;by[key].pop(pick)
   else:mismatch[tag].append(key)
  verified[tag]=good;slots[tag]=ss
 touched={v['scheduleid']for v in expected['missionschedules']};encnames={a[1].lower()for a in real['ENC']};buckets={a[1].lower()for a in real['BUCKET']};snames={a[1].lower()for a in real['SCHED']};ml={a[0]:words(a[2])for a in real['MISSION']}
 selected={v for ids in ml.values() for v in ids}
 wrongbound=[];nb=0
 for a in real['BOUND']:
  if a[0].lower() not in touched:continue
  nb+=1;found=[atom(v)for v in a[2:]];want=[atom(a[1])]*2+['false']*5
  if found!=want:wrongbound.append(a)
 references=[(a[1],s)for a in real['SCHED'] if a[1].lower() in touched for s in words(a[-1]) if s not in encnames|buckets]
 missingmission=[(m,s)for m,ids in ml.items()for s in ids if s not in snames]
 for b,fl,al,s in real['DRAW']:dr[b].append(s)
 portals={b:dict(Counter(ids))for b,ids in dr.items() if 'finalshowdown' in b.lower()}
 out={'game_counts':real['TABLEEND'][-1],'declared':counts,'matches':verified,'omega_source_protected':omega,'slots':slots,'mismatches':{t:dict(Counter(v)) for t,v in mismatch.items()},'bounds_checked':nb*7,'failed_bounds':wrongbound,'directly_referenced':len(touched & selected),'schedule_dangling':references,'mission_dangling':missingmission,'native_draws':sum(map(len,dr.values())),'draw_buckets':len(dr),'native_draws_blank':{k:dict(Counter(x for x in v if not x or x=='None')) for k,v in dr.items()if any(x in ('','None')for x in v)},'portal_draws':portals}
 return out
if __name__=='__main__':
 f=Path(sys.argv[1]);res=tablecheck(f);out=A/(f.stem+'_schedules.json');out.write_text(json.dumps(res,ensure_ascii=False,indent=1),encoding='utf8')
 for k,v in res.items():
  if k=='portal_draws':v={a:len(b)for a,b in v.items()}
  print(k,str(v)[:1700])
