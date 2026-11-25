from pathlib import Path
import csv,json
v=Path(__file__).parent;o=v/'Evidence';d=o/'release-roll'
def get(a,n):return json.loads((a/n).read_text('utf-8-sig'))
def keys(a,n,cols):
 with (a/n).open(encoding='utf-8-sig',newline='')as f:return {tuple(r[k] for k in cols) for r in csv.DictReader(f)}
c=get(d,'chosen-checks.json');p=get(d,'poison-checks.json');g=get(d,'forecast-checks.json')
bc=get(o,'chosen-checks.json');bp=get(o,'poison-checks.json');bg=get(o,'forecast-checks.json')
inventory={}
for name,cols in [('chosen-combinations.csv',['직책','캡스톤','키스톤','로드스톤']),('chosen-forecasts.csv',['직책','순번']),('poison-pairs.csv',['대상','A','B']),('poison-multi.csv',['대상','방향'])]:
 a=keys(o,name,cols);b=keys(d,name,cols);inventory[name]={'old':len(a),'new':len(b),'keys_equal':a==b}
fields=['roster','buttons','singles_considered','single_deltas','same_unit_pairs','observed_directions','possible_campaign_directions','ordered_list_differences','multis','max_simultaneous']
data={'inventory':inventory,'matrix':{k:[bp[k],p[k]] for k in fields},'grants':[bc['native_records'],c['native_records']],'forecasts':[bg['paired'],g['paired']],'control_count':g['individual_controls'],'tested_per_role':g['per_role'],'gather_failed':c['failed'],'forecast_diff':g['order_diff'],'forecast_invalid':g['invalid'],'poison_failed':p['all_bad']+p['multi_failed']+p['equip_failed']+p['truncated'],'stable':all(r['keys_equal'] for r in inventory.values()) and all(bp[k]==p[k] for k in fields)}
(o/'release-regression.json').write_text(json.dumps(data,ensure_ascii=False,indent=2),'utf8')
print(data['stable'],[(k,r['new'])for k,r in inventory.items()])
