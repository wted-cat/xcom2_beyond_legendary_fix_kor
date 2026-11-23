# rev007 전술·편성 검증 자료

상위 reports 폴더의 rev007 보고서에 대응한다. 설치 파일은 별도 배포한 AI_Encounter_Fixes_rev007.zip이다.

- logs에는 게임이 출력한 검증 기록, 로드한 Highlander 버전, 병력표 정리 기록을 담았다. 번호는 같은 파일 안에서 비교한다. R6는 이전부터 사용한 전술 관찰 형식, R7은 이번에 추가한 관찰 형식이다.
- MultiBindGrid는 rev007의 집중 전투 배치 80~91, 61, 28, 95, 96, 32와 임무 관리자의 추첨·배치 기록이다. RosterBind는 전체 설정표와 경계 조건이다. IndividualSkills, ExtractVIP, DefenseRetest는 rev006 대조군이다. StasisObjective와 VIPControl은 rev007 설치본이다. VIPControl은 실제 철수 지점이 있는 구출 임무에서 중립 VIP, 적 팀으로 바꾼 대조군, 피의 조류·시나님·니븐을 관찰했다. DefenseBranch는 첫 적 턴 전 임무 종료, FinalCandidate와 WarlockCover는 플레이어 턴 진행 지연을 기록한 초기 시도다.
- fixtures에는 별도 게임에서 사용하는 관찰 모듈의 최종 소스와 설정을 넣었다. 빌드 환경은 WotC SDK와 활성 Highlander를 사용한다. 이전 배치별 모듈에는 이후 추가한 기록 항목이 없을 수 있다. 지정 분기는 실제 적 턴에서 해당 분기만 진입점으로 삼는다.
- checks에는 비교 도구, 입력별 측정치, 대조 결과, 설치 ZIP 구성 파일의 SHA-256이 있다. 보관된 rev006 전술 로그를 다시 검사한 결과는 rev006_regression.txt에 있다. 원시 rev006 전술 자료는 별도의 EnemyTurns_rev006.zip에 있다.

Python 3에서 독자적으로 대조하려면 이 자료와 설치 ZIP을 각각 풀고, 모드 폴더 CoarseEnemyAIAndEncounters를 checks/Baseline/에 둔다. 자료 최상위 디렉터리에서 아래 명령을 실행하면 제공된 기록을 다시 판정할 수 있다.

```text
python checks/audit_schedules.py logs/RosterBind.log
python checks/audit_native.py logs/RosterBind.log logs/MultiBindGrid.log logs/StasisObjective.log
python checks/audit_detail.py logs/RosterBind.log logs/MultiBindGrid.log logs/DefenseRetest.log
python checks/audit_groups.py logs/RosterBind.log logs/StasisObjective.log
python checks/summarize_fields.py logs
```

SHA256.json은 파일 무결성을 확인할 때 사용한다.
