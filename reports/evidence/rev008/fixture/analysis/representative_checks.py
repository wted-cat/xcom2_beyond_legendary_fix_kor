from pathlib import Path
import csv,json,collections,re,sys
V=Path(__file__).parent;O=V/'Evidence'
def rd(f):
 b=f.read_bytes();return b.decode('utf-16' if b[:2] in (b'\xff\xfe',b'\xfe\xff') else 'utf-8-sig','replace')
profile=json.loads(rd(V/'poison_units.json'))
picks={u for n,units in profile['cases'] if n in range(210,220) for u in units.split('~')}
sources=['PoisonOrder','FinalInteractions','RollAfter']
records={};summary={}
for n in sources:
 registry_session='CatalogLoot' if n=='RollAfter' else n
 f=V/'Logs'/(registry_session+'.log')
 if not f.exists():continue
 groups=collections.defaultdict(list);seen={}
 for l in rd(f).splitlines():
  if 'R8|CHAR|' not in l:continue
  vals=l.split('R8|CHAR|')[1].split('|')
  if len(vals)<6:continue
  k=vals[0];seen[k]=tuple(sorted(v for v in vals[5].split(',') if v.lower().startswith(('arfm','tpy'))))
 for k,sig in seen.items():groups[sig].append(k)
 covered=set()
 for lab in (['FinalInteractions','ExtraRoster','FinalSupplement'] if n=='FinalInteractions' else [n]):
  raw=V/'Logs'/(lab+'.log')
  if not raw.is_file():continue
  completed=set();staged={}
  for line in rd(raw).splitlines():
   if 'R8|PYBASE|' in line:
    case,unit,_=line.split('R8|PYBASE|',1)[1].split('|',2);staged.setdefault(case,set()).add(unit)
   if 'R8|PYDONE|' in line:
    case,count=line.split('R8|PYDONE|',1)[1].split('|')[:2]
    if int(count)==len(staged.get(case,())):completed.add(case)
  for case in completed:covered.update(staged[case])
 picks=covered
 missing=[v for v in groups.values() if not set(v)&picks];summary[n]={'registry_session':registry_session,'templates':len(seen),'sorted_ability_signatures':len(groups),'representatives':len(picks),'signatures_without_a_representative':missing}
 records[n]=[(n,i,','.join(sorted(set(items)&picks)),len(items),','.join(sorted(items)),','.join(sig)) for i,(sig,items) in enumerate(sorted(groups.items()))]
with (O/'roster-representation.csv').open('w',newline='',encoding='utf-8-sig')as f:
 w=csv.writer(f);w.writerow(['시험','유형','대표 유닛','템플릿 수','같은 직접 부여 구성을 가진 캐릭터','대상 이름으로 시작하는 능력 목록']);w.writerows(x for ls in records.values() for x in ls)
(O/'roster-checks.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf8')
print(summary)
