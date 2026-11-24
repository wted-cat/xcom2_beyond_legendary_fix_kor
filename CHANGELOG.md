# rev001–rev008 변경 이력

**LWOTC Coarse - Enemy AI and Encounters**의 버전별 게임 동작과 검증 범위를 정리했습니다. 각 보고서에서 재현 조건과 실제 기록을 확인할 수 있습니다. [설치 안내](README.md)

## rev008 — 선택받은 자의 지속 효과와 위태로운 갈망의 중첩 강화

- **선택받은 자.** 생성 때 같은 보석·헌신의 지속 효과가 여러 번 붙어 행동력이 불어나던 문제를 고쳤습니다. 권능과 변화의 헌신도 표적의 엄폐에 맞춰 명중·치명타를 보정합니다.
- **적의 전술 행동.** 고급·정예 기사는 활 표적이 없어도 자기 방패를 쓸 수 있습니다. 사제의 ‘시간 이동’은 표적을 사제의 턴 시작 칸으로 옮기고 사제가 마지막으로 받은 피해를 한 번 적용합니다. 스펙터의 기계 탈취와 섹토이드의 전리품 회수도 해당 카드 하나로 작동합니다.
- **PICK YOUR POISON.** 코덱스의 사이오닉 폭탄에 폭발물 봉쇄와 능력 충전 차감을 함께 적용할 수 있습니다. 섹토이드의 ‘기억술’ 등 네 강화는 실제 공격 능력치 대결에 +40을 적용합니다. 스펙터 은신 회복, 버서커 타격, 폭발 반경과 병종별 카드 부여도 바로잡았습니다.

전설 난이도에서 위태로운 갈망을 켜고 선택받은 자 세 명의 보석 조합 1,728개와 같은 대상을 강화하는 선택지 3,178쌍을 대조했습니다. 전투 구성은 두 선택의 순서를 바꿔도 같았고, 캠페인에서 고를 수 있는 순서는 각 카드의 등장 월에 따라 달랐습니다. [rev008 단독 변경 이력](rev008/CHANGELOG.md) · [적 AI와 카드 검증 보고서](reports/ModReport_CoarseEnemyAIAndEncounters_rev008.md) · [설치 ZIP](rev008/AI_Encounter_Fixes_rev008.zip)

## rev007 — 마무리 사격 표적과 기동 지휘관의 망치

- **정예 어드밴트 저격수와 랩터.** 이제 실제로 쏠 병사의 명중률이 90%를 넘고, 그 사격으로 처치할 수 있거나 체력이 최대치의 40% 이하일 때 마무리 사격을 시도합니다. 적격 표적이 없으면 일반 공격 등 다음 행동을 평가합니다.
- **정예 어드밴트 기동 지휘관.** 첫 행동의 근접 공격 차례에서 총검을 쓸 수 없으면 지급 망치를 시도합니다. 표식과 이동 등 앞선 선택은 원래 순서를 따릅니다.

전설 난이도에서 위태로운 갈망을 켜고 저격수의 실제 처치, 랩터의 지정 표적 명중, 기동 지휘관의 망치 사용을 확인했습니다. 기존 편성의 일정 경계 검사 5,845건과 `ETP_` 추첨 10,044회가 기대와 일치했습니다. 전체 설치본 53개 파일 중 rev006과 달라진 파일은 `Config/XComAI.ini` 하나입니다. [rev007 단독 변경 이력](rev007/CHANGELOG.md) · [전술·편성 검증 보고서](reports/ModReport_CoarseEnemyAIAndEncounters_rev007.md) · [설치 ZIP](rev007/AI_Encounter_Fixes_rev007.zip)

## rev006 — 범위 공격·치료·처형·반응 사격

