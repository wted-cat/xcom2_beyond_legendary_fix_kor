"""Run after extracting the evidence archive. Standard library only."""
from pathlib import Path
from collections import Counter
import csv,hashlib,json,re,sys,zipfile
root=Path(__file__).resolve().parent
def data(name):return json.loads((root/name).read_text(encoding='utf-8-sig'))
def rows(name):
 with (root/name).open(encoding='utf-8-sig',newline='') as f:return list(csv.DictReader(f))
def need(ok,why):
 if not ok:raise ValueError(why)
files=data('files.json')
for n,h in files.items():need(hashlib.sha256((root/n).read_bytes()).hexdigest()==h,n)
gems=rows('chosen-combinations.csv')
keys={(x['직책'],x['캡스톤'],x['키스톤'],x['로드스톤'])for x in gems}
need(len(gems)==len(keys)==1728 and set(Counter(x[0] for x in keys).values())=={576},'Chosen combinations')
need(all(x['일치']=='True' for x in gems),'Chosen grants')
fore=rows('chosen-forecasts.csv')
need(len(fore)==1728 and all(x['입력·범위 정상']==x['순서 일치']=='True' for x in fore),'Chosen forecasts')
fg=data('forecast-checks.json');need(fg['paired']==1728 and fg['individual_controls']==78 and not fg['invalid'] and not fg['order_diff'],'Chosen forecasting inputs')
p=data('poison-checks.json');pairs=rows('poison-pairs.csv')
need(p['roster']==79 and p['buttons']==168 and p['strategy_order_allowed']==23157 and p['singles_considered']==79*168,'PICK YOUR POISON inputs')
need(len(pairs)==p['same_unit_pairs'] and p['observed_directions']==2*len(pairs),'PICK YOUR POISON directions')
need(all(x['양방향 실행']==x['양방향 구성 같음']==x['A→B 기대 일치']==x['B→A 기대 일치']=='True' for x in pairs),'Unit ability and gear')
need(not p['multi_failed'] and not p['equip_failed'] and not p['truncated'],'Multi-card and equipment')
need(len(pairs)==3178 and sum(row[k]=='True' for row in pairs for k in ('A→B 월 가능','B→A 월 가능'))==5231,'Same-unit order and month filtering')
need(sum(row['항목 순서 같음']=='False' for row in pairs)==2,'Order of independent soldier unlocks')
multi=rows('poison-multi.csv')
need(len(multi)==102 and max(int(row['선택 수']) for row in multi)==17 and all(row['기대 일치']==row['양방향 구성 일치']=='True' for row in multi),'Stacked card results')
field=data('poison-field.json');need(len(field)==9 and len({r['unit'] for r in field})==9 and all(all(r[k] for k in ('equipment_equal','abilities_equal','effects_equal','tracked_stats_equal')) for r in field),'Physical reversed card loadouts')
need(data('soldier-unlock-checks.json')['count']==24,'XCOM unlock status counts')
need(all(x['일치']=='True' for x in rows('poison-soldier-modifiers.csv')),'XCOM soldier unlocks')
need(all(x['양방향 실행']==x['효과별 통과 동일']=='True' for x in rows('attack-effect-order.csv')),'Attack effect order')
need(len(rows('attack-effect-card-conditions.csv'))>0 and all(x['일치']=='True' for x in rows('attack-effect-card-conditions.csv')),'Native card conditions')
b=data('permanent-checks.json')
need(b['groups']>0 and not b['duplicate_effects'] and not b['changed_effects'],'Recurring passive initialization')
need(data('battle-summary.json')['chosen_active_witnesses']==15,'Five Chosen actions on three roles')
need(all(y['matching'] for y in data('sectoid-loot-checks.json')) and len(data('sectoid-loot-checks.json'))==4,'Loot state')
need(len(rows('characters.csv'))==31,'ARFM units')
need(len(rows('abilities.csv'))==562,'ARFM/TPY ability inventory')
need(len(rows('poison-options.csv'))==168,'Strategy options')
attachment=data('attachment-outcomes.json')
need(attachment['phase_cases']=={'before':14,'final':14} and not attachment['mismatches'] and not attachment['radius_mismatches'] and not attachment['unit_mismatches'],'Action card effects')
need(not data('roster-checks.json')['FinalInteractions']['signatures_without_a_representative'],'Roster coverage')
stat=data('stat-contest-checks.json');need(len(stat['templates'])==6 and not stat['failed'],'Offensive stat checks')
gear=data('bashar-checks.json');need(gear['completed'] and gear['physical_items']==21 and gear['directions']==2*gear['pairs'] and len(gear['units'])==4 and not any(gear[k] for k in ('failed','draw_failed','pair_draws_failed','gear_missing','truncated')),'Bashar combinations')
strategy=data('strategy-callbacks.json')
need(strategy['completed'] and strategy['first']==168 and strategy['directions']==strategy['unique']==27720 and strategy['allowed']==23157 and strategy['denied']==4563 and len(strategy['full_commits'])==9 and all(r[-1] for r in strategy['full_commits']) and not any(strategy[k] for k in ('first_errors','direction_errors','missing_directions','unexpected_directions','errors')),'Strategy card callbacks and order')
roll=data('actual-stat-rolls.json')
need(len(roll['primary_multi_rows'])==8 and len(roll['family_rows'])==8 and len(roll['fire_exceptions'])==4 and not roll['bad'] and not roll['errors'],'Actual stat rolls')
reg=data('release-regression.json')
need(reg['stable'] and reg['grants']==reg['forecasts']==[1728,1728] and reg['control_count']==78 and not any(reg[k] for k in ('gather_failed','forecast_diff','forecast_invalid','poison_failed')),'Release Chosen and PYP regression')
rs=data('roster-checks.json')['RollAfter'];need(rs['registry_session']=='CatalogLoot' and rs['templates']==895 and rs['sorted_ability_signatures']==77 and rs['representatives']==79 and not rs['signatures_without_a_representative'],'Final package representatives')
mind=data('mindspin-enemy-turns.json');need(set(mind)=={'263','264','265'} and all(r['pass'] for r in mind.values()),'Mindspin hostile turns, cooldown and fire exception')
for case in data('sectoid-loot-checks.json'):
 need(case['ordinary_move'] and case['move_finished_event_replayed'] and len(case['outcomes'])==2,'Loot movement and repeated trigger')
 need(all((item['ground'] in (0,-1) and item['backpack']==1 and item['owner']==case['owner']) if case['case']==239 else (item['ground']==1 and item['backpack']==0 and item['owner']==0) for item in case['outcomes']),'Loot item owner and count')
