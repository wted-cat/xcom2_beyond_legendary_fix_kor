# Beyond legendary fix for korea user

XCOM 2 선택된 자의 전쟁에서 **Requiem Legion: Coarse Edition**의 적 AI와 **Totally Reasonable Definitely Not Psychotic Tedjam Plugin**의 병력·스토리 임무·최종 요새 수정을 함께 적용하는 LWOTC용 모드입니다.

**플레이용 버전은 rev005입니다.** 

## 설치 및 실행 방법

1. 다음 모드와 관련된 모드들이 구독된 상태여야만 합니다. 일반적인 Beyond Legendary 환경인 경우, 누락된 모드가 있는지만 확인하면 됩니다.

- [Long War of the Chosen](https://steamcommunity.com/sharedfiles/filedetails/?id=2663990965)

- [Ted Jam+ Collection Meta Mod](https://steamcommunity.com/sharedfiles/filedetails/?id=3310018472)

- [Requiem Legion: Coarse Edition](https://steamcommunity.com/sharedfiles/filedetails/?id=3555944655)

- [A Requiem For Man: Gameplay Mutators](https://steamcommunity.com/sharedfiles/filedetails/?id=2795578857)

- [A Requiem For Man: ADVENT Pack](https://steamcommunity.com/sharedfiles/filedetails/?id=3512490242)

- [Tedster's Requiem Legion Tweaks Coarse Edition](https://steamcommunity.com/sharedfiles/filedetails/?id=3744810123)

- [Totally Reasonable Definitely Not Psychotic Tedjam Plugin](https://steamcommunity.com/sharedfiles/filedetails/?id=3835619377)

이 모드 자체에서 요구하는 정확한 필수, 충돌 모드 ID는 설정 파일에 있습니다. [의존성 목록](rev005/CoarseEnemyAIAndEncounters/Config/XComGame.ini)
현재 의존성 모드에 +IncompatibleMods(충돌 모드) 로 등록된 항목은 현재 모드를 생성하기 전 테스트에 사용한 모드들의 리스트로, 일반적인 경우 문제가 없습니다.

2. release의 fix_release_rev005을 클릭한 다음, AI_Encounter_Fixes_rev005.zip 파일을 다운로드 합니다. 만약 이전 버전을 테스트 하고 싶은 경우 해당 소스 디렉터리를 직접 다운로드 합니다.

3. zip 파일의 압축을 풀면 'CoarseEnemyAIAndEncounters' 디렉터리가 생성됩니다. 필요한 경우 적절한 경로로 이동합니다.

4. AML을 실행 후, Options > Settings에 압축을 푼 CoarseEnemyAIAndEncounters 디렉터리 경로를 추가합니다.

5. 모드의 런쳐 내부 식별자는 'CoarseEnemyAIAndEncounters' 입니다. AML에서 경로를 등록해도 인식하지 않는 경우, Refresh를 클릭하거나 재시작을 합니다.

6. 게임을 실행한 후, 전설 난이도와 세컨드 웨이브 옵션 **That Perilous Yearning**을 선택합니다.

## 버전별 보고서 (세부 보고서 내용는 AI로 작성되어 있습니다.)

| 버전 | 주요 내용 | 검증 기록 |
|---|---|---|
| rev005 | 실제 적 턴의 능력·표적 선택, Bashar 장비 21종과 행동력 환급 | [적 턴 45턴과 장비별 행동표](reports/ModReport_CoarseEnemyAIAndEncounters_rev005.md) |
| rev004 | TPY 카드 효과, 조우 목록·일정 복구, 헌터 M3 회전 경고 재현 | [168개 버튼·18개월 경로·임무 검증](reports/ModReport_CoarseEnemyAIAndEncounters_rev004.md) |
| rev003 | TPY 선택지, 선택받은 자의 능력·무기·후속 행동, Bashar 강화 | [전설 캠페인과 전술 전투](reports/ModReport_CoarseEnemyAIAndEncounters_rev003.md) |
| rev002 | rev001 시작 오류, Frost·Raptor 행동, 난이도별 장비와 Omega 편성 | [실게임 대조와 요새 추첨](reports/ModReport_CoarseEnemyAIAndEncounters_rev002.md) |
| rev001 | Coarse 적 AI와 Tedjam 일반 병력·스토리 임무·요새 포털 최초 통합 | [초기 구현과 SDK 검사](reports/ModReport_CoarseEnemyAIAndEncounters_rev001.md) |

rev001은 초기 구현을 비교할 수 있도록 보관한 버전입니다. 당시 SDK 검사 54건은 통과했으나 같은 바이너리는 후속 실게임 시험에서 시작 중 종료됐습니다. rev002에서 원인을 수정하고 전술 전투 진입을 확인했습니다.

각 버전 폴더에는 해당 시점의 설정, UnrealScript 소스, 컴파일 패키지가 들어 있습니다. 보고서는 검증 당시 수행한 정적 검토, SDK 검사, 실제 게임 관찰과 미실행 사례를 구분합니다. [GitHub 배포 파일 검증](reports/ModReport_rev001-rev005_GitHub.md)