- **제단과 사이버디스크.** 보복 임무의 제단은 자기 칸을 중심으로 민간인 네 명을 맞힐 수 있을 때 ‘새벽 파괴자의 의식’을 시도합니다. 사이버디스크는 처음 고른 칸에서 ‘죽음의 꽃’을 쓸 수 없으면 자기 칸을 다시 검사합니다.
- **니벤과 치천사.** 수호가 재사용 대기 중이면 니벤은 ‘복구’, 니벤 수호자(T3)는 ‘시간 역행’으로 부상병을 치료합니다. M4 지팡이를 쓰는 치천사는 ‘천사의 자비’로 출혈·현혹·의식불명 병사를 구분해 처형하며, 정상 병사에게는 다른 공격을 선택합니다.
- **피의 조류.** XCOM 병사가 측면으로 이동을 마치면 적색 경계인 능력 소유자가 반응할 수 있습니다. 실제 전투에서 어드밴트 M2·M3가 각각 충전 한 번을 써서 행동력 하나를 얻고 같은 XCOM 턴에 사격했습니다.

전설 난이도에서 위태로운 갈망(That Perilous Yearning)을 켜고 확인했습니다. 최종 SDK 빌드 오류·경고는 각각 0개이며 전술 기록 20개의 검사 41개가 통과했습니다. [rev006 단독 변경 이력](rev006/CHANGELOG.md) · [전술 검증 보고서](reports/ModReport_CoarseEnemyAIAndEncounters_rev006.md) · [설치 ZIP](rev006/AI_Encounter_Fixes_rev006.zip)

## rev005 — 실제 적 턴과 바샤르 장비

- **바샤르의 첫 행동과 주무기.** 원본 AI가 찾던 강화 효과가 실제 장비 지급 때 생성되지 않아 전용 첫 사격 분기를 타지 못했습니다. 이제 실제 장비 21종을 인식하고, 최고 명중률이 70%를 넘고 사격이 가능하면 먼저 쏩니다. 조건이 맞지 않으면 다음 행동을 평가합니다. 주무기가 필요한 장비 공격도 뮤톤의 실제 소총에 연결됩니다. 전술 도중 지급하거나 저장 상태를 복구할 때도 같은 연결을 사용합니다.
- **행동력·치명타·장비 효과.** 사제·아바타·워록의 사이오닉, 첫 표준 사격, 스턴 랜스, 기계 유닛의 사격 비용과 선택받은 자의 기억 헌신을 실제 사용한 능력과 비용으로 판정합니다. 크리살리드의 명중 보상과 치명타 시 페이스리스·버서커의 행동력 환급, 섹토이드·바이퍼의 파열 대상을 바로잡았습니다. 시가이트의 첫 두 행동, 탄자나이트의 경계 행동력, 자수정·황수정의 고지대·측면 판정과 조이사이트의 표적별 원한 피해도 고쳤습니다.
- **선택받은 자와 표적 선택.** 실제 적 턴에서 어쌔신은 복제와 지휘 후 검격을 썼고, 상위 기술이 대기 중일 때는 저격수 옆으로 이동해 같은 병사를 쐈습니다. 헌터의 첫 추적 사격, 워록의 이동 후 눈부신 영광, 사제의 성전사 표적과 단독 사격도 관찰했습니다. 악몽은 각각 경계·제압 중인 병사를 골랐고, 보이는 적이 없는 별도 전투에서는 잠복 후 굴을 팠습니다. 습격자 특공대는 발각 직후 점프하거나, 탄약이 없고 점프가 대기 중이면 이동했습니다.
- **장비별 후속 행동.** 정상 탄약, 빈 탄창, 보이는 적 없음, 장비 능력 대기, 장비 능력과 표준 사격 동시 대기의 다섯 상황으로 21종의 행동 105건을 기록했습니다. 자체 재사용 대기 능력이 있는 장비는 Blood와 Elbaite 두 종입니다. 표준 사격 대기 시험에서는 탄약이 있는 21기 모두 사격이 차단됐고 이동·총검·수류탄·제압 등으로 이어졌습니다.

