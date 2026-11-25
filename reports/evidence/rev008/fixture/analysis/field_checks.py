from pathlib import Path
from collections import Counter,defaultdict
import csv,re,json
V=Path(__file__).parent
O=V/'Evidence'
O.mkdir(exist_ok=True)
def read(f):
 b=f.read_bytes()
 return b.decode('utf-16' if b[:2] in (b'\xff\xfe',b'\xfe\xff') else 'utf-8-sig','replace')
def save(n,v):(O/n).write_text(json.dumps(v,ensure_ascii=False,indent=2),encoding='utf8')
def table(n,head,rows):
 with (O/n).open('w',encoding='utf-8-sig',newline='') as f:
  w=csv.writer(f);w.writerow(head);w.writerows(rows)
labels=['MatrixBase','ChosenRoles','PowersBefore','PowersAfter','FieldRoster','ChosenStones','FinalPowers','PoisonOrder','PoisonOrderTail','AttachmentBefore','FinalInteractions','ExtraRoster','FinalReplay','FinalSupplement','RollAfter','RollConfirm','CatalogLoot','MindCooldown']
allcases={};final=defaultdict(list);before={};truth={};generated=defaultdict(list);origins=[];states=[];environments=[]
power_info={};actions={};named=defaultdict(set)
for lab in labels:
 f=V/'Logs'/(lab+'.log')
 if not f.exists():continue
 left=read(f);case=0;data={};found_fields=set();core=[]
 for l in left.splitlines():
  if ' -- v' in l and '1.32.0' in l:core.append(l.split('Highlander:')[-1].strip())
  m=re.search(r'(R[678]\|.+)',l)
  if not m:continue
  x=m[1].split('|');kind=x[1]
  if x[0]=='R6' and kind=='CASE':
   case=int(x[3]);rec={'bits':defaultdict(list),'act':[],'world':[],'fin':None};data[case]=rec
  if not case:continue
  if x[0]=='R6':
   if kind=='WORLD':rec['world']=x[2:]
   if kind=='CASEFINISHED':rec['fin']=x[2:]
   if kind=='ACT' and len(x)>=15:
    vals=x[2:];rec['act'].append(vals)
    if vals[1]!='0':
     key=vals[6];named[key].add(vals[5]);actions.setdefault(lab,{}).setdefault(case,[]).append(vals)
   continue
  if x[0]!='R8':continue
  if kind in ('NATURALGRANT','VALID','CACHE','POWERFRAME','GATE','LANDING','LOOTAVAILABLE','LOOTWITNESSES','LOOTMOVE','LOOTREPLAY','LOOTNOPATH','LOOTVALID','LOOTRESULT','POWER','INPUT','PARRY','SUPPRESSREADY','SUPPRESSEDTEST','SUPPRESSINPUT','WIGHTCACHE','WIGHTTARGET','WIGHTMISSING','MINDREADY','MINDTURN','MINDFIRE','MINDCOOLDOWN','STUNGEAR','LOSTACT','FORECASTTARGET','PYSTACK'):
   rec['bits'][kind].append(x[2:])
  if lab=='ChosenStones' and kind=='GEMEFFECT':
   k=(int(x[2]),x[3],x[4]);before.setdefault(k,[]).append(x[5])
  if (lab=='FinalInteractions' and (case not in (251,252,253) or not (V/'Logs/FinalReplay.log').exists()) or lab==('RollAfter' if (V/'Logs/RollAfter.log').exists() else 'FinalReplay') and case in (251,252,253)) and kind in ('PASSIVE','PASSIVEOWNER','REPEATPASSIVE','FORECASTTARGET','LOOTAVAILABLE','LOOTWITNESSES','LOOTMOVE','LOOTREPLAY','LOOTNOPATH','LOOTVALID','LOOTRESULT','PYSTACK'):
   final[kind].append(x[2:])
 allcases[lab]=data
 env={'session':lab,'cases':len(data),'worlds':sum(bool(r['world']) for r in data.values()),'worlds_legend_tpy':sum(r['world'][1:3]==['3','True'] for r in data.values()),'case_end':sum(r['fin'] is not None for r in data.values()),'engine_version':bool(re.search(r'Init: Version: 8917',left)),'highlander':sorted(set(core)), 'finished':'R6|FINISHED|' in left};environments.append(env)
 for c,r in data.items():
  if (c in range(110,137) or c in range(170,187) or c in range(201,205) or c in range(238,249) or c in range(257,260) or c in range(263,266)) and (r['bits'] or r['act']):
   aa=[{'frame':int(v[0]),'round':v[1],'active_team':v[3],'actor_id':v[4],'unit':v[5],'ability':v[6],'target_id':v[7],'multi':v[8],'ap':v[9],'tiles':v[10],'hit':v[-1]} for v in r['act'] if v[1]!='0']
   power_info[lab+'/'+str(c)]={'observed':r['bits'],'actions':aa}
save('test-environments.json',environments);save('targeted-field-cases.json',power_info)
table('initial-effect-counts-before.csv',['배치','직책','효과 종류','동시 활성 효과 수','발생 능력 객체별 개수'],[[*key,len(v),json.dumps(dict(Counter(v)))] for key,v in sorted(before.items())])
pas=defaultdict(lambda:defaultdict(list));owners={};rep={}
for c,stage,oid,role,ap,total in final['PASSIVEOWNER']:owners[(int(c),oid,stage)]=(role,int(ap),int(total))
for c,stage,oid,role,k,j,eff,ab,guard,cls in final['PASSIVE']:
 if guard=='True':pas[(int(c),oid,role,k,int(j),cls)][stage].append((int(eff),int(ab)))
