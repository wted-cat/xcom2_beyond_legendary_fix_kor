from collections import Counter,defaultdict
from functools import lru_cache
from pathlib import Path
import json,sys
from audit_schedules import collect,words,loaddecl,arr
def audit(base,detail,taglog=None):
 data=collect(base); sample=collect(detail); flags=collect(taglog) if taglog else {}
 enc={};bkt={}
 for x in data['ENC']:enc.setdefault(x[1].casefold(),x)
 for x in data['BUCKET']:bkt.setdefault(x[1].casefold(),x)
 cycles=set()
 @lru_cache(None)
 def allowed(key,fl,alert,tags,parents=()):
  if key in parents:cycles.add(key);return frozenset()
  if key in bkt:
   b=bkt[key];possible=set()
   for v in words(b[-1]):
    candidate,include,exclude=v.split(':')
    if include!='none' and include not in tags or exclude!='none' and exclude in tags:continue
    can=allowed(candidate,fl,alert,tags,parents+(key,))
    possible.update(can)
    if can and b[2].casefold()=='false':break
   return frozenset(possible)
  if key in enc:
   r=enc[key]
   if int(r[3])<=fl<=int(r[4]) and int(r[5])<=alert<=int(r[6]):return frozenset([key])
  return frozenset()
 gridtags=tuple(sorted(words(flags.get('GRIDHQ',[['','']])[0][1])))
 errs=[];n=blank=portal=portalblank=0;holes=Counter();tagmiss=[];kind=Counter();nogap=Counter()
 for b,f,al,g,bs in sample['GRID']:
  f=int(f);al=int(al);k=b.casefold();g=g.casefold()
  can=allowed(k,f,al,gridtags)
  if (g=='none')!= (not can) or (g!='none' and g not in can):errs.append([b,f,al,g,sorted(can)])
  if k.startswith('etp_'):
   n+=1;blank+=int(g=='none')
   ref=k[4:-7] if k.endswith('_select') else ''
   if g=='none' and ref and ref in enc and allowed(ref,f,al,gridtags):holes[k]+=1
   if (k.startswith('etp_original_') and ref==''):nogap[k]+=1
  else:portal+=1;portalblank+=int(g=='none')
 for b,j,c,p,fl,al,s,actual in flags.get('TAGDRAW',[]):
  tags=tuple(sorted(words(s)));key=b.lower();actual=actual.lower();choices=allowed(key,int(fl),int(al),tags)
  if (actual=='none')!=(not choices) or actual!='none' and actual not in choices:tagmiss.append([b,j,c,p,fl,al,tags,actual,sorted(choices)])
  kind[b]+=1
 assert n==93*108 and portal==6*108 and len({tuple(v[:3])for v in sample['GRID']})==n+portal
 if taglog:assert int(flags['TAGEND'][0][0])==sum(kind.values()) and len(kind)>5
 spec=loaddecl()
 pool=['ahwlegate','ahwmechapede','ahwberserkermagnat4','ahwincubatormagnat4','ahwheavymechtoidt4','ahwcyberdisct4']
 replace={a['encounterbucketid']:a for a in spec['replacementencounterbuckets']};variants={};bad=[];orderbad=[];checked={}
 for k,v in replace.items():
  r=bkt[k];canonical=[s['encounterid']for s in arr(v,'encounterids')]
  ref=[f'fslr_{name}_{unit}'for name in canonical for unit in pool] if ('avatarteam' in k or 'purgeteam' in k)else canonical
  got=[x.split(':')[0]for x in words(r[-1])]
  if ref!=got or v['randomizedselection']!=r[2].casefold():orderbad.append(k)
  checked[k]=len(ref)
 for k in ('list_finalshowdown_purgeteam','list_finalshowdown_avatarteam','list_finalshowdown_dualavatarteam'):
  declared=words(bkt[k][-1])
  for e in declared:
   vid,inc,exc=e.split(':');unit=next((u for u in pool if vid.endswith('_'+u)),None)
   if unit is None or not vid.startswith('fslr_'):bad.append(vid);continue
   orig=vid[5:-(len(unit)+1)];v=enc[vid];o=enc[orig];prior=words(o[-1]);after=words(v[-1])
   if (not prior or int(o[2])!=len(prior) or int(v[2])!=len(prior)+1 or after!=prior+[unit+':true'] or v[3:9]!=o[3:9]):bad.append(vid)
   variants.setdefault((k,orig),[]).append(unit)
 for key,row in variants.items():
  if row!=pool:orderbad.append(key)
 ms={v[0].lower():words(v[2])for v in data['MISSION']};schedules={v[1].casefold() for v in data['SCHED']};fixes={}
 for family,old,new in [('supplyextraction_lw','guerilla_d23_2_lw','guerilla_d22_2_lw'),('bigsupplyextraction_lw','guerilla_d23_2_lw','guerilla_d22_2_lw'),('smashngrab_lw','guerilla_revealed_d23_2_lw','guerilla_revealed_d22_2_lw'),('gathersurvivors','resistanceops_d1_gathersurvivorspa','resistanceops_d1_gathersurvivors')]:
  fixes[family]=[old not in ms[family],new in schedules,ms[family].count(new)]
 betray=spec['arrmissions'][0];assert ms[betray['missionname']]==arr(betray,'missionschedules')
 return dict(etp_total=n,valid_nonempty=n-blank,valid_empty=blank,portal_grid=portal,portal_grid_blank=portalblank,grid_differences=errs,current_tags=gridtags,holes_in_original=dict(holes),tag_trials=sum(kind.values()),tag_buckets=dict(kind),tag_errors=tagmiss,cycles=sorted(cycles),replacements=checked,fixed_variants=sum(map(len,variants.values())),late_base_pods=len(variants),variant_order_errors=orderbad,variant_errors=bad,schedule_repair=fixes,betrayal_schedules=len(ms[betray['missionname']]))
if __name__=='__main__':
 d=audit(*map(Path,sys.argv[1:]));Path(__file__).with_name('NativeChecks.json').write_text(json.dumps(d,indent=1),encoding='utf8')
 print({k:(v[:3] if k.endswith(('differences','errors')) else v) for k,v in d.items()})
