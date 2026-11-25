from pathlib import Path
from collections import Counter,defaultdict
import json,csv,re,sys
V=Path(__file__).parent;O=V/'Evidence';f=V/'Logs'/((sys.argv[1] if len(sys.argv)>1 else 'ExtraRoster')+'.log')
def read(f):
 b=f.read_bytes();return b.decode('utf-16' if b[:2] in (b'\xff\xfe',b'\xfe\xff') else 'utf-8-sig','replace')
def val(s):return Counter(x for x in s.removesuffix('!END!').split(',')if x)
src=read(V/'Baseline/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningEquipment.uc')
pools={mode:set(re.findall(r'\b'+pool+r'Pool\(\d+\)=(\w+)',src)) for mode,pool in [('33','Elite'),('34','Unique'),('35','Mundane'),('general','General')]}
a=json.loads(read(V/'poison_cards.json'))
allow=lambda i,j:max(int(a[i]['min'])+1,int(a[j]['min']))<=int(a[j]['maximum'] or 1000)
bs={};gs={};cs={};pairs={};miss=[];draws=[];pr=[];done=False;badframes=[]
for l in read(f).splitlines():
 if 'R6|FINISHED|' in l:done=True
 if 'R8|BASHAR' not in l:continue
 x=l.split('R8|',1)[1].split('|');kind=x[0]
 if kind in ('BASHARBASE','BASHARGEARSINGLE','BASHARCARD','BASHARPAIR') and not x[-1].endswith('!END!'):badframes.append(x[:4]);continue
 if kind=='BASHARBASE':bs[x[1]]=val(x[2])
 if kind=='BASHARGEARSINGLE':gs[x[1],x[2],x[3]]=val(x[4])
 if kind=='BASHARCARD':cs[x[1],x[2]]=val(x[3])
 if kind=='BASHARPAIR':pairs[x[1],x[2],x[3],x[4],int(x[5])]=val(x[6])
 if kind=='BASHARGEARMISSING':miss.append(x[1:])
 if kind=='BASHARDRAW':
  u,mode,pos,roll,result=x[1:];should=pos in (('0','1') if u=='AHWMutonMagna' else ('0','1','4'));draws.append([u,mode,pos,roll,result,(result in pools['general' if u=='AHWMutonMagna' else mode]) if should else result in ('None','')])
 if kind=='BASHARPAIRPOOL':
  u,mode,card,order,result=x[1:];pr.append([u,mode,card,order,result,result in pools['general' if u=='AHWMutonMagna' else mode]])
rows=[];bad=[]
for (u,mode,gear),equip in sorted(gs.items()):
 for (unit,card),single in cs.items():
  if u!=unit:continue
  base=bs[u];ex=(base-((base-single)|(base-equip)))+((single-base)|(equip-base))
  left=pairs.get((u,mode,gear,card,0));right=pairs.get((u,mode,gear,card,1))
  r=[u,mode,gear,card,a[int(card)]['callback'],allow(int(mode),int(card)),allow(int(card),int(mode)),left is not None and right is not None,left==right,left==ex,right==ex]
  rows.append(r)
  if not all(r[7:]):bad.append(r)
def out(n,h,ls):
 with (O/n).open('w',encoding='utf-8-sig',newline='')as f:
  w=csv.writer(f);w.writerow(h);w.writerows(ls)
out('bashar-gear-card-pairs.csv',['뮤톤','승격 선택','실제 장비','다른 선택','콜백','승격 먼저 월 가능','다른 카드 먼저 월 가능','양방향 실행','구성 동일','승격 먼저 기대 일치','다른 카드 먼저 기대 일치'],rows)
out('bashar-draws.csv',['뮤톤','승격 선택','조건 단계','승격 판정 난수','추첨 결과','해당 풀 또는 미승격 기대 일치'],draws)
out('bashar-pair-draws.csv',['뮤톤','승격 선택','다른 선택','순서','추첨 결과','승격 풀과 일치'],pr)
su={'completed':done,'units':list(bs),'physical_items':len(set(k[2] for k in gs)),'choices_per_unit':dict(Counter(u for u,k in cs)),'pairs':len(rows),'directions':len(pairs),'failed':bad,'draws':len(draws),'draw_failed':[x for x in draws if not x[-1]],'pair_draws':len(pr),'pair_draws_failed':[x for x in pr if not x[-1]],'gear_missing':miss,'truncated':badframes,'pools':{k:sorted(v)for k,v in pools.items()}}
(O/'bashar-checks.json').write_text(json.dumps(su,ensure_ascii=False,indent=2),encoding='utf8')
print(su['physical_items'],len(rows),len(pairs),len(bad),len(miss),len(su['draw_failed']))