**검증 결과.** 전설·TPY를 켠 독립 전술 실행 14회에서 실제 적 턴 45턴을 기록했습니다. 수정 전 대조 전투가 포함됩니다. 원본 INI 24개와 INT 3개에서 버튼 168개의 설명과 발동 함수를 대조했습니다. 동일한 입력으로 강화 효과를 검사한 29건에서 원본은 12건이 기대와 달랐고 rev005는 29건 모두 일치했습니다. WotC SDK 최종 컴파일 오류·경고는 0건입니다. 장비의 기본 세 상황은 중간 빌드에서, 재사용 대기 두 상황은 최종 배포본에서 실행했습니다. [rev005 검증 보고서와 장비별 행동표](reports/ModReport_CoarseEnemyAIAndEncounters_rev005.md)

## rev004 — TPY 카드 효과와 임무 편성

- **카드가 부여하는 능력과 장비.** 스턴 랜서 정신 연결 3종, 병사·장교의 가속 체임버, MEC의 대구경을 해당 유닛에 연결했습니다. 로켓·마이크로 미사일, 외계인 수류탄, 정화병 화염방사기 강화가 각자의 선택에서 지급됩니다.
- **전술 효과와 영문 설명.** 크리살리드의 근접 명중 등급 상승과 장교의 측면 치명타를 공격자 기준으로 판정합니다. 방어구·관통 피해 감소는 최종 관통과 남은 방어구를 사용합니다. 보호막과 성전사 연결에 따른 피해 감소, Democracy 세 카드가 세는 생존 아군과 보이는 XCOM 병사의 범위도 바로잡았습니다.
- **EncounterLists와 Schedules.** 일정 14개의 배치 번호 93곳과 병력표 선언 7개의 번호 23곳을 복원했습니다. 어드밴트 기동 지휘관 M1의 뒤집힌 출현 전력 구간도 수정했습니다. 보급품 임무 3종은 경계도 22에서 두 번째 편성을 사용할 수 있습니다. GatherSurvivors는 전용 일정이 없을 때 D1 구출 일정을 사용합니다. 최종 임무 관리자의 빈 조우 27칸, 뒤집힌 전력 구간 4곳, 끊긴 임무 일정 참조 4곳이 모두 0이 됐습니다.
- **헌터 M3 회전 경고 조사.** 헌터 생성 직후 임시 어드밴트 애니메이션 세트만 붙어 있을 때 왼쪽 180도 회전 경고를 재현했습니다. 같은 무기를 유지해도 선택받은 자 공용 세트가 붙으면 회전 시퀀스가 조회됐습니다. 이 항목의 작업 범위는 원인 확인이었습니다.

**검증 결과.** 전설 캠페인 세 개에서 TPY 카드 56장의 버튼 168개를 직접 눌렀고, 저장 후 불러오기를 확인했습니다. 두 선택의 유효한 순서 23,157건은 게임 내 전략 상태에서, 서로 다른 세 카드의 버튼 조합 748,440건은 소스와 월 조건으로 검사했습니다. 월마다 하나씩 선택한 별도의 18개월 경로도 저장·복원했습니다. 병력표 선언 2,308개와 일정 선언 850개의 병합 결과를 대조했으며, 대상 일정 835개의 선택 경계를 5,845회 검사했습니다. WotC SDK 최종 스크립트 컴파일 오류·경고는 0건입니다. [rev004 검증 보고서와 카드 화면](reports/ModReport_CoarseEnemyAIAndEncounters_rev004.md)

## rev003 — 위태로운 갈망과 전설 난이도

