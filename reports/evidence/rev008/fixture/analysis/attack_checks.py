from pathlib import Path
from collections import Counter,defaultdict
import csv,json,itertools,sys,hashlib,re
V=Path(__file__).parent
O=V/'Evidence'
def read(f):
 b=f.read_bytes();return b.decode('utf-16' if b[:2] in (b'\xff\xfe',b'\xfe\xff') else 'utf-8-sig','replace')
def save(n,v):(O/n).write_text(json.dumps(v,ensure_ascii=False,indent=2),encoding='utf8')
def csvout(n,header,ls):
 with (O/n).open('w',encoding='utf-8-sig',newline='')as f:
  w=csv.writer(f);w.writerow(header);w.writerows(ls)
a=json.loads(read(V/'poison_cards.json'))
pairs=[];gates=[];actions=[];templates=[];newowners=[];newp=[];unexpected=[]
for phase,filename in [('before','AttachmentBefore'),('final',('RollAfter' if (V/'Logs/RollAfter.log').exists() else 'FinalReplay' if (V/'Logs/FinalReplay.log').exists() else 'FinalGroup1'))]:
 f=V/'Logs'/(filename+'.log')
 if not f.exists():continue
 tests={};slots=defaultdict(set);problems=[]
 for l in read(f).splitlines():
  if 'R8|' not in l:continue
  c=l.split('R8|',1)[1].split('|');k=c[0]
  if k=='ATTACHGATE':
   act,buttons,sig=c[1:4];selected=tuple(int(q)for q in buttons.strip(',').split(',')if q);observed={}
   if not sig.endswith('!END!'):problems.append([act,buttons,'불완전한 기록']);continue
   for result in sig[:-5].strip(';').split(';'):
    if not result:continue
    loc,typ,req,raw=result.split(':');g=tuple(int(q)for q in req.strip(',').split(',')if q);passed=raw=='True';expected=set(g)<=set(selected)
    observed[(loc,typ,g)]=passed;slots[act].update(g);gates.append([phase,act,buttons,loc,typ,req,passed,expected,passed==expected])
    if passed!=expected:problems.append([act,buttons,result])
   tests[act,selected]=observed
  if k=='ATTACHRESULT':actions.append([phase,*c[1:]])
  if k=='CARDTEMPLATE':templates.append([phase,*c[1:]])
  if k=='NEWOWNER':newowners.append([phase,*c[1:]])
  if k=='NEWPASSIVE':newp.append([phase,*c[1:]])
  if k=='ATTACHMISSING':unexpected.append([phase,*c[1:]])
 for ability,opts in slots.items():
  for i,j in itertools.combinations(sorted(opts),2):
   if a[i]['card']==a[j]['card']:continue
   fw=tests.get((ability,(i,j)));rv=tests.get((ability,(j,i)))
   pairs.append([phase,ability,i,j,a[i]['callback'],a[j]['callback'],fw is not None and rv is not None,fw==rv and fw is not None,len([v for v in (fw or {}).values() if v])])
 save('attack-card-'+phase+'.json',{'templates_with_affected_effects':len(slots),'buttons_with_attack_effects':sorted(set().union(*slots.values())) if slots else [],'checks':len([r for r in gates if r[0]==phase]),'legal_distinct_card_pairs_same_attack':len([r for r in pairs if r[0]==phase]),'order_failures':[r for r in pairs if r[0]==phase and (not r[6] or not r[7])],'mismatched_conditions':problems})
csvout('attack-effect-card-conditions.csv',['버전','기술','선택 순서','주·보조 효과 슬롯','효과 클래스','요구 선택 ID','게임 조건 통과','기대','일치'],gates)
csvout('attack-effect-order.csv',['버전','기술','A','B','선택 A','선택 B','양방향 실행','효과별 통과 동일','양쪽 활성 슬롯 수'],pairs)
csvout('attack-card-effects.csv',['버전','기술','표적','선택 순서','보조 표적','성공 효과 수','수류탄 사용 가능 값','기준·결과 충전','기준·결과·최대 HP','기준·결과 피해 기록 수','효과별 결과'],actions)
csvout('attack-card-templates.csv',['버전','기술','난이도 변형','보조 표적 방식','보유 능력별 추가 반경(m)','조건 수','첫 보유 조건','폭탄 이벤트 위치'],templates)
csvout('new-unit-card-effects.csv',['버전','배치','유닛','객체','카드 능력','효과','명중 가산','찰과상 배제','행동력 종류·수'],newp)
save('attack-card-actual.json',{'combat_stage_effects':actions,'new_actors':newowners,'new_effects':newp,'missing_fixture_ability':unexpected})
print(len(gates),len(pairs),len(actions),len(newp),unexpected)

