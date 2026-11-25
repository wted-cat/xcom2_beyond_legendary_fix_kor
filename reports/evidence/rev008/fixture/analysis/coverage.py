from pathlib import Path
from collections import Counter,defaultdict,deque
import re,csv,io,sys,zipfile,json,hashlib
V=Path(__file__).parent
R=V.parent
G=R/'EnemyAI_Fixes_rev001-rev005_GitHub'
L=V/'Logs'
O=V/'Evidence'
O.mkdir(exist_ok=True)
def decode(raw):
 return raw.decode('utf-16' if raw[:2] in (b'\xff\xfe',b'\xfe\xff') else 'utf-8-sig',errors='replace')
def dump(n,d):
 (O/n).write_text(json.dumps(d,ensure_ascii=False,indent=2),encoding='utf-8')
def csvfile(n,cols,rows):
 with (O/n).open('w',encoding='utf-8-sig',newline='') as h:
  w=csv.writer(h);w.writerow(cols);w.writerows(rows)
registry={k:{} for k in ['ABILITY','CHAR','ITEM','STRATEGY','NODEDEF']}
allab=set();summary={};previous={};live={};cases={};source_meta={};nick={}
def rec(table,name,group,w):
 slot=table.setdefault(name.lower(),{}).setdefault(group,[])
 if len(slot)<20 and w not in slot:slot.append(w)
def readold(n,raw,v):
 for l in decode(raw).splitlines():
  m=re.search(r'R([56])\|ACT\|(.+)',l)
  if not m:continue
  a=m[2].split('|')
  if len(a)<10 or not a[0].isdigit():continue
  mode='전투' if a[1]!='0' else '생성'
  rec(previous,a[6],mode,f'{v}/{n}#{a[0]}')
for f in sorted((G/'reports/evidence/rev005').glob('*.txt')):
 if f.stem not in ('BasharBaseline','ChosenBefore'):readold(f.stem,f.read_bytes(),'rev005')
for v in ('rev006','rev007'):
 for ar in (R/'reports/evidence'/v).glob('*.zip'):
  with zipfile.ZipFile(ar) as z:
   for n in z.namelist():
    if (v=='rev007' and n.startswith('logs/') and n.endswith('.log') or v=='rev006' and '/' not in n and n.endswith('.txt')) and 'Before' not in n:
     readold(Path(n).stem,z.read(n),v)
def target(n):return n.lower().startswith(('arfm','tpy'))
for label in sys.argv[1:]:
 f=L/(label+'.log');text=decode(f.read_bytes())
 rows=text.splitlines();case=0;run={};own_lost=set()
 for l in rows:
  if 'R8|LOSTACT|' not in l:continue
  x=l.split('R8|LOSTACT|',1)[1].split('|')
  if len(x)>4 and x[3]=='eTeam_TheLost' and x[2] not in ('0','8','16'):own_lost.add((x[0],x[1]))
  elif len(x)>4 and x[2]==x[3] and x[2] not in ('0','8','16'):own_lost.add((x[0],x[1]))
 path=O/'logs'/(label+'.txt');path.parent.mkdir(exist_ok=True)
 with path.open('w',encoding='utf-8')as excerpt:
  for l in rows:
   match=re.search(r'(R[678]\|.+)',l)
   if not match:continue
   raw=match[1];x=raw.split('|')
   if len(x)<3:continue
   tag,kind=x[:2]
   if tag=='R8' and kind in registry:
    if label!='MatrixBase' or not x[2] in registry[kind]:registry[kind][x[2]]=x[3:]
    continue
   if tag=='R8' and kind=='ABILITYID':allab.add(x[2].lower());continue
   if tag=='R6' and kind=='CASE':
    case=x[3];run[case]={'actors':{},'actions':[],'nodes':[],'observations':[],'finished':False};key=run[case]
   if tag=='R6' and kind=='CASEFINISHED' and x[2] in run:run[x[2]]['finished']=True
   if not case:continue
   key=run[case]
   if tag=='R7' and kind=='ACTOR' and len(x)>=9 and case==x[2]:
    saved=key['actors'].setdefault(x[4],{'unit':x[5],'root':x[7],'abilities':[v.split(':')[0] for v in x[8].split(',') if v]})
    for ab in saved['abilities']:rec(live,ab,'보유',f'{label}/{case}/{x[5]}')
   if tag=='R6' and kind=='ACT' and len(x)>=15:
    fno,roundn,turn,team,aid,who,ability,tar=x[2:10]
    wt=f'{label}/{case}#{fno} {who}'
    own=(team=='16' or (case,fno) in own_lost)
    group='생성' if roundn=='0' else ('적 턴' if own else '턴 외')
    rec(live,ability,group,wt)
    if roundn!='0':key['actions'].append([int(fno),who,ability,tar,team,x[-1],aid,x[10],x[11],x[12],own])
   if tag=='R6' and kind=='NODE' and len(x)>6 and x[-1] in ('BTS_SUCCESS','BTS_FAILURE') and [x[-2],x[-1]] not in key['nodes']:key['nodes'].append([x[-2],x[-1]])
   if tag=='R8' and kind in ('POWERFRAME','VALID','POWER','CACHE','INPUT','PARRY','GATE','NATURALGRANT','EXTRA','TAGS','LANDING','LOSTACT','STUNGEAR'):key['observations'].append(x[1:])
   if (tag=='R8' or (tag=='R7' and kind in ('ACTOR','SCOPED','MISSINGROOT','WITNESS','COVER','BIND','BEFORE','SHOT')) or (tag=='R6' and kind in ('CASE','CASEFINISHED','FINISHED','WORLD','ACT','TARGET','MULTI','XCOMFLUSH','NODE','MISSIONEND'))):
    if kind!='NODE' or x[-1] in ('BTS_SUCCESS','BTS_FAILURE'):excerpt.write(raw+'\n')
 cases[label]=run
 source_meta[label]={'complete':any('R6|FINISHED|' in l for l in rows),'cases':len(run),'game_log_sha256':hashlib.sha256(f.read_bytes()).hexdigest()}