ready=mind['265']['cooldown_check']
need(mind['265']['session']=='MindCooldown' and len(ready)==1 and ready[0]['cooldown']==5 and ready[0]['availability']=='AA_CoolingDown' and not mind['265']['cast'] and any(a[1]=='StandardShot' for a in mind['265']['enemy_abilities']),'Submitted cooldown and actual next attack')
need(all(int(unit['score'])==100 for unit in mind['263']['ready'].values()) and any(a['result']=='eHit_Success' for a in mind['263']['cast']),'Guaranteed Mindspin')
need(all(int(unit['score'])==60 for unit in mind['264']['ready'].values()) and len(mind['264']['cast'])>=1,'No-card control')
if len(sys.argv)>1:
 path=Path(sys.argv[1]);meta=data('release.json')
 need(hashlib.sha256(path.read_bytes()).hexdigest()==meta['archive'],'Installation archive SHA-256')
 with zipfile.ZipFile(path)as z:
  need(z.testzip() is None and len(z.namelist())==meta['members'],'Installation archive')
  for fname,sha in meta['member_hashes'].items():
   need(hashlib.sha256(z.read('CoarseEnemyAIAndEncounters/'+fname)).hexdigest()==sha,fname)
print('OK',len(keys),'Chosen combinations,',len(pairs),'same-unit choice pairs,',len(files),'evidence files')
