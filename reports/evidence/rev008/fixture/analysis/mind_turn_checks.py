from pathlib import Path
import json

root = Path(__file__).parent
cases = {}
for label, wanted in [('RollConfirm', {263, 264}), ('MindCooldown', {265})]:
    path = root / 'Logs' / (label + '.log')
    raw = path.read_bytes()
    encoding = 'utf-16' if raw.startswith((b'\xff\xfe', b'\xfe\xff')) else 'utf-8-sig'
    record = None
    for line in raw.decode(encoding, 'replace').splitlines():
        if 'R6|CASE|' in line:
            scenario = int(line.split('R6|CASE|')[1].split('|')[1])
            record = None
            if scenario in wanted:
                record = {'session': label, 'ready': {}, 'cast': [], 'enemy_abilities': [], 'fire': [], 'cooldown_check': [], 'finished': False}
                cases[scenario] = record
        if record is None:
            continue
        if 'R8|MINDREADY|' in line:
            _, owner, target, attack, defense, score, cooldown = line.split('R8|MINDREADY|')[1].split('|')
            record['ready'][target] = {'caster': int(owner), 'attack': int(attack), 'defense': int(defense), 'score': int(score), 'cooldown': int(cooldown)}
        if 'R8|MINDCOOLDOWN|' in line:
            _, ability, cooldown, availability, target_count = line.split('R8|MINDCOOLDOWN|')[1].split('|')
            record['cooldown_check'].append({'ability': int(ability), 'cooldown': int(cooldown), 'availability': availability, 'available_targets': int(target_count)})
        if 'R8|MINDTURN|' in line:
            _, frame, turn, team, owner, target, result, tier = line.split('R8|MINDTURN|')[1].split('|')
            if int(turn) > 0 and team == '16':
                record['cast'].append({'frame': int(frame), 'target': target, 'caster': int(owner), 'result': result, 'tier': int(tier)})
        if 'R8|MINDFIRE|' in line:
            _, skill, unit, fear, hit = line.split('R8|MINDFIRE|')[1].split('|')
            record['fire'].append({'skill': skill, 'target': unit, 'fear': fear == 'True', 'hit': hit == 'True'})
        if 'R6|ACT|' in line:
            event = line.split('R6|ACT|')[1].split('|')
            if event[5] == 'Sectoid' and event[3] == '16' and int(event[1]) > 0:
                record['enemy_abilities'].append([int(event[0]), event[6], event[7]])
        if 'R6|CASEFINISHED|' in line:
            record['finished'] = int(line.split('R6|CASEFINISHED|')[1].split('|')[0]) == scenario
for scenario, record in cases.items():
    ready = record['ready']
    checks = {
        'completed': record['finished'], 'present_targets': bool(ready),
        'score': all(t['score'] == (60 if scenario == 264 else 100) for t in ready.values()),
        'cooldown': all(t['cooldown'] == (5 if scenario == 265 else 0) for t in ready.values()),
        'fire_classes': len({t['skill'] for t in record['fire']}) == 2,
        'fire_control': all(not t['fear'] and not t['hit'] for t in record['fire']),
    }
    if scenario == 265:
        fresh = record['cooldown_check']
        checks['submitted_cooldown'] = len(fresh) == 1 and fresh[0]['cooldown'] == 5 and fresh[0]['availability'] == 'AA_CoolingDown'
        checks['fallback'] = not record['cast'] and any(action[1] == 'StandardShot' for action in record['enemy_abilities'])
    else:
        checks['cast_at_ready_target'] = bool(record['cast']) and all(action['target'] in ready and ready[action['target']]['caster'] == action['caster'] for action in record['cast'])
        if scenario == 263:
            checks['certain_hit'] = all(action['result'] not in ('eHit_Miss','0') for action in record['cast'])
    record['checks'] = checks
    record['pass'] = all(checks.values())
(root / 'Evidence' / 'mindspin-enemy-turns.json').write_text(json.dumps(cases, ensure_ascii=False, indent=2), encoding='utf8')
print([(n, r['pass'], r['enemy_abilities'][:3], r['cooldown_check'], [k for k,v in r['checks'].items() if not v]) for n,r in cases.items()])
if set(cases) != {263, 264, 265} or not all(r['pass'] for r in cases.values()):
    raise ValueError('Hostile Mindspin, comparison units or cooldown evidence requires review')