def join(d,k):return '; '.join(d.get(k,[])[:4])
def abb(k):
 a=registry['ABILITY'][k];d=live.get(k.lower(),{});v=previous.get(k.lower(),{});trig=a[3]
 status=next((n for n in ['적 턴','턴 외','생성','보유'] if n in d), '등록')
 if status in ('등록','보유','생성') and '전투' in v:status+=' / 과거 전투'
 return [k,a[0],a[2],trig,a[4],a[5],status,join(d,'적 턴'),join(d,'턴 외'),join(d,'생성'),join(d,'보유'),join(v,'전투'),join(v,'생성')]
abrows=[abb(k) for k in sorted(registry['ABILITY']) if target(k)]
csvfile('abilities.csv',['ID','템플릿 생성 클래스','패시브 표시','발동 방식','후속 이벤트','부여 능력','확인 단계','이번 적 턴','이번 턴 외','이번 유닛 생성','이번 보유 목록','이전 전투','이전 생성'],abrows)
ch=[]
for k,val in sorted(registry['CHAR'].items()):
 if not k.lower().startswith('arfm'):continue
 fields=[];acts=set();roots=set()
 for label,cc in cases.items():
  for n,case in cc.items():
   if any(u['unit']==k for u in case['actors'].values()):
    fields.append(label+'/'+n);roots.update(u['root'] for u in case['actors'].values() if u['unit']==k)
    acts.update(a[2] for a in case['actions'] if a[1]==k and a[-1] is True)
 ch.append([k,*val[:3],'; '.join(fields),'; '.join(sorted(roots)),'; '.join(sorted(acts))])
csvfile('characters.csv',['ID','원래 AI','생성 클래스','기본 장비','전투 배치','시험 시 AI','적 턴에서 기록한 행동'],ch)
for k in ['ITEM','STRATEGY']:
 csvfile(k.lower()+'.csv',['ID','생성 클래스','종류','확인 단계'],[[n,*v,'전술 로드 시 등록'] for n,v in sorted(registry[k].items()) if n.lower().startswith('arfm')])
dct={k.lower():(k,v) for k,v in registry['NODEDEF'].items()}
def graph(root):
 seen=set();missing=set();pending=[root.lower()]
 while pending:
  k=pending.pop()
  if k in seen or k not in dct:continue
  seen.add(k)
  for v in dct[k][1][1].split(','):
   if not v:continue
   if v.lower() not in dct:missing.add(v)
   else:pending.append(v.lower())
 return {'nodes':len(seen),'dynamic_score':sorted(v for v in missing if re.match(r'^(AddTo|Set)\w*Score_-?\d+$',v,re.I)),'other_missing':sorted(v for v in missing if not re.match(r'^(AddTo|Set)\w*Score_-?\d+$',v,re.I))}
roots={v[0] for k,v in registry['CHAR'].items() if k.lower().startswith('arfm') or k in ('AdvRaptorM3','ChosenAssassinM3','ChosenWarlockM3','ChosenSniperM3','AdvPriestM3','SpectreM2')}
roots.update(k for k in registry['NODEDEF'] if re.match(r'(Chosen(Assassin|Warlock|Sniper)(Root|::CharacterRoot)|Assassin::CharacterRoot|Hunter::CharacterRoot|Warlock::CharacterRoot)$',k,re.I))
g={k:graph(k) for k in sorted(roots) if k};dump('roots.json',g)
missing={k:[n for n in v[5].split(',') if n and n.lower() not in allab] for k,v in registry['ABILITY'].items() if target(k)}
dump('unresolved-additional.json',{k:v for k,v in missing.items() if v})
dump('cases.json',cases)
for kind,data in registry.items():summary[kind]={'logged':len(data),'ARFM':sum(k.lower().startswith('arfm')for k in data),'TPY':sum(k.lower().startswith('tpy')for k in data)}
summary['ARFM_ability_status']=dict(Counter(r[6] for r in abrows if r[0].lower().startswith('arfm')))
summary['ARFM_characters_placed']=sum(bool(r[4]) for r in ch);summary['ARFM_characters_hostile_turn_action']=sum(bool(r[-1]) for r in ch)
summary['all_ability_ids']=len(allab);summary['field_runs']=source_meta
dump('coverage.json',summary)
print(json.dumps(summary,ensure_ascii=False)[:3500])
