from collections import defaultdict,Counter
from pathlib import Path
import json,sys
from read_fields import events
def summarize(folder):
 out={};assertions=[]
 for f in sorted(folder.glob('*.log')):
  if f.stem.startswith('Review') or f.stem not in ('RosterBind','IndividualSkills','MultiBindGrid','ExtractVIP','DefenseBranch','DefenseRetest','StasisObjective','WarlockCover','FinalCandidate','DefenseFinal','VIPControl','RosterCompare'):continue
  g=defaultdict(lambda:defaultdict(list))
  capture=list(events(f));firstcase=next((cx for cx,tag,row in capture if tag=='WORLD'),None)
  for c,k,x in capture:
   if c is None and k in ('OBJVIP','EVAC','VIPOBJECTIVE','POD'):c=firstcase
   if c is not None:g[c][k].append(x[2:])
  by={}
  for c,rows in g.items():
   actions=[a for a in rows['ACT']if a[1]!='0']
   when={a[0] for a in actions}
   shots=[dict(template=a[3],target=a[4],hp=a[5],chance=a[7])for a in rows['SHOT'] if float(a[5])<=2]
   by[c]=dict(world=rows['WORLD'],actions=actions,branches=[n for n in rows['NODE'] if n[3]in ('AdventSniperTryKillShot','PsiOpsTryKillShot','CoarseOutriderTryEquippedMelee','CoarseTryRequiemLeaderJob','CoarseTryRequiemFollowerJob','NightmareAlwaysRevealOnAvengerDefenseLW','FlushRoot','TryFrostTechProtocolMJ','SkipMove')],witness=rows['WITNESS'],scope=rows['SCOPED'],finish=rows['CASEFINISHED'],weak_target=list({(a['target'],a['hp'],a['chance'])for a in shots}),unit_damage=[a for a in rows['TARGET']+rows['MULTI']if a[0]in when and a[-1].split(',')[0]!=a[-1].split(',')[-1]],checks={k:rows[k]for k in ['POD','PODROLES','ROLE','BOUNDSTATE','BINDVISIBLE','COVER','XCOMFLUSH','VIPSTEP','VIPOBJECTIVE','OBJVIP','EVAC','BURROWSETUP','UNBURROW','PLACED','RUSHNEXT','VIPCONTROL'] if rows[k]})
  out[f.stem]=by
 def check(condition,name):
  if not condition:raise AssertionError(name)
  assertions.append(name)
 m=out['MultiBindGrid']
 def act(c,name):return [a for a in m[c]['actions']if a[6]==name]
 def hp(c,frame,target):return [a[-1] for a in m[c]['unit_damage']if a[0]==frame and a[1]==target]
 a=act(80,'StandardShot');check(len(a)==1 and (a[0][7],'1.0000','100') in m[80]['weak_target'] and hp(80,a[0][0],a[0][7])==['1.0000,0.0000'] and m[80]['witness'][0][-1]=='SniperFinish','sniper finished the same 100%/1 HP target in the ordinary enemy turn')
 check(any(n[3:] == ['AdventSniperTryKillShot','BTS_FAILURE']for n in m[81]['branches']) and bool(act(81,'StandardShot')),'healthy targets use normal fire')
 check(any(n[3:] == ['AdventSniperTryKillShot','BTS_FAILURE']for n in m[82]['branches']) and not act(82,'StandardShot') and any(x[2]=='0' for x in m[82]['weak_target']),'zero hit chance rejected by the isolated finishing branch')
 r=act(83,'StandardShot');check(bool(r)and any(x[0]==r[0][7]and int(x[2])>90 for x in m[83]['weak_target'])and any(w[-1]=='RaptorFinish' for w in m[83]['witness']),'Raptor finishing branch fired on the selected wounded target')
 check(bool(act(84,'StandardMelee'))and any(n[3:] == ['CoarseOutriderTryEquippedMelee','BTS_SUCCESS']for n in m[84]['branches']),'Outrider first-action melee branch used its hammer')
 check(act(85,'MarkTarget')[0][7]==act(85,'StandardShot')[0][7],'Outrider marked the soldier its ally shot')
 for c,name in [(86,'LightningHands'),(87,'Faceoff'),(88,'Faceoff'),(89,'MZ_FDFreezeSpit'),(90,'MZ_FDHardlinerFreezeLauncher'),(91,'MZ_FDFrostProtocol')]:
  check(bool(act(c,name))and (len(act(c,name)[0][8].strip(',').split(','))>=2 if c in [87,88,89,90] else True),'enemy turn '+str(c)+' used '+name)
 ids=[act(61,'MZ_FDAdderRushAndBind')[0][7],act(61,'MZ_FDAdderRushAndBind_Bind')[0][7]]+[a[7]for a in act(61,'MZ_FDAdderRushAndBind_Crush')]
 check(len(ids)>=4 and len(set(ids))==1 and len(m[61]['checks']['PLACED'][0][-1].split(','))==3 and any(b[-1]=='168.0000'for b in m[61]['checks']['BOUNDSTATE']),'three exposed soldiers; natural rush, binding and two crushes kept the same victim')
 for c,role,job in [(95,0,'CoarseTryRequiemLeaderJob'),(96,1,'CoarseTryRequiemFollowerJob')]:
  actor=m[c]['checks']['PODROLES'][0][role]
  check(any(n[1]==actor and n[3:]==[job,'BTS_SUCCESS']for n in m[c]['branches']) and any(a[4]==actor for a in act(c,'PistolStandardShot')),'wounded separated '+('leader'if role==0 else'follower')+' reached its role-specific pistol attack')
 cover=m[32]['checks']['COVER'][0];flush=m[32]['checks']['XCOMFLUSH'][0]
 check(cover[1:3]==flush[1:3] and flush[-1]=='eHit_Success' and any(a[0]==cover[0]and a[4]==cover[2]for a in act(32,'StandardMove')),'same Warlock moved after a legal XCOM Flush; directional and tile cover recorded')
 w=out['IndividualSkills'][54];check(len([a for a in w['actions']if a[6]=='PistolStandardShot'and a[-1]=='eHit_Crit'])==2,'unmodified rev006 Wraith successfully used pistol twice')
 vv=out['ExtractVIP'][60]['checks']['VIPSTEP']
 for nm in ['StasisSuitVIP','CommanderVIP']:
  check(len([a for a in vv if a[3]==nm and 'eGameRule_SkipTurn' in a[-1]and a[4]=='2,0'and len(set(a[5].split('>')))==1])>=3,nm+' retained its extraction tile through three neutral turns')
 if 'DefenseRetest' in out and out['DefenseRetest'].get(27,{}).get('witness'):
  nf=out['DefenseRetest'][27]
  nw=next(w for w in nf['witness'] if w[-1]=='NightmareDefense')
  check(any(a[4]==nw[1] and a[6]=='AHWMagnalidUnburrow' and int(a[0])==int(nw[0])+1 for a in nf['actions']) and any(x[-2:]==['True','False'] for x in nf['checks']['UNBURROW']),'defense-specific Nightmare branch followed by actual loss of Burrowed')
 if 'StasisObjective' in out and out['StasisObjective'].get(98,{}).get('finish'):
  st=out['StasisObjective'][98];identified=st['checks']['OBJVIP']
  check(any(z[1:]==['StasisSuitVIP','1','True','True','VIPRoot']for z in identified),'natural rescue mission selected an unconscious, carriable, neutral StasisSuitVIP')
  for nm in ['CommanderVIP','StasisSuitVIP']:
   check(len([a for a in st['checks']['VIPSTEP'] if a[3]==nm and 'eGameRule_SkipTurn' in a[-1] and a[4]=='2,0' and len(set(a[5].split('>')))==1])==2,'two additional neutral turns on the actual stasis rescue objective map for '+nm)
 if 'VIPControl' in out and out['VIPControl'].get(100,{}).get('finish'):
  pv=out['VIPControl'][100]['checks']
  check(all(x[3]=='1' and x[5]=='False' and int(x[6])>0 for x in pv['VIPCONTROL']) and len({x[6]for x in pv['VIPCONTROL']})==1,'alert, conscious neutral subjects had an actual XCOM evac zone')
  for nm in ['CommanderVIP','StasisSuitVIP']:
   check(len([a for a in pv['VIPSTEP'] if a[3]==nm and 'eGameRule_SkipTurn' in a[-1] and a[4]=='2,0' and len(set(a[5].split('>')))==1])==2,'two stationary neutral turns near the live extraction zone for '+nm)
  blood=out['VIPControl'].get(31,{}).get('actions',[])
  if any(a[6]=='ARFMDEAbility_BloodTide' for a in blood):
   owners={a[4] for a in blood if a[6]=='ARFMDEAbility_BloodTide'and a[9]=='0,1'}
   spent={a[4] for a in blood if a[6]=='StandardShot'and a[9]=='1,0'}
   check(len(owners)==2 and owners<=spent,'rev007 Blood Tide granted two reaction points and the respective owners fired')
  ri=out['VIPControl']
  if ri.get(38,{}).get('actions'):
   cm=next((a for a in ri[38]['actions']if a[6]=='AHWShinanimMercy1'),[])
   check(bool(cm)and any(d[0]==cm[0] and d[1]==cm[7] and d[-1]=='1.0000,0.0000'for d in ri[38]['unit_damage']),'rev007 Shinanim mercy finished the designated 1 HP soldier')
  if ri.get(36,{}).get('actions'):
   check(any(a[6]=='AHWNivenHeal'and a[7]!='0' for a in ri[36]['actions']),'rev007 Niven used healing on a selected ally')
 return {'assertions':assertions,'fields':out}
if __name__=='__main__':
 p=Path(sys.argv[1]);r=summarize(p);Path(__file__).with_name('TacticalChecks.json').write_text(json.dumps(r,indent=1),encoding='utf8');print('checked',len(r['assertions']),'conditions',list(r['fields']))
