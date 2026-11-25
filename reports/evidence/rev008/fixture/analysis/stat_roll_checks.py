from pathlib import Path
from collections import Counter
import csv,json
v=Path(__file__).parent;o=v/'Evidence'
def read(f):
 b=f.read_bytes();return b.decode('utf-16' if b[:2] in (b'\xff\xfe',b'\xfe\xff') else 'utf-8-sig','replace')
outs=[];families=[];fire=[];held=[];casts=[];types={};errors=[]
for label,filename in [('before','FinalSupplement'),('final','RollAfter')]:
 f=v/'Logs'/(filename+'.log')
 for line in read(f).splitlines():
  if 'R8|ROLL' not in line:continue
  a=line.split('R8|',1)[1].split('|');k=a[0]
  if k=='ROLLACTUAL':
   _,case,unit,calc,raw,pred,trials,single,area,enabled=a
   raw,pred,trials,single,area=map(int,(raw,pred,trials,single,area))
   card=case=='261';actual_card=enabled=='True'
   def plausible(count):
    bound=raw+(40 if card and label=='final' else 0)
    return count==0 if bound<=0 else (count==trials if bound>=100 else 0<count<trials)
   ok=card==actual_card and pred==raw+40*card and trials==128 and plausible(single) and plausible(area)
   outs.append([label,case,unit,calc,raw,pred,trials,single,area,card,ok])
  if k=='ROLLFAMILY':
   _,case,key,cl,raw,pred,trials,hits=a;raw,pred,trials,hits=map(int,(raw,pred,trials,hits))
   wanted=raw+(40 if case=='261' else 0)
   ok=pred==wanted and trials==128 and (hits==0 if wanted<=0 else hits==trials if wanted>=100 else 0<hits<trials)
   families.append([case,key,cl,raw,pred,trials,hits,ok])
  if k=='ROLLFIRE':fire.append(a[1:]+[a[-2]==a[-1]])
  if k=='ROLLHELD':held.append([label,*a[1:]])
  if k=='ROLLCAST':casts.append([label,*a[1:]])
  if k=='ROLLTYPE':types.setdefault(label,{})[a[1]]=a[2]
  if k=='ROLLERROR':errors.append([label,*a[1:]])
def csvout(name,cols,rows):
 with (o/name).open('w',encoding='utf-8-sig',newline='')as f:
  wr=csv.writer(f);wr.writerow(cols);wr.writerows(rows)
csvout('stat-actual-rolls.csv',['수정 전후','배치','유닛','실제 계산기','카드 제외 판정','예측','시행','단일 성공','복수 표적 성공','카드','기대 일치'],outs)
csvout('stat-other-rolls.csv',['배치','기술','계산기','카드 제외 판정','예측','시행','성공','기대 일치'],families)
csvout('stat-calculator-inventory.csv',['수정 전후','전설 기술','계산기'],[(k,a,t) for k,ids in types.items() for a,t in sorted(ids.items())])
data={'primary_multi_rows':outs,'family_rows':families,'fire_exceptions':fire,'held':held,'cast_inputs':casts,'type_counts':{k:dict(Counter(v.values()))for k,v in types.items()},'errors':errors,'bad':[r for r in outs+families+fire if not r[-1]]}
(o/'actual-stat-rolls.json').write_text(json.dumps(data,indent=2,ensure_ascii=False),'utf8')
print(len(outs),len(families),len(fire),len(errors),len(data['bad']))