- **전략 선택지.** 같은 이름으로 등록되던 18번과 19번 카드를 분리했습니다. 21번의 두 번째 버튼 *새벽의 화로*은 정화병의 화염방사기 보너스를 적용합니다. 세 버튼 모두 선택한 번호와 횟수를 한 번에 저장합니다. 새 전설 캠페인에서 19번 카드를 직접 선택해 저장·재불러온 뒤 재선택이 차단되는 것을 확인했습니다. 19번이 빠진 전략 저장을 모사한 시험에서도 55장이 56장으로 복구됐습니다. 예전 선택을 식별할 수 없는 기록은 소급 재배정하지 않습니다.
- **선택받은 자의 표적과 다음 행동.** 세 직책의 첫·마지막 행동에서 TPY 특수 능력을 평가하도록 연결하고, 복제와 지휘가 아군에게 점수를 주도록 고쳤습니다. 어쌔신은 복제만 대기 중이면 지휘를 썼고, 지휘받은 스턴 랜서는 곧바로 공격했습니다. 두 능력 모두 4턴 대기 중이거나 아군 후보가 0명이면 어쌔신은 일반 사격을 했습니다. 같은 무표적 시험에서 워록의 일반 사격과 헌터의 권총 사격도 확인했습니다.
- **어쌔신의 추적과 특수 능력.** *그림자처럼*는 변화 헌신이 있는 어쌔신만 적 저격수 옆 빈 칸으로 이동시킵니다. 저격수의 위치는 유지됐고, 주변 8칸을 병력으로 채우면 추적 대상에서 제외됐습니다. 순간이동의 능력 참조, 지휘의 명중 판정, 아군 복제 연출도 수정했습니다.
- **무기와 바샤르.** 선택받은 자 무기 강화와 뮤톤 바샤르 강화를 각각 켜고 끌 수 있습니다. 생존한 선택받은 자가 0명이어도 선택지에 해당하는 뮤톤은 지정된 장비군부터 추첨합니다. All-Seeing 바샤르와 연결 능력을 복구했고, 스턴 랜서가 선택지로 받은 수류탄을 실제로 지급받도록 고쳤습니다.
- **승천·교리·효과.** 선택받은 자가 같은 승천 특성을 중복 획득하는 문제와 월말 교리의 상태 반영을 수정했습니다. 16개 지역의 전력·경계·경계심이 각각 1씩 오르는 것을 확인했습니다. *황금 갑옷*는 사이오닉 40을 20으로 한 번 줄이고 7개 능력을 금지합니다. 바이퍼 독 피해의 비독 보너스, 네트워크 수복 반응 사격의 공황 설정, 누락된 능력·사용 입력도 수정했습니다.

**검증 결과.** 카드 56개의 월 제한과 버튼 콜백 168개, 선택받은 자 무기 조합 42개, 바샤르 장비 21종과 확률 입력 3,600개가 통과했습니다. 168개는 각 버튼이 적용한 태그 또는 해금 결과를 검사한 수입니다. rev003 당시 모든 선택 조합의 장기 캠페인과 연출은 미검증이었으며, 헌터 M3의 회전 애니메이션 경고가 남았습니다. 최종 WotC SDK 컴파일 오류·경고는 0건이고 기존 회귀 검사 71건이 모두 통과했습니다. [rev003 검증 보고서와 56개 카드 목록](reports/ModReport_CoarseEnemyAIAndEncounters_rev003.md)

## rev002 — 시작 오류와 전술 AI 수정

- **게임 시작.** rev001에서 능력 공급 클래스 `CoarseEnemyEquipment`를 생성하지 못해 종료되던 문제를 고쳤습니다. 같은 모드 구성으로 rev002를 실행해 주 메뉴, 지도 생성, 실제 전술 전투 진입을 확인했습니다.
- **Requiem 분대와 발각 행동.** 사령관·전설 난이도와 Requiem Hard Mode 조건이 겹칠 때 단서 추적자가 실패한 분대 행동을 최대 네 번 시도하던 경로를 정리했습니다. 전용 행동을 한 번 평가한 뒤 일반 행동으로 이어집니다. 레퀴엠 아르콘 계열의 표식·이동, 강제 재배치의 중복 시도, 습격자 특공대의 끊긴 발각 행동도 고쳤습니다.
- **서리 병종.** 서리 맘바·아르콘·랜서 M1~M3의 난이도별 변형 25개를 확인했습니다. 전용 행동이 누락된 20개는 해당 병종의 기본 행동으로 이어지고, 유효한 5개는 고유 행동을 유지합니다. 전술 전투에서 서리 랜서의 이동 후 서리 도끼 공격과 단서 추적자의 권총 경계를 확인했습니다.
- **장비와 병력표.** 난이도별 능력 및 무기 변형을 따로 조회해 다른 모드가 실제로 공급한 `Feedback`과 무기 속성을 유지합니다. Berserker Omega Bridge의 잘못된 보스 항목을 바로잡고, 세 보호 목록에는 기존 기간·가중치·개수를 대조해 부족한 항목만 추가합니다.

