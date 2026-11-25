from pathlib import Path
import csv,json
v=Path(__file__).parent
out=v/'Evidence'
cards=json.loads((v/'poison_cards.json').read_text('utf-8-sig'))
raw=(v/'Logs'/('RollAfter.log' if (v/'Logs/RollAfter.log').exists() else 'FinalReplay.log')).read_bytes()
s=raw.decode('utf-16' if raw[:2] in (b'\xff\xfe',b'\xfe\xff') else 'utf-8-sig','replace')
def maximum(card):return int(card['maximum'] or 10000)
def read(k):
    key='R8|'+k+'|'
    return [l.split(key,1)[1].split('|') for l in s.splitlines() if key in l]
def export(path,columns,items):
    with (out/path).open('w',encoding='utf-8-sig',newline='') as handle:
        writer=csv.writer(handle);writer.writerow(columns);writer.writerows(items)
first=[];rows=[];committed=[]
for si,sm,accepted,flag,values in read('CHOICEFIRST'):
    i,m=int(si),int(sm)
    first.append([i,m,accepted,flag,values,m==int(cards[i]['min']) and accepted==flag==values=='True'])
for si,sj,sm,srv,accepted,first_flag,next_flag,values in read('CHOICEORDER'):
    i,j,month=map(int,(si,sj,sm))
    expected_month=max(int(cards[i]['min'])+1,int(cards[j]['min']))
    allowed=expected_month<=maximum(cards[j])
    ok=(month==expected_month and (srv=='True')==allowed and (accepted=='True')==allowed and first_flag==next_flag==values=='True')
    rows.append([i,j,cards[i]['callback'],cards[j]['callback'],expected_month,month,allowed,accepted,first_flag,next_flag,values,ok])
for si,sj,sm,accepted,f1,f2,values in read('CHOICESUBMIT'):
    i,j,m=map(int,(si,sj,sm))
    legal=max(int(cards[i]['min'])+1,int(cards[j]['min']))<=maximum(cards[j])
    committed.append([i,j,m,legal,accepted,f1,f2,values,(accepted=='True')==legal and f1=='True' and (f2=='True')==legal and values=='True'])
expected={(i,j) for i,a in enumerate(cards) for j,b in enumerate(cards) if a['card']!=b['card']}
observed={(r[0],r[1]) for r in rows}
export('strategy-first-choices.csv',['선택','실제 월','수락','선택 상태 일치','HQ 일치','통과'],first)
export('strategy-choice-orders.csv',['첫 선택','다음 선택','첫 콜백','다음 콜백','기대 월','실제 월','월 허용 예상','실제 수락','첫 카드 유지','후속 카드 상태','두 강화의 HQ 보존·거절 시 미변경','일치'],rows)
export('strategy-committed-controls.csv',['첫 선택','다음 선택','월','월 허용 예상','둘째 수락','첫 카드 선택됨','둘째 카드 선택됨','제출 후 HQ 일치','통과'],committed)
result={'first':len(first),'directions':len(rows),'unique':len(observed),'allowed':sum(x[6] for x in rows),'denied':sum(not x[6] for x in rows),'first_errors':[x for x in first if not x[-1]],'direction_errors':[x for x in rows if not x[-1]],'missing_directions':len(expected-observed),'unexpected_directions':len(observed-expected),'completed':read('CHOICEDONE')==[['168']],'full_commits':committed,'board':read('CHOICEBOARD'),'errors':read('CHOICEERROR')}
(out/'strategy-callbacks.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf8')
print('strategy',len(first),len(rows),result['allowed'],result['denied'],len(result['direction_errors']),len(committed),result['completed'])
