from collections import defaultdict,Counter
from pathlib import Path
import sys,json
from audit_schedules import loaddecl,collect,arr,words,atom

def inspect(baselog,detail,storylog=None):
 base=collect(baselog);live=collect(detail)
 assert live['DETAILEND'] and live['STORYEND'],'detail or story hook did not finish'
 expected=loaddecl()
 assert len(expected['missionschedules'])==850 and len(expected['configurableencounters'])==275 and len(base['SCHED'])==1229,'incomplete reference inventory'
 sched=defaultdict(list);slots=defaultdict(dict);head={};extra={}
 for i,k,*props in live['SBASE']:head[i]=props
 for i,j,*props in live['SLOT']:slots[i][int(j)]=props
 for i,k,*props in live['EXTRAENC']:extra[k.casefold()]=props
 for i,k,*rest in base['SCHED']:sched[k.casefold()].append(i)
 if len(head)!=len(base['SCHED']):raise ValueError('different schedule inventory')
 nums=['idealxcomspawndistance','minxcomspawndistance','encounterzonepatroldepth','alientoadventfollowerratio','alientoadventleaderratio','maxturrets','xcomsquadstartsconcealed','defaultencounterleaderspawnlist','defaultencounterfollowerspawnlist']
 fields=['encounterid','encounterzonewidth','encounterzonedepthoverride','encounterzoneoffsetfromlop','encounterzoneoffsetalonglop','encounterzonevolumetag','spawnlocationactortag','includetacticaltag','excludetacticaltag','preplacedencountertag','strategyunittag']
 missing=[];tkeys=[];slotn=0;condfields=0
 for e in expected['missionschedules']:
  key=e['scheduleid'];w=arr(e,'preplacedencounters');cand=sched[key]
  def same(i):
   if not all(atom(y)==e[k]for k,y in zip(nums,head[i])if k in e):return False
   if len(slots[i])<len(w):return False
   return all(all(atom(y)==p[k]for k,y in zip(fields,slots[i][j])if k in p) for j,p in enumerate(w))
  ix=next((v for v in cand if same(v)),None)
  if ix is None:missing.append(key);continue
  cand.remove(ix);slotn+=len(w);condfields+=sum(sum(k in p for k in fields)for p in w)
  for j in range(len(w),len(slots[ix])):tkeys.append((j-len(w),slots[ix][j][0],slots[ix][j][7]))
 keys=['offsetforcelevel','offsetalertlevel','reinforcementcountdown','bgroupdoesnotawardloot']
 eerr=[e['encounterid'] for e in expected['configurableencounters']if not all(atom(v)==e[k]for k,v in zip(keys,extra[e['encounterid']])if k in e)]
 enc=defaultdict(list);bk={a[1].casefold():a for a in base['BUCKET']}
 for row in base['ENC']:enc[row[1].casefold()].append(row)
 from audit_native import audit as native_audit
 grid=native_audit(baselog,detail,storylog)
 failures=grid['grid_differences'];blank=grid['valid_empty'];legal=grid['valid_nonempty'];gridrows=grid['etp_total'];nogrid=grid['holes_in_original']
 measured=collect(storylog)if storylog else live
 order={row[0]:words(row[1])for row in measured['PORTALORDER']};story=measured['STORY'];ports=measured['PORTAL']
 trail=defaultdict(list)
 for mode,family,key,method,before,after in measured['STORYHOOK']:trail[(mode,family,key)].append((method,words(before),words(after)))
 continuity=[];external=Counter()
 for (mode,family,key),steps in trail.items():
  state=['advtrooperm1']*8
  for owner,bef,aft in steps:
   if state!=bef:continuity.append([mode,family,key,owner])
   if owner.lower() not in ('x2downloadablecontentinfo_totallynotpsychogoldenpath','x2dlcinfo_coarseencounters') and aft!=bef:external[(family,key,owner)]+=1
   state=aft
 # Full rosters for the fixture's eight initial AdvTrooperM1 slots, in source order.
 options=[
  ('GoldenPath1_LW','ALNx4_Standard','','AHWMutonMagnaElite MutonM3_LW MutonM3_LW'),
  ('GoldenPath1_LW','OPNx4_Standard','','Mk2_Custodian'),
  ('GoldenPath1_LW','ADVx4_Standard','','AdventCustodian ARFMAdvKnightM3 ARFMAdvKnightM3 ARFMAdvArtilleryM3 ARFMAdvArtilleryM3'),
  ('GoldenPath1_LW','Lone_Drone_LW','','AdventCustodian'),
  ('GoldenPath2_LW','OPNx6_WithTerror','','AHWHeavyFloater AHWHeavyFloater AdventCustodian AdventCustodian'),
  ('GoldenPath2_LW','OPNx6_Standard','','AHWHeavyMechtoid MutonM3_LW MutonM3_LW'),
  ('GoldenPath2_LW','ADVx4_Standard','','AdventCustodian'),
  ('GoldenPath2_LW','Lone_Drone_LW','','AHWGunship'),
  ('GoldenPath3_LW','OPNx8_Standard','','ExaltedCustodian_Grandmaster ExaltedCustodian ExaltedCustodian Muton_Prowler Muton_Prowler'),
  ('GoldenPath3_LW','ALNx8_Standard','','AHWHeavyMechtoid MutonM3_LW MutonM3_LW DromeDome_Cryo DromeDome_Cryo'),
  ('GoldenPath3_LW','SolitaryHunter','','ExaltedPurgeArchbishop ExaltedPurgePriest ExaltedPurgePriest'),
  ('GoldenPath4_LW','GP_Broadcast_Codices_LW_PROTECTED','AHWOutsiderMagna ExaltedCustodian','ExaltedCustodian AHWOutsiderMagna'),
  ('GoldenPath4_LW','GP_Broadcast_Codices_Extreme_LW_PROTECTED','AHWOutsiderMagna AHWOutsiderMagna Sectopod','ExaltedCustodian ExaltedCustodian ExaltedCustodian'),
  ('GoldenPath4_LW','Lone_Drone_LW','AHWCyberdisc',''),
  ('GoldenPath4_LW','GoldenPath_Hard','','MutonM3_LW DromeDome_Fire DromeDome_Poison DromeDome_Cryo Andromedon AHWAndromelidMagnaM3 NajaM3 NajaM3'),
  ('GoldenPath4_LW','GoldenPath_Extreme','','AHWBerserkerMagna DromeDome_Fire DromeDome_Poison DromeDome_Cryo Andromedon AHWAndromelidMagnaM3 NajaM3 NajaM3'),
  ('GoldenPath2_LW','GP_Forge_BossGroup','AHWMechapede AHWGunship AHWGunship','ExaltedCustodian ExaltedCustodian'),
  ('GoldenPath2_LW','GP_Forge_BossGroup_Easy','AHWMechapede AHWHeavyFloater AHWHeavyFloater','AdventCustodian AdventCustodian'),
  ('GoldenPath2_LW','GP_Forge_BossGroup_Extreme','AHWMechapede AHWCyberdisc AHWCyberdisc','ExaltedCustodian_Grandmaster ExaltedCustodian ExaltedCustodian'),
  ('GuerillaOps_LW','OPNx4_Standard','','')]
 wanted={}
 for md in ('0','1'):
  for family,key,always,on in options:
   r=always.lower().split()+(on.lower().split() if md=='1' else [])
   defaults=['advtrooperm1']*8
   if key=='ADVx4_Standard' and (md,family,key) in trail:
    steps=trail[(md,family,key)];defaults=next(bef for name,bef,aft in steps if name.lower()=='x2downloadablecontentinfo_totallynotpsychogoldenpath')
   wanted[(md,family,key)]=r+defaults[len(r):]
 story_bad=[]
 for mode,opt,fam,k,w in story:
  actual=words(w);ref=wanted.pop((mode,fam,k),None)
  if (mode=='1')!=(opt.lower()=='true') or ref!=actual:story_bad.append([mode,fam,k,ref,actual])
 story_bad.extend([[*key,'missing'] for key in wanted])
 if storylog:
  assert measured['STORYENV'] and measured['STORYENV'][-1][:2]==['3','True'] and len(trail)==40
  assert all(len(x)==len(measured['STORYORDER'][0][1].strip(',').split(',')) for x in trail.values())
 assert gridrows==93*27*4 and len({tuple(row[:3]) for row in live['GRID'] if row[0].lower().startswith('etp_')})==gridrows
 assert len(ports)==60 and len(story)==40 and len(extra)>=275 and len(head)==1229
 portbad=[r[:3]for r in ports if not words(r[3])or words(r[3])!=words(r[4])]
 out={'schedule_declarations':len(expected['missionschedules']),'matched_with_placement':len(expected['missionschedules'])-len(missing),'slot_count':slotn,'compared_explicit_slot_fields':condfields,'schedule_differences':missing,'detailed_encounter_differences':eerr,'conditional_appends':[[i,id,tag,n] for (i,id,tag),n in Counter(tkeys).items()],'etp_grid':gridrows,'eligible_draws':legal,'no_eligible_draws':blank,'illegal_grid':failures,'base_inside_variant_absent':dict(nogrid),'story_hook_calls':len(story),'story_specific_errors':story_bad,'portal_hook_calls':len(ports),'portal_restore_errors':portbad,'portal_orders':order,'story_option_restored':measured['STORYEND'][-1],'story_environment':measured['STORYENV'],'story_hook_order_errors':continuity,'independent_mod_changes':[[*k,v]for k,v in external.items()]}
 return out
if __name__=='__main__':
 a,b=map(Path,sys.argv[1:3]);o=inspect(a,b,Path(sys.argv[3]) if len(sys.argv)>3 else None);d=Path(__file__).resolve().parent/(b.stem+'_detail.json');d.write_text(json.dumps(o,indent=1),encoding='utf8')
 for k,v in o.items():print(k,str(v)[:1200])