**검증 결과.** 실제 WotC 병합 순서 표식 989개와 행동 노드 6,053개를 대조했습니다. 최종 요새의 여섯 포털은 게임의 조우 추첨 함수를 총 8,448회 호출해 검사했습니다. 전체 캠페인의 요새 진행·저장 재개는 미실행입니다. SDK 회귀 검사는 71건 모두 통과했습니다. [rev002 검증 보고서](reports/ModReport_CoarseEnemyAIAndEncounters_rev002.md)

## rev001 — Coarse 적 AI와 Tedjam 최초 통합

- **적 AI와 특수 장비.** 악몽의 어벤저 방어전 잠복 해제와 근접 표적 선택, 헌터의 무기별 표적, 워록의 자기 호출, 의무병의 부상 아군 탐색을 수정했습니다. 프라이토리안 명령, 서리 군단 살무사 결박, 어드밴트 서리 사제 수류탄, 제단·사이버디스크 범위 공격도 포함합니다. Calendarium과 ARFM 장비의 누락 능력, `Wall`·`WholeHearted`의 지급 능력, 보호막이 있을 때의 피해 감소, 영혼 벌레 근접 무기 12종을 점검했습니다.
- **일반 병력 교대.** 전력 수준(FL)에 따라 드론 M1은 FL 7, 트루퍼 M2는 11, 척탄병 M2는 12, 로켓병 M2는 13까지 일반 병력표에서 양수 가중치를 갖고 다음 단계부터 빠집니다.
- **Tedjam 스토리 임무.** 블랙사이트·포지·사이오닉 게이트·방송탑에 Golden Path 편성과 ZERO SANITY 분기를 반영했습니다. 포지 Extreme 전용 보스는 메카피드 1기와 사이버디스크 2기가 기본이며 옵션을 켜면 어드밴트 고위 커스토디안 그랜드마스터 1기와 어드밴트 고위 커스토디안 2기를 추가합니다. 방송탑의 단독 드론은 사이버디스크로 교체합니다.
- **최종 요새.** 여섯 포털의 강화 추첨과 스포너별 병력 명단 복원을 통합했습니다. 정화팀·단일 아바타·이중 아바타의 19개 추첨 항목은 후반 Requiem 후보 6종을 적용해 114개가 되며, 각 편성에 1기가 추가됩니다.

**검증 결과.** 당시 정적 AI 병합과 SDK 검사 54건을 통과했습니다. rev001 작업 당시 전술 턴과 캠페인 재진입은 미실행이었습니다. 이후 같은 배포 파일에서 확인한 게임 시작 오류는 rev002에 수정했습니다. [rev001 검증 보고서](reports/ModReport_CoarseEnemyAIAndEncounters_rev001.md) · [rev002 실행 대조](reports/ModReport_CoarseEnemyAIAndEncounters_rev002.md)

## 실제 배포 파일 대조

상대 경로와 전체 파일의 SHA-256을 비교했습니다. 최초 버전은 빈 목록을 기준으로 셌고 후속 버전은 직전 배포본과 비교했습니다.

