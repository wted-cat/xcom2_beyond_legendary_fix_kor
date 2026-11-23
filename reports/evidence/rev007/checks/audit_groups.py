from collections import Counter,defaultdict
from pathlib import Path
import sys,json
from audit_schedules import collect,loaddecl,words
def examine(base,log):
 ref=collect(base);runs=collect(log);authored=loaddecl()
 req={v["encounterid"] for v in authored["configurableencounters"]}
 bases=["sabotagecc_patrolx3","gp_broadcast_guards_hard","gp_fortress_midboss_01c_lw_tj"]
 by={}
 for r in ref["ENC"]:by.setdefault(r[1].lower(),r)
 expected=req|set(bases);dup=Counter();bad=[];odd=[];ss=Counter();choice=Counter();absent=[];over=[]
 for name,j,f,a,cap,forced,types,roster in runs['GROUPDRAW']:
  k=name.casefold();dup[(k,j)]+=1; rr=by[k];maxcount=int(cap);before=[s.split(':')[0]for s in words(rr[-1])];arr1=words(types);arr2=words(roster)
  assert maxcount==int(rr[2]) and int(forced)==len(before)
  real=arr2
  auxiliary_expected=real[1:] if before else real
  if arr1!=auxiliary_expected:bad.append([k,j,'character templates output',arr1,auxiliary_expected])
  if 'none' in real:absent.append([k,j,real])
  ss[len(real)-maxcount]+=1;choice[('templates'if arr1 else '')+(' names'if arr2 else '')]+=1
  if len(before)>maxcount:over.append([k,j,maxcount,before,real])
  if (not real and maxcount>0) or real[:len(before)]!=before or len(real)!=max(maxcount,len(before)):odd.append([k,j,maxcount,before,real])
 assert runs['GROUPEND'] and int(runs['GROUPEND'][0][0])==2*len(expected)
 assert set(dup)=={(k,j)for k in expected for j in ('0','1')}and set(dup.values())=={1}
 overcontrols={name:(cap,len(roster)) for name,case,cap,fixed,roster in over if name in bases}
 control_errors=[]
 for name,case,cap,fixed,roster in over:
  if name in bases:continue
  parent=next((b for b in bases if name.startswith('etp_'+b+'_fl')),None)
  if parent is None or overcontrols.get(parent)!=(cap,len(roster)):control_errors.append([name,case,parent])
 assert len(overcontrols)==3 and len({k[0] for k in over if k[0]not in bases})==8
 return dict(control_errors=control_errors,declared=len(req),source_controls=len(bases),native_samples=len(dup),length_minus_configured_max=dict(ss),output_arrays=dict(choice),empty_templates=absent,array_mismatches=bad,overdeclared_fixed_slots=over,observed_exceptions=odd)
if __name__=='__main__':
 x=examine(*map(Path,sys.argv[1:]));Path(__file__).with_name('GroupChecks.json').write_text(json.dumps(x,indent=1),encoding='utf8');print([(k,(len(v) if k in ['array_mismatches','overdeclared_fixed_slots','observed_exceptions']else v))for k,v in x.items()]);print('first exceptions',x['observed_exceptions'][:3])
