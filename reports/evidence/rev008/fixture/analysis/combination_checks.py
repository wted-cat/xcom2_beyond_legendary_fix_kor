from pathlib import Path
from collections import Counter, defaultdict
from itertools import combinations
import csv,json,sys,hashlib,re
V=Path(__file__).parent
GEM_RUN,POISON_RUN,FORECAST_RUN=(sys.argv[1:4] if len(sys.argv)>=4 else ['ChosenStones','PoisonOrder','FinalPowers'])
O=V/'Evidence'
if len(sys.argv)>4:O=O/sys.argv[4]
O.mkdir(exist_ok=True)
def decode(b):return b.decode('utf-16' if b[:2] in (b'\xff\xfe',b'\xfe\xff') else 'utf-8-sig',errors='replace')
def rows(label):
 if label=='FinalInteractions':
  for sub in ('ExtraRoster','FinalSupplement'):
   if (V/'Logs'/(sub+'.log')).exists():yield from rows(sub)
 f=V/'Logs'/(label+'.log')
 if f.exists():
  for line in decode(f.read_bytes()).splitlines():
   if 'R8|' in line:yield line.split('R8|',1)[1].split('|')
def write(n,d):(O/n).write_text(json.dumps(d,ensure_ascii=False,indent=2),encoding='utf8')
def export(n,headers,rows):
 with (O/n).open('w',encoding='utf-8-sig',newline='')as h:
  w=csv.writer(h);w.writerow(headers);w.writerows(rows)