| 버전 | 총 파일 | 추가 | 수정 | 삭제 | 패키지 크기(바이트) | 배포 .u SHA-256 |
|---|---:|---:|---:|---:|---:|---|
| rev001 | 16 | 16 | 0 | 0 | 72,487 | `df88e5b908351665f02a6b8afbf7756e46fe14c89575c707cc37a0b94c119e91` |
| rev002 | 17 | 1 | 5 | 0 | 86,809 | `22e315c7ec920cc21e7dc5cf98c1e25d824331003a7abc7816f297d4d2c9a0ec` |
| rev003 | 28 | 11 | 3 | 0 | 222,217 | `038b88da19dc9d3dcc2640b401dd040ce1f638bbd29554b9839e5e060db4616e` |
| rev004 | 37 | 9 | 6 | 0 | 277,568 | `3ca0d1cac14d99d19226f716a8e1f2f7f99b34f3bbaaff09147856d708d9ae89` |
| rev005 | 51 | 14 | 5 | 0 | 344,888 | `8469d3b6224f2fad2d0fc5c583f4bc8fc706f46045ad9b862dc532085126be2d` |
| rev006 | 53 | 2 | 4 | 0 | 363,733 | `6827e7fa8a3ea658cbd70d1b0dea2f3e46ee688dfd87573bc185fef9c2837e64` |
| rev007 | 53 | 0 | 1 | 0 | 363,733 | `6827e7fa8a3ea658cbd70d1b0dea2f3e46ee688dfd87573bc185fef9c2837e64` |
| rev008 | 63 | 10 | 4 | 0 | 441,057 | `ae9c8de89d67142c530c29eb0bf7cd855e5f398e5b1a74fc71083ede6935c454` |

<details>
<summary>rev001의 추가·수정 파일 16개</summary>

| 구분 | 버전 내 파일 |
|---|---|
| 추가 | [CoarseEnemyAIAndEncounters.XComMod](rev001/CoarseEnemyAIAndEncounters/CoarseEnemyAIAndEncounters.XComMod) |
| 추가 | [Config/XComAI.ini](rev001/CoarseEnemyAIAndEncounters/Config/XComAI.ini) |
| 추가 | [Config/XComCoarseEncounters.ini](rev001/CoarseEnemyAIAndEncounters/Config/XComCoarseEncounters.ini) |
| 추가 | [Config/XComEditor.ini](rev001/CoarseEnemyAIAndEncounters/Config/XComEditor.ini) |
| 추가 | [Config/XComEncounterLists.ini](rev001/CoarseEnemyAIAndEncounters/Config/XComEncounterLists.ini) |
| 추가 | [Config/XComEncounters.ini](rev001/CoarseEnemyAIAndEncounters/Config/XComEncounters.ini) |
| 추가 | [Config/XComEngine.ini](rev001/CoarseEnemyAIAndEncounters/Config/XComEngine.ini) |
| 추가 | [Config/XComGame.ini](rev001/CoarseEnemyAIAndEncounters/Config/XComGame.ini) |
| 추가 | [Config/XComLW_Overhaul.ini](rev001/CoarseEnemyAIAndEncounters/Config/XComLW_Overhaul.ini) |
| 추가 | [Config/XComMissionDefs.ini](rev001/CoarseEnemyAIAndEncounters/Config/XComMissionDefs.ini) |
| 추가 | [Config/XComSchedules.ini](rev001/CoarseEnemyAIAndEncounters/Config/XComSchedules.ini) |
| 추가 | [Script/CoarseEnemyAIAndEncounters.u](rev001/CoarseEnemyAIAndEncounters/Script/CoarseEnemyAIAndEncounters.u) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/CoarseEnemyEquipment.uc](rev001/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/CoarseEnemyEquipment.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2DLCInfo_CoarseEncounters.uc](rev001/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2DLCInfo_CoarseEncounters.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2DLCInfo_CoarsePortalCapture.uc](rev001/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2DLCInfo_CoarsePortalCapture.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseBasharShield.uc](rev001/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseBasharShield.uc) |

</details>

<details>
<summary>rev002의 추가·수정 파일 6개</summary>

| 구분 | 버전 내 파일 |
|---|---|
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/XGAIBehavior_CoarseFrost.uc](rev002/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/XGAIBehavior_CoarseFrost.uc) |
| 수정 | [Config/XComAI.ini](rev002/CoarseEnemyAIAndEncounters/Config/XComAI.ini) |
| 수정 | [Config/XComEncounterLists.ini](rev002/CoarseEnemyAIAndEncounters/Config/XComEncounterLists.ini) |
| 수정 | [Script/CoarseEnemyAIAndEncounters.u](rev002/CoarseEnemyAIAndEncounters/Script/CoarseEnemyAIAndEncounters.u) |
| 수정 | [Src/CoarseEnemyAIAndEncounters/Classes/CoarseEnemyEquipment.uc](rev002/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/CoarseEnemyEquipment.uc) |
| 수정 | [Src/CoarseEnemyAIAndEncounters/Classes/X2DLCInfo_CoarseEncounters.uc](rev002/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2DLCInfo_CoarseEncounters.uc) |

