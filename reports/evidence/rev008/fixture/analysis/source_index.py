from pathlib import Path
import re,csv,json
from collections import Counter,defaultdict
V=Path(__file__).parent;O=V/'Evidence'
P='CoarseEnemyAIAndEncounters'
WS=Path(r'C:\Program Files (x86)\Steam\steamapps\workshop\content\268500')
a=json.loads((V/'poison_cards.json').read_text('utf8'))
def read(p):
 b=p.read_bytes();return b.decode('utf-16' if b[:2] in (b'\xff\xfe',b'\xfe\xff') else 'utf-8-sig',errors='replace')
def save(n,cols,lines):
 with (O/n).open('w',encoding='utf-8-sig',newline='') as h:
  w=csv.writer(h);w.writerow(cols);w.writerows(lines)
roots={ '2795578857':WS/'2795578857','CoarseEnemyAIAndEncounters':V/'Baseline'/P,'3512490242':WS/'3512490242','3835619377':WS/'3835619377','3555944655':WS/'3555944655'}
tags={t.lower():i for i,x in enumerate(a) for t in x['tags']}
tags.update({key.lower():i for i,keys in {57:('PYPDroneOverlordsUnlock','ARFMPYP_DroneOverlords'),64:('PYPExecutionUnlock','ARFMPYP_SummaryExecution'),65:('PYPMarkedForDeathUnlock','ARFMPYP_MarkedForDeath')}.items() for key in keys})
refs=defaultdict(set)
for label,root in roots.items():
 files={pp.relative_to(root).as_posix():pp for ext in ('*.uc','*.ini') for pp in root.rglob(ext)}
 if label==P:
  candidate=V/'Candidate'/P
  files.update({pp.relative_to(candidate).as_posix():pp for ext in ('*.uc','*.ini') for pp in candidate.rglob(ext)})
 for rel,pp in sorted(files.items()):
  function=''
  for k,l in enumerate(read(pp).splitlines(),1):
   m=re.search(r'(?i)\b(?:function|event)\s+(?:[a-z]\w*(?:<[^>]+>)?\s+)*?(\w+)\s*\(',l)
   if m:function=m[1]
   for word in set(re.findall(r'\b(?:ARFM\w+|TPY\w+|PYP\w+)\b',l,re.I)):
    if word.lower() in tags:refs[tags[word.lower()]].add(f'{label}/{rel}#{k} {function}')
ret=[]
for i,x in enumerate(a):
 hits=set(refs[i]);g=sorted(y for y in hits if 'ARFM_SE_YearningMutators.uc' not in y)
 ret.append([i,x['card'],x['button'],x['callback'],','.join(x['tags']) or x['callback'],x['min'],x['maximum'] or '', '전술 태그' if x['tags'] else 'XCOM 병사 전술 능력 해금','; '.join(g),'; '.join(sorted(hits-set(g)))])
save('poison-options.csv',['선택 ID','카드 ID','버튼','원본 선택 함수','부여 태그 또는 해금','최소 월','최대 월','저장 방식','소비 코드 및 설정의 참조','원본 선택 함수 참조'],ret)
abil={};char={};nodes={};al=defaultdict(list);teams={}
for label in ['MatrixBase','PoisonOrder','FinalInteractions','RollAfter','CatalogLoot']:
 f=V/'Logs'/(label+'.log')
 if not f.is_file():continue
 for l in read(f).splitlines():
  if 'R8|' not in l:continue
  x=l.split('R8|',1)[1].split('|');k=x[0]
  if k=='ABILITY':abil[x[1]]=x[2:]
  if k=='CHAR':char[x[1]]=x[2:]
  if k=='CHARGROUP':teams[x[1]]=x[2:]
  if k=='NODEDEF':nodes[x[1]]=x[2:]
  if k=='ALIAS':
   for target in x[2].split(','):
    if target and x[1] not in al[target.lower()]:al[target.lower()].append(x[1])
usage=defaultdict(list)
for n,v in char.items():
 for k in v[4].strip(',').split(','):
  if k and n not in usage[k.lower()]:usage[k.lower()].append(n)
out=[]
for n,v in sorted(abil.items()):
 if not n.lower().startswith(('arfm','tpy')):continue
 owners=usage[n.lower()]
 direct=[name for name in nodes if name.lower().endswith('-'+n.lower())]
 active='능력 입력' if 'PlayerInput' in v[3] else ('생성 시 발동' if 'UnitPostBeginPlay' in v[3] else '이벤트 또는 기타')
 out.append([n,v[0],active,v[3],len(owners),';'.join(owners),';'.join(direct),';'.join(al[n.lower()])])
save('ability-routes.csv',['능력','정의 클래스','기본 발동 방식','전체 발동 방식','캐릭터 템플릿 수','직접 부여하는 캐릭터','명시 AI 노드','대체 능력의 일반 키'],out)
print(len(ret),len(out))