outcomes=[];passive_records=[];radii_records=[]
for r in actions:
 phase,ability,unit,buttons,scope,count,enabled,charges,hp,damage,raw=r
 pick=set(int(k) for k in buttons.strip(',').split(',')if k);active=(phase=='final')
 value=float(enabled);before,after=map(int,charges.split(','));health,hit,mx=map(float,hp.split(','));from_count,to_count=map(int,damage.split(','))
 if ability=='PsiBombStage1':
  expect_charges=before-int(active and unit=='Soldier' and 50 in pick and before>0)
  expect_enabled=int(not (active and unit=='Soldier' and 27 in pick))
  ok=after==expect_charges and value==expect_enabled and int(count)==(len(pick&{27,50}) if active and unit=='Soldier' else 0)
 elif ability=='Vanish':
  ok=hit==(min(mx,health+400) if active and 70 in pick else health) and int(count)==int(active and 70 in pick)
 else:
  expect=active and 46 in pick
  ok=(hit<health if expect else hit==health) and to_count-from_count==int(expect) and int(count)==int(expect)
 outcomes.append([*r,ok])
want={'Sectoid':{'ARFMDESW_SlipperyStalkers','ARFMPYP_SectoidPsi'},'Viper':{'ARFMDESW_SlipperyStalkers'},'Berserker':{'ARFMDESW_SpeedyGonzales'},'Faceless':{'ARFMDESW_SpeedyGonzales'},'Muton':{'ARFMPYP_BrutalistMuton'},'AdvTrooperM3':{'ARFMPYP_TrooperAim'}}
for phase,case,unit,owner,observed_count in newowners:
 if unit not in want:continue
 present=[x for x in newp if x[:4]==[phase,case,unit,owner]]
 target=(want[unit] if phase=='final' else (want[unit]&{'ARFMPYP_SectoidPsi'})) if case in ('251','252') else set()
 marker=Counter(x[4] for x in present);ok=marker==Counter(target) and int(observed_count)==len(target)
 for rr in present:
  if rr[4]=='ARFMPYP_TrooperAim':ok=ok and int(rr[6])==20
  if rr[4]=='ARFMPYP_BrutalistMuton':ok=ok and rr[7]=='True'
  if rr[4]=='ARFMDESW_SpeedyGonzales':ok=ok and rr[8].lower()=='move,1'
 passive_records.append([phase,case,unit,sorted(target),sorted(marker.elements()),ok])
radius_map={'RocketLauncher':{'ARFMPYP_WeGotTheRockets':1.51},'MicroMissiles':{'ARFMPYP_WeGotTheRockets':1.51},'ThrowGrenade':{'ARFMPYP_BedlamBlasting':1.51,'ARFMTPY_JANMegaNades':4.51},'LaunchGrenade':{'ARFMPYP_BedlamBlasting':1.51},'AHWKosmaLauncher':{'ARFMPYP_BedlamBlasting':1.51}}
for phase,key,variant,style,bonus,*_ in templates:
 if key not in radius_map:continue
 saved=[(w.split(':')[0],float(w.split(':')[1]))for w in bonus.strip(',').split(',') if w and w.lower().startswith('arfm')]
 expected=radius_map[key] if phase=='final' or key=='MicroMissiles' else {}
 radii_records.append([phase,key,variant,dict(saved),expected,Counter(saved)==Counter(expected.items())])
save('attachment-outcomes.json',{'phase_cases':dict(Counter(x[0] for x in outcomes)),'mismatches':[r for r in outcomes if not r[-1]],'checked_owners':len(passive_records),'unit_cases':passive_records,'unit_mismatches':[r for r in passive_records if not r[-1]],'radius_rows':radii_records,'radius_mismatches':[r for r in radii_records if not r[-1]]})

stats=[];mind=[]
f=V/'Logs'/('RollAfter.log' if (V/'Logs/RollAfter.log').exists() else 'FinalReplay.log')
if f.exists():
 for l in read(f).splitlines():
  if 'R8|STATCARD|' in l:
   v=l.split('R8|STATCARD|')[1].split('|');role,cl,aim,stat,old_aim,name=v
   roll=role in ('ARFMPYP_SectoidPsi','ARFMPYP_LancerStun','ARFMPYP_BerserkerRoll','ARFMPYP_MutonRoll')
   stats.append([*v,int(aim)==(0 if roll else 20) and int(stat)==(40 if roll else 0) and int(old_aim)==20])
  if 'R8|STATFIELD|' in l:mind.append(l.split('R8|STATFIELD|')[1].split('|'))
save('stat-contest-checks.json',{'templates':stats,'failed':[r for r in stats if not r[-1]],'mindspin_forecasts':mind})