</details>

<details>
<summary>rev003의 추가·수정 파일 14개</summary>

| 구분 | 버전 내 파일 |
|---|---|
| 추가 | [Config/XComGameData_BeyondLegendary.ini](rev003/CoarseEnemyAIAndEncounters/Config/XComGameData_BeyondLegendary.ini) |
| 추가 | [Config/XComTPYConfig.ini](rev003/CoarseEnemyAIAndEncounters/Config/XComTPYConfig.ini) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/CoarseChosenAscent.uc](rev003/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/CoarseChosenAscent.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningCards.uc](rev003/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningCards.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningEquipment.uc](rev003/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningEquipment.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningPowers.uc](rev003/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningPowers.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningStrategy.uc](rev003/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningStrategy.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/UICoarseYearningChoice.uc](rev003/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/UICoarseYearningChoice.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Condition_CoarseArmoredInGold.uc](rev003/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Condition_CoarseArmoredInGold.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Condition_CoarseShadowStalkTile.uc](rev003/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Condition_CoarseShadowStalkTile.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseViperPoison.uc](rev003/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseViperPoison.uc) |
| 수정 | [Config/XComAI.ini](rev003/CoarseEnemyAIAndEncounters/Config/XComAI.ini) |
| 수정 | [Script/CoarseEnemyAIAndEncounters.u](rev003/CoarseEnemyAIAndEncounters/Script/CoarseEnemyAIAndEncounters.u) |
| 수정 | [Src/CoarseEnemyAIAndEncounters/Classes/X2DLCInfo_CoarseEncounters.uc](rev003/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2DLCInfo_CoarseEncounters.uc) |

</details>

<details>
<summary>rev004의 추가·수정 파일 15개</summary>

| 구분 | 버전 내 파일 |
|---|---|
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningCardEffects.uc](rev004/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningCardEffects.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseBoxingBugs.uc](rev004/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseBoxingBugs.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseDemocracyLiberates.uc](rev004/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseDemocracyLiberates.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseDemocracyProtects.uc](rev004/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseDemocracyProtects.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseDemocracyUnifies.uc](rev004/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseDemocracyUnifies.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseEnergyShield.uc](rev004/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseEnergyShield.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseHighCaliber.uc](rev004/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseHighCaliber.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseHolyWarrior.uc](rev004/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseHolyWarrior.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarsePinpoint.uc](rev004/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarsePinpoint.uc) |
| 수정 | [Config/XComEncounterLists.ini](rev004/CoarseEnemyAIAndEncounters/Config/XComEncounterLists.ini) |
| 수정 | [Config/XComSchedules.ini](rev004/CoarseEnemyAIAndEncounters/Config/XComSchedules.ini) |
| 수정 | [Script/CoarseEnemyAIAndEncounters.u](rev004/CoarseEnemyAIAndEncounters/Script/CoarseEnemyAIAndEncounters.u) |
| 수정 | [Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningEquipment.uc](rev004/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningEquipment.uc) |
| 수정 | [Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningPowers.uc](rev004/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningPowers.uc) |
| 수정 | [Src/CoarseEnemyAIAndEncounters/Classes/X2DLCInfo_CoarseEncounters.uc](rev004/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2DLCInfo_CoarseEncounters.uc) |

</details>

<details>
<summary>rev005의 추가·수정 파일 19개</summary>