for c,role,k,accepted in final['REPEATPASSIVE']:rep[(int(c),role,k)]=accepted
pas_rows=[];duplicates=[];changed=[];unseen=[];refused=[]
for k,stage in sorted(pas.items()):
 n=stage.get('natural',[]);r=stage.get('replay',[]);c,i,role,ability,j,cls=k
 retried=rep.get((c,role,ability))
 pas_rows.append([c,i,role,ability,j,cls,len(n),len(r),','.join(str(a) for a,b in n),','.join(str(a) for a,b in r),retried or '',bool(n and sorted(n)==sorted(r)),len(n)==len(r)==1])
 if max(len(n),len(r))>1:duplicates.append(pas_rows[-1])
 if sorted(n)!=sorted(r):changed.append(pas_rows[-1])
 if retried is None:unseen.append(pas_rows[-1])
 if retried=='False':refused.append(pas_rows[-1])
table('permanent-effects-final.csv',['배치','유닛 객체','유닛','부여 능력','효과 슬롯','효과 클래스','자연 생성','재실행 후','최초 효과 객체','재실행 후 효과 객체','게임 재실행 반환값','동일 객체 유지','각각 1개'],pas_rows)
pasinfo={'groups':len(pas_rows),'actors_with_snapshots':len({(c,i) for c,i,st in owners}),'distinct_protected_effect_sources':sorted(set(r[3] for r in pas_rows)),'retry_calls':len(rep),'retry_return':dict(Counter(rep.values())),'duplicate_effects':duplicates,'changed_effects':changed,'no_retry':unseen,'retry_false':refused,'before_198':{role:{name:len(before.get((198,role,name),[])) for name in ('X2Effect_TurnStartActionPoints','X2Effect_CoarseRemembrance')}for role in ('ChosenAssassinM3','ChosenSniperM3','ChosenWarlockM3')},'after_198':[r[:8] for r in pas_rows if r[0]==198 and r[5] in ('X2Effect_TurnStartActionPoints','X2Effect_CoarseRemembrance')]}
save('permanent-checks.json',pasinfo)
loot=[]
for c in (238,239,240,241):
 d=allcases.get('CatalogLoot',allcases.get('FinalReplay',allcases.get('FinalInteractions',{}))).get(c,{}).get('bits',{})
 mv=d.get('LOOTMOVE',[None])[0];res=d.get('LOOTRESULT',[]);ab=d.get('LOOTVALID',[])
 if mv is None:continue
 results=[{'ground':int(v[3]),'backpack':int(v[4]),'owner':int(v[5]),'slot':v[6]} for v in res]
 expected=(c==239)
 loot.append({'case':c,'owner':int(mv[1]),'drop_id':int(mv[2]),'item_id':int(mv[3]),'stock_ability':int(mv[4]),'custom_ability':int(mv[5]),'end_tile':mv[6],'drop_tile':mv[7],'ordinary_move':mv[8]=='True','move_finished_event_replayed':bool(d.get('LOOTREPLAY')),'checks':ab,'outcomes':results,'initial_drop':d.get('LOOTAVAILABLE',[]),'competing_looters_isolated':d.get('LOOTWITNESSES',[]),'expected_pickup':expected,'matching':bool(len(results)>=2 and int(mv[2])>0 and int(mv[3])>0 and (results[-1]['backpack']==1 and results[-1]['owner']==int(mv[1]) and results[-1]['ground'] in (0,-1) if expected else results[-1]['backpack']==0 and results[-1]['ground']==1))})
save('sectoid-loot-checks.json',loot)
def events(label,c,keyword):
 return [v for v in actions.get(label,{}).get(c,[]) if keyword.lower() in v[6].lower()]
roles=['ChosenAssassinM3','ChosenSniperM3','ChosenWarlockM3']
choice=[]
for ability in ('TPYDuplicateUnit','TPYChosenCommand','TPYChosenWave','TPYChosenGroundpound','TPYChosenTeleport'):
 for role in roles:
  found=[]
  for lab in ('ChosenRoles','PowersAfter','FinalPowers'):
   for c,r in allcases.get(lab,{}).items():
    if c not in range(122,137):continue
    found.extend([lab+'/'+str(c)+'#'+a[0] for a in r['act'] if a[1]!='0' and a[3]=='16' and a[5]==role and a[6]==ability])
  choice.append([role,ability,', '.join(found)])
table('chosen-active-turns.csv',['직책','능력','지정 적 턴 분기에서 관찰한 기록'],choice)
save('battle-summary.json',{'chosen_active_witnesses':sum(bool(r[-1]) for r in choice),'native_forecast_targets':final['FORECASTTARGET'],'loot_complete':len(loot)==4 and all(r['matching'] for r in loot),'passive_groups':len(pas_rows),'duplicate_groups':len(duplicates),'changed_groups':len(changed)})
print('protected',len(pas_rows),len(duplicates),len(changed),'roles',sum(bool(r[-1]) for r in choice),'loot',[(r['case'],r['matching'])for r in loot])
