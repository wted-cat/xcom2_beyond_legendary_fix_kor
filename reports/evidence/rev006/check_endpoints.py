"""Read the compact tactical evidence directly, without an XCOM installation."""
from pathlib import Path
from zipfile import ZipFile
import sys,collections
def events(z,field):
 case=None
 for raw in z.read(field+'.txt').decode('utf-8').splitlines():
  r=raw.split('ScriptLog: ',1)[1].split('|')
  if r[1]=='CASE':case=int(r[3])
  elif r[1]=='WORLD':case=int(r[2])
  yield case,r
def require(cond,description):
 if not cond:raise ValueError(description)
 print('OK',description)
def run(path):
 with ZipFile(path) as z:
  require(z.testzip() is None,'archive integrity')
  cases={key:[*events(z,key)] for key in ['Altar03','BeforeAltar','FocusedAltar','Support04','SupportGaps','OtherGaps','PostRevision','FocusedSight']}
  for n in ['FinalSight','FinalDefense','FinalAltar','FinalBlood','FinalSingleBind']:
   if n+'.txt' in z.namelist():cases[n]=[*events(z,n)]
  for n,records in cases.items():
   worlds=[r for k,r in records if r[1]=='WORLD']
   require(worlds and all(r[3:5]==['3','True'] for r in worlds),n+' Legend and That Perilous Yearning')
  def lines(n,case,key):
   return [r for sid,r in cases[n] if (case is None or case==sid) and r[1]==key]
  def frames(n,case,unit,kind):
   return {r[2] for r in lines(n,case,'ACT') if r[5]=='16' and r[7]==unit and r[8]==kind}
  for n in ['FocusedAltar','BeforeAltar']:
   measured={(int(r[5]),int(r[7]),r[8],r[9]) for r in lines(n,None,'PAIR')}
   require({(3,0,'False','False'),(4,0,'False','True'),(4,1,'False','False')}<=measured,n+' original/repaired radius with civilian and allied targets')
  if 'FinalAltar' in cases:
   normal=frames('FinalAltar',18,'AHWAltar','AHWAltarDesolate')
   results=[r for r in lines('FinalAltar',18,'ACT') if r[2] in normal and r[11]=='1,0' and r[13]=='True,False']
   require(any(sum(t[2]==r[2] and t[4]=='Civilian' and t[5]=='1.0000,0.0000' for t in lines('FinalAltar',18,'MULTI'))==4 for r in results),'terror last action used the charged altar and killed four civilians')
   require(any(r[5]=='TryAltarDesolateProtocolAttack' and r[-1]=='BTS_SUCCESS' for r in lines('FinalAltar',18,'NODE')),'terror-specific AI attack branch completed')
  area=lines('PostRevision',35,'CASTLOC')
  shots=[r for r in area if r[3]=='AHWCyberdiscDeathBlossom' and r[7:10]==['2','2','0']]
  require(len(shots)>=2 and {r[2] for r in shots}<=frames('PostRevision',35,'AHWCyberdisc','AHWCyberdiscDeathBlossom'),'two actual radial attacks with two injured soldiers each')
  require(any(r[4]==','.join(r[6].split(',')[:2]) for r in shots) and any(r[4]!=','.join(r[6].split(',')[:2]) for r in shots),'both shooter and non-shooter tiles actually used')
  for case,template,ability in [(36,'AHWNiven','AHWNivenHeal'),(37,'AHWNivenT3','AHWNivenHealM2')]:
   histories=frames('FocusedSight',case,template,ability)
   require(any(r[2] in histories and r[4]=='AdvTrooperM3' and r[5]=='8.0000,20.0000' for r in lines('FocusedSight',case,'TARGET')),template+' restored wounded unit at 8 HP to 20 HP')
  for case,condition,which in [(38,'BleedingOut','1'),(39,'Dazed','2'),(40,'Unconscious','2')]:
   field='FocusedSight'
   applied=[r for r in lines(field,case,'MERCYSTATE') if r[4]==condition and r[5:7]==['AA_Success','True']]
   arrivals={(r[2],r[9])for r in lines(field,case,'ACT')if r[5]=='16'and r[7]=='AHWArchonMagnaM4'and r[8]=='AHWShinanimMercy'+which}
   defeated={(r[2],r[4])for r in lines(field,case,'MERCYEND')if r[5]=='False,True'and r[6].split(',')[-1]=='0.0000'}
   require(any(a[3]==target for fr,target in (arrivals&defeated) for a in applied),'M4 Mercy selected and killed the designated '+condition+' target')
  pos=[r for r in lines('FocusedSight',41,'MELEEPLACED')];require(bool(pos),'healthy control in melee range')
  target=pos[0][4]
  cond=[r for r in lines('FocusedSight',41,'MERCYVALID') if r[5]==target and r[7]=='False,False,False' and r[8]=='True']
  require({r[4]for r in cond if r[9]!='AA_Success'}=={'AHWShinanimMercy1','AHWShinanimMercy2'} and not any(r[4]==target for r in lines('FocusedSight',41,'MERCYEND')) and frames('FocusedSight',41,'AHWArchonMagnaM4','StunLance'),'healthy control rejected by both abilities, actual replacement action')
  require(any(r[5]=='8.0000,12.0000' and r[2] in frames('SupportGaps',22,'AdvMedicM2','MedikitHeal') for r in lines('SupportGaps',22,'TARGET')),'medic healed the selected wounded soldier')
  steps=[('PraetorianLieutenantOrder','686'),('EnergyShield','687'),('StandardShot','688')]
  require(all(any(r[2]==frame and r[8]==act for r in lines('Support04',None,'ACT'))for act,frame in steps),'officer order and subsequent ally shot')
  if 'FinalBlood' in cases:
   original=lines('FocusedSight',31,'MOVEEND')
   require(len({r[5] for r in original if r[6:9]==['True','1','AA_AlertStatusInvalid']})==2,'two flanked alert units with a charge were rejected before the repair')
   levels={(r[3],r[5])for r in lines('FinalBlood',31,'BLOODLEVEL')}
   require({('0','AA_AlertStatusInvalid'),('1','AA_AlertStatusInvalid'),('2','AA_Success')}<=levels,'Blood Tide honors alert levels 0, 1, and 2')
   spent=[r for r in lines('FinalBlood',31,'BLOODACT') if r[3]==r[4] and r[5]=='1,0']
   actual=lines('FinalBlood',31,'ACT')
   owners={r[3] for r in spent};require(len(owners)==2,'two separate reaction charges spent exactly once')
   for e in spent:
    reaction=next(r for r in actual if r[2]==e[2] and r[6]==e[3] and r[8]=='ARFMDEAbility_BloodTide')
    require(reaction[5]=='8' and reaction[11]=='0,1','reaction granted an action point during the XCOM turn')
    shots=[r for r in actual if r[6]==e[3] and r[5]=='8' and r[8]=='StandardShot' and 0<int(r[2])-int(e[2])<=10]
    require(any(t[2]==s[2] and t[3]==s[9] and float(t[5].split(',')[1])<float(t[5].split(',')[0]) for s in shots for t in lines('FinalBlood',31,'TARGET')),'same unit used the granted point and injured a soldier')
  if 'FinalBlood' in cases:
   setup=lines('FinalBlood',59,'BINDINPUT');require(len(setup)>=1 and setup[0][4]=='True','bound fixture used an actual, legal binding action')
   keeper,victim=setup[0][2:4]
   crush=[r for r in lines('FinalBlood',59,'ACT') if r[5]=='16' and r[6]==keeper and r[9]==victim and r[8]=='MZ_FDAdderRushAndBind_Crush']
   dmg={r[2]:r[5] for r in lines('FinalBlood',59,'TARGET') if r[3]==victim}
   require(len({r[4] for r in crush if r[2] in dmg and float(dmg[r[2]].split(',')[0])-float(dmg[r[2]].split(',')[1])==6})>=3,'same unit remained bound and took six crush damage on three actual alien turns')
   for nm in ['CommanderVIP','StasisSuitVIP']:
    changes=[r for r in lines('FinalBlood',60,'VIPSTEP') if r[5]==nm and r[3]=='1' and r[6]=='2,0' and r[7].partition('>')[0]==r[7].partition('>')[2] and 'eGameRule_SkipTurn' in r[8]]
    require(len({r[2]for r in changes})==2,nm+' completed two stationary neutral turns')
  if 'FinalSingleBind' in cases:
   rs=lines('FinalSingleBind',61,'ACT')
   starts=[r for r in rs if r[5]=='16' and r[8]=='MZ_FDAdderRushAndBind']
   for start in starts:
    later=[r for r in rs if r[6]==start[6] and r[9]==start[9] and r[5]=='16' and int(r[2])>int(start[2])]
    binds=[r for r in later if r[8]=='MZ_FDAdderRushAndBind_Bind']
    crushes=[r for r in later if r[8]=='MZ_FDAdderRushAndBind_Crush']
    if binds and any(int(crush[2])>int(binds[0][2]) and int(crush[4])>int(start[4]) for crush in crushes):break
   else:raise ValueError('natural Adder rush did not lead to binding and next-turn crushing on the same soldier')
   require(not lines('FinalSingleBind',61,'BINDINPUT'),'native Adder bound and crushed a single soldier without a fixture activation')
  flush=[r for r in lines('PostRevision',32,'XCOMFLUSH') if r[5]=='eHit_Success']
  require(any(r[6]==h[4] and r[7]=='ChosenWarlockM3' and r[8]=='StandardMove' and r[5]!='16' and int(r[2])>int(h[2]) for h in flush for r in lines('PostRevision',32,'ACT')),'Warlock displaced in reaction to a successful XCOM Flush')
if __name__=='__main__':run(Path(sys.argv[1]) if len(sys.argv)>1 else Path('EnemyTurns_rev006.zip'))