| 구분 | 버전 내 파일 |
|---|---|
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2AIBTConditions_CoarseYearning.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2AIBTConditions_CoarseYearning.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseAmethyst.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseAmethyst.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseChryssalidHits.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseChryssalidHits.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseCitrine.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseCitrine.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseFacelessCritical.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseFacelessCritical.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarsePriestPsionics.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarsePriestPsionics.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseRemembrance.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseRemembrance.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseShigaite.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseShigaite.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseSlipperyStalkers.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseSlipperyStalkers.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseSmartMunitions.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseSmartMunitions.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseStunLanceRefund.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseStunLanceRefund.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseTanzanite.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseTanzanite.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseWarlockPsionics.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseWarlockPsionics.uc) |
| 추가 | [Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseZoisite.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseZoisite.uc) |
| 수정 | [Config/XComAI.ini](rev005/CoarseEnemyAIAndEncounters/Config/XComAI.ini) |
| 수정 | [Script/CoarseEnemyAIAndEncounters.u](rev005/CoarseEnemyAIAndEncounters/Script/CoarseEnemyAIAndEncounters.u) |
| 수정 | [Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningCardEffects.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningCardEffects.uc) |
| 수정 | [Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningEquipment.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningEquipment.uc) |
| 수정 | [Src/CoarseEnemyAIAndEncounters/Classes/X2DLCInfo_CoarseEncounters.uc](rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/X2DLCInfo_CoarseEncounters.uc) |

</details>

<details>
<summary>rev006의 추가·수정 파일 6개</summary>

설치 ZIP의 `CoarseEnemyAIAndEncounters/`를 기준으로 한 경로입니다. [설치 ZIP](rev006/AI_Encounter_Fixes_rev006.zip)

| 구분 | 버전 내 파일 |
|---|---|
| 수정 | `Config/XComAI.ini` |
| 추가 | `Src/CoarseEnemyAIAndEncounters/Classes/X2AIBTActions_CoarseRadial.uc` |
| 추가 | `Src/CoarseEnemyAIAndEncounters/Classes/X2Condition_CoarseMercyTarget.uc` |
| 수정 | `Src/CoarseEnemyAIAndEncounters/Classes/X2DLCInfo_CoarseEncounters.uc` |
| 수정 | `Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningPowers.uc` |
| 수정 | `Script/CoarseEnemyAIAndEncounters.u` |

</details>

<details>
<summary>rev007에서 수정한 파일 1개</summary>

설치 ZIP의 `CoarseEnemyAIAndEncounters/`를 기준으로 한 경로입니다. [설치 ZIP](rev007/AI_Encounter_Fixes_rev007.zip)

| 구분 | 버전 내 파일 |
|---|---|
| 수정 | `Config/XComAI.ini` |

</details>

<details>
<summary>rev008에서 수정한 파일 4개와 추가한 파일 10개</summary>

설치 ZIP의 `CoarseEnemyAIAndEncounters/`를 기준으로 한 경로입니다. [설치 ZIP](rev008/AI_Encounter_Fixes_rev008.zip)

| 구분 | 버전 내 파일 |
|---|---|
| 수정 | `Config/XComAI.ini` |
| 수정 | `Script/CoarseEnemyAIAndEncounters.u` |
| 수정 | `Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningCardEffects.uc` |
| 수정 | `Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningPowers.uc` |
| 추가 | `Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningAttackCards.uc` |
| 추가 | `Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningStatRolls.uc` |
| 추가 | `Src/CoarseEnemyAIAndEncounters/Classes/X2AbilityToHitCalc_CoarseYearningDoctrineRoll.uc` |
| 추가 | `Src/CoarseEnemyAIAndEncounters/Classes/X2AbilityToHitCalc_CoarseYearningPanicRoll.uc` |
| 추가 | `Src/CoarseEnemyAIAndEncounters/Classes/X2AbilityToHitCalc_CoarseYearningUnitRoll.uc` |
| 추가 | `Src/CoarseEnemyAIAndEncounters/Classes/X2Condition_CoarsePermanentPassive.uc` |
| 추가 | `Src/CoarseEnemyAIAndEncounters/Classes/X2Condition_CoarseTimeShiftLanding.uc` |
| 추가 | `Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseDedicationChange.uc` |
| 추가 | `Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseDedicationPower.uc` |
| 추가 | `Src/CoarseEnemyAIAndEncounters/Classes/X2Effect_CoarseTimeShiftDamage.uc` |

</details>
