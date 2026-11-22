# LWOTC Coarse - Enemy AI and Encounters

XCOM 2 선택된 자의 전쟁에서 **Requiem Legion: Coarse Edition**의 적 AI와 **Totally Reasonable Definitely Not Psychotic Tedjam Plugin**의 병력·스토리 임무·최종 요새 수정을 함께 적용하는 LWOTC용 모드입니다.

**플레이용 버전은 rev005입니다.** 전설에서 That Perilous Yearning(TPY)을 켜면 Bashar 뮤톤이 장착한 장비와 사격 가능 여부를 첫 행동에 반영합니다. 선택받은 자의 특수 능력, 카드 강화 효과, 임무별 병력 편성에는 rev004까지의 수정도 함께 적용됩니다. [rev005 모드](rev005/CoarseEnemyAIAndEncounters/) · [전체 변경 이력](CHANGELOG.md)

## 설치

1. rev001부터 rev005까지 들어 있는 압축 파일을 풀거나 저장소를 내려받습니다. 런처의 로컬 모드 검색 경로에 **rev005** 폴더를 Workshop 경로 다음으로 추가합니다. 그 안에 `CoarseEnemyAIAndEncounters/CoarseEnemyAIAndEncounters.XComMod`가 있습니다.
2. 다섯 버전의 런처 식별자는 모두 `CoarseEnemyAIAndEncounters`입니다. 이전 버전 경로를 빼고 목록을 새로 고친 뒤 **LWOTC Coarse - Enemy AI and Encounters**의 위치가 rev005인지 확인합니다.
3. WotC Community Highlander, LWOTC, Ted Mod Jam for LWOTC, Requiem Legion: Coarse Edition(3555944655), ARFMDarkEvents(2795578857), ARFMAdventPack, 원본 Tedjam 플러그인(3835619377)을 함께 켭니다. 이전에 독립 AI·요새 패치를 썼다면 중복 항목을 끕니다. 런처에서 쓰는 정확한 필수·충돌 모드 ID는 설정 파일에 있습니다. [의존성 목록](rev005/CoarseEnemyAIAndEncounters/Config/XComGame.ini)
4. 게임을 다시 시작합니다. rev005의 TPY 검증 조건을 재현하려면 전설 난이도와 세컨드 웨이브 옵션 **That Perilous Yearning**을 선택합니다. Tedjam의 스토리 편성은 해당 임무를 생성하기 전 전략 저장에서 확인할 수 있습니다.

## 버전별 보고서

| 버전 | 주요 내용 | 검증 기록 |
|---|---|---|
| rev005 | 실제 적 턴의 능력·표적 선택, Bashar 장비 21종과 행동력 환급 | [적 턴 45턴과 장비별 행동표](reports/ModReport_CoarseEnemyAIAndEncounters_rev005.md) |
| rev004 | TPY 카드 효과, 조우 목록·일정 복구, 헌터 M3 회전 경고 재현 | [168개 버튼·18개월 경로·임무 검증](reports/ModReport_CoarseEnemyAIAndEncounters_rev004.md) |
| rev003 | TPY 선택지, 선택받은 자의 능력·무기·후속 행동, Bashar 강화 | [전설 캠페인과 전술 전투](reports/ModReport_CoarseEnemyAIAndEncounters_rev003.md) |
| rev002 | rev001 시작 오류, Frost·Raptor 행동, 난이도별 장비와 Omega 편성 | [실게임 대조와 요새 추첨](reports/ModReport_CoarseEnemyAIAndEncounters_rev002.md) |
| rev001 | Coarse 적 AI와 Tedjam 일반 병력·스토리 임무·요새 포털 최초 통합 | [초기 구현과 SDK 검사](reports/ModReport_CoarseEnemyAIAndEncounters_rev001.md) |

rev001은 초기 구현을 비교할 수 있도록 보관한 버전입니다. 당시 SDK 검사 54건은 통과했으나 같은 바이너리는 후속 실게임 시험에서 시작 중 종료됐습니다. rev002에서 원인을 수정하고 전술 전투 진입을 확인했습니다.

각 버전 폴더에는 해당 시점의 설정, UnrealScript 소스, 컴파일 패키지가 들어 있습니다. 보고서는 검증 당시 수행한 정적 검토, SDK 검사, 실제 게임 관찰과 미실행 사례를 구분합니다. [GitHub 배포 파일 검증](reports/ModReport_rev001-rev005_GitHub.md)
