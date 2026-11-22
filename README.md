# Beyond legendary fix for korea user

XCOM 2 선택된 자의 전쟁에서 **Requiem Legion: Coarse Edition**의 적 AI와 **Totally Reasonable Definitely Not Psychotic Tedjam Plugin**의 병력·스토리 임무·최종 요새 수정을 함께 적용하는 LWOTC용 모드입니다.

**플레이용 버전은 rev005입니다.** 전설에서 That Perilous Yearning(TPY)을 켜면 Bashar 뮤톤이 장착한 장비와 사격 가능 여부를 첫 행동에 반영합니다. 선택받은 자의 특수 능력, 카드 강화 효과, 임무별 병력 편성에는 rev004까지의 수정도 함께 적용됩니다. [rev005 모드](rev005/CoarseEnemyAIAndEncounters/) · [전체 변경 이력](CHANGELOG.md)

## 설치 및 실행 방법

1. Long War of the Chosen, Ted Jam+ Collection Meta Mod, Requiem Legion: Coarse Edition,  A Requiem For Man: Gameplay Mutators, A Requiem For Man: ADVENT Pack, Totally Reasonable Definitely Not Psychotic Tedjam Plugin, Tedster's Requiem Legion Tweaks Coarse Edition 과 관련된 모드가 구독된 상태여야 합니다. 런처에서 쓰는 정확한 필수·충돌 모드 ID는 설정 파일에 있습니다. [의존성 목록](rev005/CoarseEnemyAIAndEncounters/Config/XComGame.ini)

2. release에 있는 rev005.zip 파일을 받습니다. 압축을 푼 다음, AML을 실행 후, Options > Settings에 해당 경로를 추가합니다. 만약 이전 버전을 테스트 하고 싶은 경우 해당 소스 디렉터리를 직접 다운로드 합니다.

3. 모드의 런쳐 내부 식별자는 'CoarseEnemyAIAndEncounters' 입니다. AML에서 경로를 등록해도 인식하지 않는 경우, Refresh를 클릭하거나 재시작을 합니다.

4. 전설 난이도와 세컨드 웨이브 옵션 **That Perilous Yearning**을 선택합니다.

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