def counter(s):return Counter(k for k in s.removesuffix("!END!").split(',') if k)
def packed(c):return ','.join(k+(' ×'+str(v) if v>1 else '') for k,v in sorted(c.items()) if v)
src=(V/'Baseline/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/CoarseChosenAscent.uc').read_text('utf8')
pools={g:list(dict.fromkeys(re.findall(r'\b'+g+r'\(\d+\)=(\w+)',src))) for g in ('Capstones','Keystones','Lodestones')}
gemroles=['ChosenAssassinM3','ChosenSniperM3','ChosenWarlockM3']
gather={};gems={};covers=[];turns=defaultdict(list);casts=defaultdict(list);effects=defaultdict(list)
for x in rows(GEM_RUN):
 k=x[0]
 if k=='COMBO':
  i=int(x[1]);role=x[2];vals=x[3:6];expect=[pools['Capstones'][i//72],pools['Keystones'][(i//9)%8],pools['Lodestones'][i%9]]
  ok=vals==expect and x[6:9]==['1,1,1','0','0'] and int(x[9])>3 and int(x[10])!=0
  gather.setdefault((role,i),[]).append([role,i,*vals,x[6],int(x[7]),int(x[8]),int(x[9]),int(x[10]),ok])
 elif k=='GEMWORLD':gems.setdefault(int(x[1]),[]).append(x[2:])
 elif k=='GEMACT':turns[(int(x[1]),x[3])].append(x[2:])
 elif k=='GEMKIT':casts[(int(x[1]),x[2])].append([x[3],int(x[4])])
 elif k=='GEMEFFECT':effects[(int(x[1]),x[2])].append([x[3],int(x[4])])
 elif k=='DEDCOVER':
  sample,role,ability,cover,counts,flags,original,actual,cls=x[1:10];victories,encounters=map(int,counts.split(','))
  exp=0
  if flags=='True,True':
   if ability=='ARFMDedicationPower':exp={'ct_standing':4*victories,'ct_midlevel':8*victories}.get(cover.lower(),0)
   if ability=='ARFMDedicationChange':exp={'ct_midlevel':2*encounters}.get(cover.lower(),0)
  covers.append([sample,role,ability,cover,counts,flags,original,actual,exp,actual==f'{exp},{exp}'])
allcomb=[r for v in gather.values() for r in v]
export('chosen-combinations.csv',['직책','순번','캡스톤','키스톤','로드스톤','세 능력 개수','다른 보석 수','누락한 하위 능력','전체 능력 수','주무기 객체','일치'],sorted(allcomb))
export('dedication-cover.csv',['배치','직책','헌신','표적 엄폐','승리와 교전','측면·엄폐 가능','원본 명중·치명타','적용 명중·치명타','각각의 기대값','일치'],covers)
field=[]
for sample,rolelist in gems.items():
 for rr in rolelist:
  role=next((n for n in gemroles if (n.replace('M3','')==rr[1])),rr[1]+'M3')
  kit=casts[(sample,role)];observed={k for k,v in kit if v>0}
  field.append({'case':sample,'role':role,'traits':rr[3:],'observed_kit':sorted(observed),'missing':sorted(set(rr[3:])-observed),'active_effects':effects[(sample,role)],'actions':turns[(sample,role)]})
write('chosen-battles.json',field)
checks={'expected':1728,'native_records':len(allcomb),'missing':[(r,i)for r in gemroles for i in range(576) if (r,i) not in gather],'duplicates':[(r,i)for (r,i),vs in gather.items() if len(vs)!=1],'failed':[r for r in allcomb if not r[-1]],'cover_rows':len(covers),'cover_failed':[r for r in covers if not r[-1]],'cover_observations':dict(Counter(r[2]+'/'+r[3]+'/'+r[7] for r in covers)),'field_loadouts':len(field),'fully_owned':sum(not r['missing'] for r in field)}
write('chosen-checks.json',checks)
a=json.loads((V/'poison_cards.json').read_text('utf8'))
for entry in a:
 entry['min']=int(entry['min']);entry['maximum']=int(entry['maximum']) if entry['maximum'] else None
allow=lambda i,j: max(a[i]['min']+1,a[j]['min'])<=int(a[j]['maximum']or 1000)
def ordered_window(ids):
 month=-1
 for i in ids:
  month=max(month+1,a[i]['min'])
  if a[i]['maximum'] is not None and month>a[i]['maximum']:return False
 return True
def some_window(ids):
 left=list(ids);month=-1
 while left:
  month=max(month+1,min(a[i]['min'] for i in left))
  i=min((v for v in left if a[v]['min']<=month),key=lambda v:a[v]['maximum'] if a[v]['maximum'] is not None else 10000)
  if a[i]['maximum'] is not None and month>a[i]['maximum']:return False
  left.remove(i)
 return True
legal=sum(x['card']!=y['card'] and allow(i,j) for i,x in enumerate(a) for j,y in enumerate(a));assert legal==23157,legal
truncated=[];aliases=defaultdict(list)
base={};single={};pairs={};multi={};eq={};rules={};groups={};gear_fail=[];effect_sources=defaultdict(list);unlock_mod=[];py_done={};team={};ucases={};special={}
for x in rows(POISON_RUN):
 k=x[0]
 if k in ('PYBASE','PYSINGLE','PYPAIR','PYMULTI') and not x[-1].endswith('!END!'):truncated.append(x[:3])
 if k=='PYEFFECTSRC':effect_sources[int(x[1])].append(x[2:])
 if k=='PYUNLOCKMOD':unlock_mod.append(x[1:])
 if k=='ALIAS':aliases[x[1]].extend(y for y in x[2].split(',') if y)
 if k=='PYRULE':rules[x[1]]=x[2:]
 if k=='CHARGROUP':groups[x[1]]=x[2:]
 if k=='CHILD':special[x[1]]=x[2:]
 if k=='PYDONE':py_done[x[1]]=int(x[2])
 if k=='PYTEAM':team[(x[1],x[2])]=x[3]
 if k=='PYGEARFAIL':gear_fail.append(x[1:])
 if k=='PYBASE':base[(x[1],x[2])]=x[3]
 if k=='PYSINGLE':single[(x[1],x[2],int(x[3]))]=x[4]
 if k=='PYPAIR':pairs[(x[1],x[2],int(x[3]),int(x[4]))]=x[5]
 if k=='PYMULTI':multi[(x[1],x[2],x[3])]=(list(map(int,x[4].strip(',').split(','))),x[5])
 if k=='PYEQUIP':eq[int(x[1])]=x[2:]
checksrows=[];bad=[];solorows=[];multicheck=[]
for (c,u),basetext in base.items():
 b=counter(basetext);opts=[i for cc,uu,i in single if (cc,uu)==(c,u)];ucases[u]=len(opts)
 for i in opts:
  point=counter(single[c,u,i]);solorows.append([c,u,i,a[i]['card'],a[i]['button'],a[i]['callback'],packed(point-b),packed(b-point)])
 for i,j in combinations(sorted(opts),2):
  if a[i]['card']==a[j]['card']:continue
  left=pairs.get((c,u,i,j));right=pairs.get((c,u,j,i));si=counter(single[c,u,i]);sj=counter(single[c,u,j])
  expected=(b - ((b-si)|(b-sj)))+((si-b)|(sj-b));lr=counter(left or '');rr=counter(right or '')
  flags=[left is not None and right is not None,lr==rr,lr==expected,rr==expected,left==right]
  rec=[c,u,i,j,a[i]['callback'],a[j]['callback'],allow(i,j),allow(j,i),*flags,packed(expected-lr),packed(lr-expected),packed(expected-rr),packed(rr-expected)]
  checksrows.append(rec)
  if not all(flags[:4]):bad.append(rec)
 for way in ('0','1'):
  if (c,u,way) not in multi:continue
  opts2,sig=multi[c,u,way];adds=Counter();drops=Counter()
  for i in opts2:
   delta=counter(single[c,u,i]);adds|=delta-b;drops|=b-delta
  exp=(b-drops)+adds;got=counter(sig);other=multi.get((c,u,('0' if way=='1' else '1')))
  multicheck.append([c,u,way,','.join(map(str,opts2)),len(opts2),got==exp,other is not None and counter(other[1])==got,packed(exp-got),packed(got-exp),ordered_window(opts2),some_window(opts2)])
export('poison-singles.csv',['배치','대상','선택','카드','버튼','선택 함수','늘어난 항목','줄어든 항목'],solorows)
export('poison-pairs.csv',['배치','대상','A','B','선택 A','선택 B','A→B 월 가능','B→A 월 가능','양방향 실행','양방향 구성 같음','A→B 기대 일치','B→A 기대 일치','항목 순서 같음','A→B 누락','A→B 초과','B→A 누락','B→A 초과'],checksrows)
export('poison-multi.csv',['배치','대상','방향','선택 ID 순서','선택 수','기대 일치','양방향 구성 일치','누락','초과','실행 순서의 월 조건','다른 순서 포함 캠페인 가능'],multicheck)
write('ai-equivalents.json',aliases);write('poison-rules.json',rules);write('character-groups.json',groups);write('native-score-nodes.json',special)
phys=[]
for i in sorted(k for k in eq if k%2==0):
 if i not in eq or i+1 not in eq:continue
 f,r=eq[i],eq[i+1];stats=f[4].split(',');rs=r[4].split(',')
 phys.append({'cases':[i,i+1],'unit':f[0],'forward_equipment':dict(counter(f[1])),'reverse_equipment':dict(counter(r[1])),'equipment_equal':counter(f[1])==counter(r[1]),'abilities_equal':counter(f[2])==counter(r[2]),'effects_equal':counter(f[3])==counter(r[3]),'ability_delta':[packed(counter(f[2])-counter(r[2])),packed(counter(r[2])-counter(f[2]))],'effect_delta':[packed(counter(f[3])-counter(r[3])),packed(counter(r[3])-counter(f[3]))],'stats':[stats,rs],'tracked_stats_equal':stats==rs,'selected_effect_sources':[[r for r in effect_sources[c] if r[1].lower().startswith(('arfm','tpy'))]for c in (i,i+1)]})
write('poison-field.json',phys)
export('poison-effects.csv',['배치','병종','발생 능력','지속 효과','능력치 변화'],[[c,*r] for c,ls in effect_sources.items() for r in ls])
cards_by_id={57:'Drone',64:'Execution',65:'Marked'}
unlock=[]
for case,choices,stage,flags,aim,damage in unlock_mod:
 picks=[int(i) for i in choices.strip(',').split(',') if i];dis,stun,marked,mc=[v=='True' for v in flags.split(',')]
 # Original effective comments and configuration: either change a cap, or use current damage/420 in their no-cap branch.
 point_aim=int(aim);point_dmg=int(damage)
 exp_aim=(10*int(dis)+50*int(stun)) if 57 in picks else 0
 exp_dmg=(420*int(mc) if 64 in picks else 0)+(10*int(marked) if 65 in picks else 0)
 unlock.append([case,choices,stage,flags,point_aim,exp_aim,point_dmg,exp_dmg,point_aim==exp_aim and point_dmg==exp_dmg])
export('poison-soldier-modifiers.csv',['배치','선택 순서','상태 단계','혼란·기절·표식·정신 지배','명중 가산','명중 기대','피해 가산','피해 기대','일치'],unlock)
write('soldier-unlock-checks.json',{'count':len(unlock),'failed':[r for r in unlock if not r[-1]],'stages':dict(Counter(r[3] for r in unlock)), 'cross_card_examples':[r for r in unlock if set(int(i) for i in r[1].strip(',').split(',') if i) in ({57,64},{57,65})]})

summary={'truncated':truncated,'buttons':len(a),'strategy_order_allowed':legal,'native_matrix_cases':py_done,'roster':len(base),'singles_considered':sum(py_done.values())*168,'single_deltas':len(solorows),'same_unit_pairs':len(checksrows),'observed_directions':len(pairs),'possible_campaign_directions':sum(int(r[6])+int(r[7]) for r in checksrows),'all_bad':bad,'ordered_list_differences':sum(not r[12] for r in checksrows),'multis':len(multicheck),'max_simultaneous':max((r[4] for r in multicheck),default=0),'multis_legal_in_some_order':sum(bool(r[-1]) for r in multicheck)//2,'multi_failed':[r for r in multicheck if not r[5] or not r[6]],'equip_failed':gear_fail,'units':ucases,'world_teams':{u:t for (_,u),t in team.items()},'stacked_live_cases':len(phys)}
write('poison-checks.json',summary)
print('gem',len(allcomb),len(checks['failed']),len(covers),'PY',len(base),len(checksrows),len(bad),len(multicheck))

fore={};owners={};fg=defaultdict(dict);fe=defaultdict(lambda:defaultdict(list))
for x in rows(FORECAST_RUN):
 if x[0]=='FORECASTOWNER':owners[x[1]]=x[2:]
 if x[0]=='FORECASTEFFECT':fe[x[1]][x[2]].append(x[3])
 if x[0]=='FORECASTGRANT':fg[x[1]][x[2]]=int(x[3])
 if x[0]=='FORECAST':
  i,o=int(x[1]),int(x[2]);role=x[3];fore[(role,i,o)]=x[4:9]
out=[];foerr=[];different=[];cnt=Counter();patterns=defaultdict(Counter)
for role in gemroles:
 for i in range(576):
  natural=fore.get((role,i,0));reverse=fore.get((role,i,1))
  if not natural or not reverse:continue
  valid=True
  wanted=[pools['Capstones'][i//72],pools['Keystones'][(i//9)%8],pools['Lodestones'][i%9]]
  if natural[:3]!=wanted or reverse[:3]!=wanted:valid=False
  for point in natural[3:]+reverse[3:]:
   try:
    ar=list(map(int,point.split(',')));valid &= len(ar)==8 and ar[2]>=0 and ar[3]>=ar[2] and 0<=ar[0]<=100
   except ValueError:valid=False
  matches=natural[3:]==reverse[3:]
  r=[role,i,*wanted,*natural[3:],*reverse[3:],valid,matches]
  out.append(r)
  if not valid:foerr.append(r)
  if not matches:different.append(r)
  if valid:
   cnt[role]+=1;patterns[role][' / '.join(natural[3:])]+=1
export('chosen-forecasts.csv',['직책','순번','캡스톤','키스톤','로드스톤','승천 순서 공격 예측','승천 순서 피격 예측','반대 순서 공격 예측','반대 순서 피격 예측','입력·범위 정상','순서 일치'],out)
control=[(role,i,v)for (role,i,o),v in fore.items() if i<0]
write('forecast-controls.json',{'owners':owners,'registered_traits':fg,'attached_effects':fe,'baselines_and_single_traits':control})
write('forecast-checks.json',{'paired':len(out),'per_role':cnt,'invalid':foerr,'order_diff':different,'individual_controls':len(control),'distinct_role_forecasts':{k:len(v)for k,v in patterns.items()},'missing_traits':{k:sorted(set(sum(pools.values(),[]))-set(v)) for k,v in fg.items()}})
