# LWOTC Coarse 적 AI와 Tedjam 임무 통합 · rev002

rev002에서는 rev001의 시작 오류를 고쳐 같은 모드 구성으로 주 메뉴와 전술 전투에 진입했다. 실제 적 턴에서 서리 랜서가 이동 후 도끼로 공격했고, 단서 추적자(`AHWOutsiderMagna`)가 권총 경계를 선택했다. 습격자 특공대의 발각 행동은 게임이 읽은 후보가 한 개에서 다섯 개로 늘었다. 발각 직후 도약과 이동을 실제로 수행한 기록은 rev005에서 확인할 수 있다. [발각 시험 기록](evidence/rev005/RaptorBlocked.txt)

Windows Steam판 XCOM 2 선택된 자의 전쟁과 Requiem Legion: Coarse Edition에서 2026년 11월 21일에 확인한 결과다.

## 설치와 적용 시점

1. 런처의 로컬 모드 검색 경로에 `rev002`를 Workshop 경로 다음으로 추가한다. rev001과 rev002는 같은 내부 ID `CoarseEnemyAIAndEncounters`를 쓴다. 기존 rev001 검색 경로를 빼고 새로 고친 뒤 **LWOTC Coarse - Enemy AI and Encounters**의 실제 위치가 rev002인지 확인하고 켠다. [완성 모드 폴더](../rev002/CoarseEnemyAIAndEncounters/)
2. **Requiem Legion: Coarse Edition**(3555944655, `AHarderWarAbsurdAliens`)과 **Totally Reasonable Definitely Not Psychotic Tedjam Plugin**(3835619377, `TotallyNotPsychoGoldenPath`)을 함께 켠다. 당시 개인 활성 목록에는 원본 Tedjam이 들어 있고 Coarse는 빠져 있었다. 시험에는 Coarse를 추가한 별도 프로필을 사용했다.
3. `Config/XComGame.ini`가 요구하는 나머지 모드는 `X2WOTCCommunityHighlander`, `LongWarOfTheChosen`, `TedModJamForLWOTC`, `ARFMDarkEvents`, `ARFMAdventPack`이다. Custodian 등 기존 편성에 등장하는 병력 제공 모드도 사용한다. 이전 오버라이드 `LWOTCEnemyTierAIOverride`, `LWOTCEnemyTierAIGoldenPathOverride`, `LWOTCFortressShowdownReinforcementOverride`, `LWOTCFortressShowdownEliteReinforcements`, `LWOTCFortressShowdownLateRequiem`은 끈다.
4. 게임을 다시 시작한다. 새 스토리 편성을 확인하려면 해당 임무를 생성하기 전 전략 저장을 사용한다. 이미 전술 저장에 생성된 병력은 생성 당시의 명단을 가진다.

## 이번 점검에서 고친 동작

| 대상 | 확인한 현상과 수정 결과 | 확인 위치 |
|---|---|---|
| 게임 시작 | 원래 rev001 배포 바이너리로 실행한 실게임에서 능력 공급 클래스를 생성할 수 없어 종료됐다. 엔진이 생성할 수 있는 클래스로 고쳤다. 같은 모드 구성의 rev002가 주 메뉴와 전술 전투에 진입했다. | `Src/CoarseEnemyAIAndEncounters/Classes/CoarseEnemyEquipment.uc` 클래스 선언 |
| Requiem 분대 행동 | 적색 경계에서 Requiem Hard Mode가 켜졌거나 사령관·전설 난이도일 때 분대장·분대원 전용 행동을 한 번 평가한다. 둘 다 충족하고 행동이 전부 실패하면 기존 단서 추적자는 전용 선택을 최대 네 번 반복했다. 이제 해당 역할 한 번, 일반 `TryJob` 한 번을 거쳐 경계 상태에 맞는 행동으로 진행한다. | `Config/XComAI.ini`의 `TryRequiemPodJobs`, `AHWOutsiderMagna::CharacterRoot` |
| 레퀴엠 아르콘 계열·강제 재배치 | 레퀴엠 아르콘 계열이 첫 표식 및 대응 기동에 실패하면 이동 후보로 넘어간다. Reshi 사용 시 강제 재배치가 같은 불타는 근접 이동을 연속으로 시도하던 경로를 고쳤다. 기존 엄폐와 후퇴 분기 순서를 유지했다. | 같은 파일의 `ScamperRoot_AHWArchonMagna`, `FlushRoot` |
| 어드밴트 습격자 특공대 | Advent Commandos 원본의 줄 연결 뒤 공백 때문에 게임이 발각 행동의 첫 자식만 읽었다. 해당 모드가 켜졌을 때 한 줄로 완전한 노드를 등록한다. 사격·도약·이동 선택, 대응 기동, 시야를 확보하는 방어 이동, 일반 이동, 이동 생략 순이다. | 같은 파일의 `ScamperRoot_Raptor`, `OverrideBehaviors` |
| 서리 맘바·아르콘·랜서 M1~M3 | 다섯 적 종류의 난이도 변형 중 20개가 현재 구성에 없는 전용 행동 이름 3개를 가리켰다. Ted Mod Jam의 `OPTC_ModJamAI.SwapBehaviourTree`는 `FindCharacterTemplate`로 당시 선택된 변형을 고친다. 이 구성에서 이미 유효한 병종 루트를 가진 5개 변형은 기존 AI 클래스를 유지했다. 해당 이름과 기본 AI 클래스가 모두 일치하는 변형에 대체 경로를 연결했다. 게임이 전용 루트를 찾으면 먼저 사용한다. 없으면 `GenericAIRoot`가 현재 병종의 Viper·Archon·`AdventStunLancer` 행동으로 이어진다. 별도 AI 클래스를 공급한 모드의 선택도 보존한다. | `XGAIBehavior_CoarseFrost.uc`의 `InstallForTemplate`, `GetBehaviorTreeRoot` 및 `X2DLCInfo_CoarseEncounters.OnPostTemplatesCreated` |
| Berserker Omega | Bridge의 닫히지 않은 따옴표 때문에 FL 16~99, 그룹당 최대 1기, 가중치 1인 보스 항목에서 실게임 설정 해석 오류가 발생했다. 원래의 잘못된 줄을 정확하게 제거하고, Bridge와 실제 캐릭터가 모두 있을 때만 의도된 항목을 복구한다. 다른 최대 인원·기간·가중치의 항목은 유지한다. 보호 지휘관 표 3개에는 원본 Omega 항목의 구간과 중복 횟수를 대조해 부족한 개수만 더한다. | `Config/XComEncounterLists.ini`, `RestoreOmegaBossEntry`, `IncludeOmegaInProtectedList` |
| 난이도별 장비와 능력 | 능력 관리자의 전체 난이도 변형을 조회한다. `Wall`·`WholeHearted`·`MegaTank`와 영혼 벌레 무기를 점검한다. 특정 난이도에 실제 `Feedback`을 공급하는 경우 그 난이도의 능력을 보존한다. 공유 무기 하나가 여러 난이도에 걸치면 잘못된 지급이 있는 범위만 나누며 별도로 등록된 무기의 속성을 보존한다. | `CoarseEnemyEquipment.uc`의 `RepairTemplates`, `GetAbilityDifficultyMask`, `RemoveMissingFeedback` |

위 표에서 파일명만 표시한 스크립트는 모두 `Src/CoarseEnemyAIAndEncounters/Classes/`에 있다. 플레이어 소환 로봇에서 발견된 네 가지 전용 루트명은 Pet Rock 및 Playable 어드밴트의 드론·MEC 소환체가 사용한다. 보고서의 서리 적 다섯 종류는 원본 병종 클래스와 실제 캐릭터 등록을 대조해 선별했다.

## 함께 반영한 기존 AI 및 Tedjam 수정

- 악몽은 일반·LW 어벤저 방어전에서 자신의 잠복 해제 행동을 선택한다. 민간인 우선순위에 이어 일반 근접 표적도 평가하며 경계·제압은 점수 보너스로 처리한다. 유효한 표적이 없으면 추적·이동으로 이어진다. 헌터의 사격·표적 선택, 워록의 자기 호출, 서리 계열의 누락 참조, 트리플 샷 중복, VIP 행동 구문도 수정본에 포함한다.
- 어드밴트 의무병의 치료 후보 순회, 프라이토리안의 명령, 서리 군단 살무사의 결박 유지, 어드밴트 서리 사제의 수류탄, 저격수·습격자 특공대의 사격과 피의 조류 반응을 포함한다. 안드로멜리드 엄폐와 타이판·니벤·레퀴엠 아르콘 계열·메카피드의 표적 평가, 제단·사이버디스크의 범위 공격도 포함한다. 게임이 읽은 범위 설정은 일반 임무의 두 능력에 표적 한 명 이상, 보복 임무의 의식에 네 명 이상, 어드밴트 서리 사제의 수류탄에 두 명 이상을 요구했다. 실제 시전과 피해는 [rev006 전술 기록](ModReport_CoarseEnemyAIAndEncounters_rev006.md)에서 확인할 수 있다.
- Calendarium의 Highlander 능력과 `Sectoid` Launcher Fuse·Avatar Power의 누락 등록, `Wall` → `MegaTank`와 `WholeHearted` → `MassFire` 지급을 포함한다. `MassFire`는 원본 원뿔·탄약·재사용 대기시간·환경 피해를 쓰며 `MassBombard`와 별개 객체다. 동일 Kinetic Plating 객체가 두 번 들어간 경우에만 두 번째 효과를 보호막이 있을 때의 피해 감소로 교체한다. 영혼 벌레 근접 무기 12종에서 Slash와 끊어진 `Feedback` 지급을 확인하고 폭발형의 자폭을 보존한다.
- 일반 부하 목록 `DefaultFollowers_LW`와 `AdventFollowers_LW`에서 드론 M1은 FL 7, 트루퍼 M2는 11, 척탄병 M2는 12, 로켓병 M2는 13이 마지막 양수 가중치다. 이후 전력 수준에서는 해당 하위형이 빠진다. 전용·보호 편성은 별도의 목록을 쓴다.
- 블랙사이트·포지·사이오닉 게이트·방송탑에 이전 Golden Path 편성과 원본의 ZERO SANITY 옵션을 반영한다. 포지 Extreme 전용 보스는 메카피드 1기와 사이버디스크 2기다. ZERO SANITY를 켜면 어드밴트 고위 커스토디안 그랜드마스터 1기와 어드밴트 고위 커스토디안 2기를 더한다. 일반 보스는 원본 Tedjam의 메카피드 1기와 Gunship 2기다. 포지 `WithTerror`는 일반 `OPN`보다 우선한다. 방송탑의 보호 코덱스는 원본 처리를 유지하고 단독 드론은 옵션과 관계없이 사이버디스크로 교체한다. 대상 밖 임무·조우는 들어온 명단을 보존한다.
- 요새에서 `GP_FortressShowdown_LW` 맵 스크립트가 부르는 여섯 포털에 기존 상위형 교체와 강화 편성 추가 추첨을 적용한다. 정화팀·단일 아바타·이중 아바타만 후보 여섯 중 한 기를 추가한다. 후보는 `AHWLegate`, `AHWMechapede`, `AHWBerserkerMagnaT4`, `AHWIncubatorMagnaT4`, `AHWHeavyMechtoidT4`, `AHWCyberdiscT4`다. `Config/XComCoarseEncounters.ini`의 `LateRequiemPool`에서 바꿀 수 있다. 등록된 서로 다른 후보 여섯이 필요하다. 빠진 후보·중복 후보는 기존 버킷으로, 잘못된 기본 편성은 해당 포털의 기존 버킷으로 돌아간다.
- `Config/XComGame.ini`에서 포털 명단 기록 훅은 `RUN_FIRST`, 복원 훅은 `RUN_LAST`이며 Coarse·원본 Tedjam·`ARFMDarkEvents` 뒤에 온다. 실제 Highlander 정렬 기록에서 포털 기록은 3번, `ARFMDarkEvents`는 404번, 원본 Tedjam은 418번, 통합 후처리는 419번이었다. 원본 Tedjam의 다른 스토리와 선택받은 자 요새 처리도 이 구성에 남는다. 두 훅은 같은 스포너의 명단을 짝지어 한 번 복원한다. 중첩 스포너·빈 명단·일반 증원·전투 시작 배치는 구분한다. 전달받은 조우를 수정하며 이 배포본이 제출할 대기 `GameState`를 새로 만들지 않는다.

기존 Golden Path의 AI 설정 268개 행이 순서대로 포함된다. rev001의 추가 33개 행도 포함하며 rev002 AI 파일은 총 313개 설정 행이다. Golden Path의 스토리 함수, 임무·일정 파일, 병력표 전체 및 엘리트 요새의 조우·추첨 변경을 기존 작업 산출물과 대조했다.

## 실제 WotC와 설정 병합

개인 활성 목록 389개에 요청한 Coarse를 추가한 격리 프로필로 시험했다. 기본 비활성 후보 중 실제 활성 목록에 명시된 `ARFMAbandoned`, `BerserkerOmega`, `EUBerserker`, `TheEthereals`도 포함했다. 사용자의 기존 런처 프로필과 캠페인 저장을 시험에 사용하지 않았다.

게임의 `DevDlc` 병합 기록과 격리 사본에 넣은 파일별 표식의 순서를 대조했다. AI 설정은 DLC·Workshop 76개에 게임의 기본 설정과 로컬 수정본이 더해진다. 다른 표식은 조우 25개, 병력 목록 48개, 일정 12개, 임무 정의 11개, LW 설정 121개, Engine 349개, Game 347개다. 이 989개의 파일별 표식이 각 범주의 실제 병합 순서와 일치했다. 이후 LWOTC `UIScreenListener_Shell.UpdateAIBehaviors`의 이름별 삭제, 추가, 활성 모드 판정과 우선순위 교체가 적용된 주 메뉴 상태를 읽었다.

## 검증과 재현

| 방식 | 조건과 절차 | 기대 | 실제 관찰 | 상태 |
|---|---|---|---|---|
| WotC 실행 대조 | 동일한 격리 프로필에서 기존 rev001 배포 파일과 rev002를 따로 실행 | rev002에서 시작·전술 진입 | rev001은 34.23초에 `Can't create object None: class CoarseEnemyEquipment is abstract`. rev002는 주 메뉴, 지도 생성, 전술 전투에 진입 | 통과 |
| AI 전수 대조 | 로컬 수정 전후를 실제 파일 순서로 재구성하고 최종 주 메뉴의 노드 이름·종류·자식 순서와 비교 | 중복 이름, 미해결 자식, 잘못된 자식 번호, 구문, 순환 각 0 | 원본은 각각 24·57·7·1·1. 최종은 모두 0. 노드 6,053개가 실제 게임과 일치. Ted Jam Requiem 선택 플러그인과 Reshi 켬·끔 네 조합의 정적 검토에서도 모두 0 | 통과 |
| 행동 분기 모의 | 네 난이도 × Hard Mode × 경계 × 역할 × 전용 행동 성공 × 일반 행동 성공. 악몽은 기본 점수가 같은 일반·경계·제압·빈 표적 5상황 | 전용 행동 0회 또는 1회, 실패하면 일반 행동. 악몽은 가산점이 높은 유효 표적 선택 | 역할 128/128, 악몽 5/5 일치. 단서 추적자의 이전 최댓값 4회 확인 | 통과 |
| WotC 난이도별 루트 | 서리 적 다섯 종류의 등록 변형마다 실제 유닛 객체를 만들고 AI에 루트명 질의. 두 번째에는 존재하는 루트를 임시 공급 | 누락 시 기본 루트, 공급 시 공급된 루트 | 누락된 20개는 `GenericAIRoot`를 반환했다. 나머지 5개는 기존 `XGAIBehavior`와 Viper·Archon·`AdventStunLancer` 루트를 유지했다. 시험에서 공급한 `GenericScamperRoot`는 25/25 보존. 시험용 변경은 원복하고 대기 상태를 정리 | 통과 |
| WotC 전술 전투 | 빠른 전술 시작으로 지도 생성 후 XCOM 병사 근처에 적 팀의 `FrostLancer_M1`, `AHWOutsiderMagna`를 배치. 게임 상태 이력에서 능력·대상을 확인 | 서리 랜서가 도끼를 사용하고 단서 추적자가 정상 전투 행동 선택 | 랜서의 `StandardMove`, 이력 604에서 대상 2227에 `MZ_FDFrostAxeSlash`, 단서 추적자의 이력 656에서 `PistolOverwatch` 확인. 사령관 일반 구성에서도 Ted Mod Jam이 연결한 기존 AI로 랜서의 도끼 공격을 확인 | 통과 |
| WotC 사령관·누락 루트 재현 | 시험용 훅이 Ted Mod Jam 뒤, 배포 훅 앞에서 서리 랜서 M1에 원본의 미등록 ABA 이름을 다시 지정. 시야가 확인된 타일에 적으로 배치해 적색 경계에서 실제 전술 유닛의 AI 객체를 조회 | 이 조건에서 배포 클래스가 기본 루트를 선택하고 실제 행동을 실행 | 생존한 적색 경계 랜서의 실제 객체는 `XGAIBehavior_CoarseFrost`, 선택한 루트는 `GenericAIRoot`. 이동 이력 464 확인, 이력 674에서 대상 2179에 `MZ_FDFrostAxeSlash` 사용 | 통과 |
| WotC 발각 루트·장비 | 주 메뉴의 습격자 특공대 발각 노드와 능력 관리자 결과를 읽음 | 습격자 특공대 분기 5개, `Wall`·`WholeHearted` 각각 자기 능력 지급 | 첫 수정 전 실게임은 습격자 특공대 자식 1개, 최종은 5개. 전체 난이도 공유 능력의 `Wall` → `MegaTank`, `WholeHearted` → `MassFire` 및 보호막 효과 실제 등록 확인 | 통과 |
| WotC Omega | 실제 Bridge·Omega를 활성화해 설정 읽기와 원본·보호 지휘관 목록 대조 | 원래 해석 오류 제거, 다른 구간과 중복 횟수 보존 | 원본의 `ImportText (SpawnDistributionLists): Missing closing parenthesis` 재현. 수정본에서 이 행 오류 0건. 보스표에 FL 16~99 최대 1기 및 다른 활성 설정을 거친 최대 4기 항목 공존. Bridge 하위 폴더의 최대 4기 행은 원문 FL 16~20이며 이번 실게임 최종값은 FL 16~99였다. 원본·보호의 Omega 항목 수는 테러 6/6, 일반 6/6, 어드밴트 1/1 | 통과 |
| 병력표·스토리 | 두 일반 부하 표에서 각 교대 경계와 FL 99까지 확인. 4개 임무군, 일반·Extreme 보스, 겹치는 이름·보호 코덱스·임무 미지정에서 ZERO SANITY 켬·끔 대조 | 원래 편성과 우선순위 보존 | 병력 경계 8/8, 스토리 44/44. 포지 FL 0~99의 각 값에서 전용 변형 1개. ETP 조우 224개·버킷 93개·일정 28개·출현표 9개의 내부 미해결 참조 0 | 통과 |
| SDK 실행 | 최종 배포 바이너리로 포털 기록·복원·중첩, 후보 누락, 재호출, 다른 Omega 구간·중복, 전설 한정 능력·별도 사령관 무기, 내용이 겹치는 장비·보호막 효과를 시험 | 적용 횟수와 실제 효과 일치. 피해 감소 6에서 보호막 있으면 10→4·3→0, 없으면 10→10 | `COARSE-QA 71 checks 0 failures`. 무관한 무기 속성과 지원 난이도의 `Feedback` 보존, 재호출 검증 포함 | 통과 |
| 캠페인 전체 재현 | 실제 캠페인의 해당 임무를 생성하기 전 저장에서 네 Golden Path 임무와 최종 요새를 진행. 포털 실물 출현·저장 후 재개를 관찰 | 생성된 편성 및 복원 상태가 표와 일치 | 전술 빠른 시작, 실제 추첨 함수, SDK 스포너 시험까지 수행. 해당 진행도의 개인 캠페인에서 전체 임무·저장 재개는 실행하지 않음 | 미실행 |

### 최종 요새 추첨

WotC의 `GetConfigurableEncounter`에 FL 20, 경계 수준 8을 주고 두 격리 실행에서 포털별 384회와 1,024회씩, 합계 8,448회를 호출했다. 아래의 등록 수는 확률에 쓰이는 중복 추첨권을 포함한다. 관찰 수는 표본 안에 실제 반환된 서로 다른 조우 ID 수다.

| 포털 | 기본 고유 편성 | 등록 추첨권 | 1,408회 중 관찰한 ID | 최종 인원 |
|---|---:|---:|---:|---:|
| T1 일반 증원 | 8 | 14 | 14 | 3~4 |
| T2 일반 증원 | 10 | 16 | 16 | 3 |
| T3 일반 증원 | 6 | 8 | 8 | 3 |
| 정화팀 | 2 | 12 | 12 | 3 |
| 아바타 1기 | 7 | 60 | 60 | 7~8 |
| 아바타 2기 | 7 | 42 | 42 | 5 |

정화·아바타 세 목록은 원래 추첨권 2·10·7개 각각에서 여섯 후보가 같은 횟수로 추가돼 총 114개가 된다. 아바타 수 0·1·2와 기존 편성 간 상대 비중을 확인했다. 원래 40개 고유 편성의 강화 추첨권은 T1 12/14, T2 12/16, T3 4/8, 단일 아바타 6/10, 이중 아바타 7/7이다. 다른 활성 모드도 T1~T3에 같은 이름의 별도 버킷을 등록한다. LWOTC의 교체 대상은 최초 일치 버킷이고, 실제 8,448회 추첨 결과는 모두 위 표의 해당 버킷 안에 있었다.

### 빌드 및 배포 확인

WotC SDK 최종 배포 빌드에서 오류 0건·경고 0건. 배포 파일은 설명자 1개, INI 10개, UnrealScript 소스 5개, 컴파일 패키지 1개다. `Config/XComEditor.ini`의 `ModPackages`와 `Config/XComEngine.ini`의 `NonNativePackages`에 같은 패키지명이 등록돼 있다. 출시 파일을 다시 열어 내장 소스 다섯 개를 SDK 매크로 확장 후 대조하고, 직렬화된 보호막 기본값 `CoarseBasharShieldDR`, `eDupe_Ignore`를 확인했다.

- 최종 `Script/CoarseEnemyAIAndEncounters.u`는 86,809바이트. SHA-256은 `22e315c7ec920cc21e7dc5cf98c1e25d824331003a7abc7816f297d4d2c9a0ec`이다. rev001 대조군은 `df88e5b908351665f02a6b8afbf7756e46fe14c89575c707cc37a0b94c119e91`이다.
- 패키지 버전 845/120. export 194개, import 231개 중 공급 패키지 4개와 그 안의 이름 227개를 확인했다. Core 15개에는 엔진 자체 반영 타입 12개가 포함된다. Engine 5개, `XComGame` 194개, `ARFMDarkEvents` 13개다. SDK에는 실제 배포 `ARFMDarkEvents.u`를 사용했다. 직접 공급 모드의 배포 바이너리는 `DLC_2`의 동결 클래스·생성 함수 두 개 및 반환값, `DLC_3`의 Overdrive 클래스를 참조한다. `DLC_2` 사본 3개와 `DLC_3` 사본 2개에서 이 공개 참조와 함수 속성 구성이 일치했다. 기존 공개 함수·구조체의 삭제는 없었고, 활성 모드의 배포 소스·설정에서 이 로컬 패키지를 참조하는 제삼자 호출은 발견되지 않았다.
- 실제 WotC 엔진 빌드는 8917. Highlander 본체·Core·Engine·`XComGame`·`DLC_2`는 모두 런타임 버전 **1.32.0**, 개정 `1cba26`를 반환했다. 본체(1796402257)는 `CookedPCConsole`의 패키지와 `X2WOTCCommunityHighlander.u`, `DLC_2` 제공 모드(2635921321)는 별도 스크립트를 제공한다. 실제 배포 클래스의 생성과 기능 실행을 확인했다. UE 로그에는 로컬 모드 폴더와 설정 경로까지 기록되고 선택된 .u의 절대 파일명은 표시되지 않았다.
- 같은 이름의 바이너리 후보는 아래에 기록했다. 경로는 Steam 라이브러리 또는 이 저장소의 루트 기준이며 시험에서는 각 경로의 별도 사본을 사용했다. SHA-256이 다른 사본은 파일의 실체를 구별한다. 경로까지 기록되지 않은 선택은 **미확인**이다. 이번 배포에서 변경한 패키지는 로컬 `CoarseEnemyAIAndEncounters.u` 하나다.

<details>
<summary>활성 설치에서 발견한 동명 .u의 위치와 SHA-256</summary>

설치 원본·현재 활성 모드의 동명 패키지는 13종, 65개 파일이다. 이와 별도로 기존 rev001과 새 rev002의 로컬 배포 경로도 아래에 포함했다.

| 이름 | 전체 경로 | SHA-256 |
|---|---|---|
| `CoarseEnemyAIAndEncounters.u` | `rev001/CoarseEnemyAIAndEncounters/Script/CoarseEnemyAIAndEncounters.u` | `df88e5b908351665f02a6b8afbf7756e46fe14c89575c707cc37a0b94c119e91` |
| `CoarseEnemyAIAndEncounters.u` | `rev002/CoarseEnemyAIAndEncounters/Script/CoarseEnemyAIAndEncounters.u` | `22e315c7ec920cc21e7dc5cf98c1e25d824331003a7abc7816f297d4d2c9a0ec` |
| `DLC_1.u` | `steamapps/common/XCOM 2/XCom2-WarOfTheChosen/XComGame/Script/DLC_1.u` | `454c9880c101cbf39de008a171caf09648b22c746c715a6184e9552c08f87f80` |
| `DLC_1.u` | `steamapps/common/XCOM 2/XCom2-WarOfTheChosen/XComGame/DLC/DLC_1/Script/DLC_1.u` | `127e877ea643f98aac5819d9cc2174b1299185abefa7de45a9dda1cf28bd5d2c` |
| `DLC_2.u` | `steamapps/common/XCOM 2/XCom2-WarOfTheChosen/XComGame/Script/DLC_2.u` | `3e3fb474868f285cf387ca7ce7bb62649c0d04245d99e2e9206f4158331f9132` |
| `DLC_2.u` | `steamapps/common/XCOM 2/XCom2-WarOfTheChosen/XComGame/DLC/DLC_2/Script/DLC_2.u` | `c408ea3579a7edf8b4306280629b0b8fcdb39807e66bc6ca1dd57d3214a0d5c8` |
| `DLC_2.u` | `steamapps/workshop/content/268500/2635921321/Script/DLC_2.u` | `168daf6b28f6daadb2cac86ccf795e20f63127d2fe35875530e6da293cf91d28` |
| `DLC_3.u` | `steamapps/common/XCOM 2/XCom2-WarOfTheChosen/XComGame/Script/DLC_3.u` | `300516cde868d918fee3c61e416dc293e2db7835b7c1069b5fe26dc151bb6259` |
| `DLC_3.u` | `steamapps/common/XCOM 2/XCom2-WarOfTheChosen/XComGame/DLC/DLC_3/Script/DLC_3.u` | `5fee5d5cf970fa4acfb7bb1c99901bdd84be1e5ff8945cca2cbdaafebf4ca6fe` |
| `LoadoutApi_1_0_0.u` | `steamapps/workshop/content/268500/2133397762/Script/LoadoutApi_1_0_0.u` | `ba743781d3c5b7ad98599dadfc117cd0d71d77e43469f79ac7e0849d271f80e1` |
| `LoadoutApi_1_0_0.u` | `steamapps/workshop/content/268500/2133399183/Script/LoadoutApi_1_0_0.u` | `2efc15c53ce0b6c80c7fd61737e5c07be3adb75cfed500a9b7f8da5c6a993f96` |
| `LoadoutApi_1_0_0.u` | `steamapps/workshop/content/268500/2569592723/Script/LoadoutApi_1_0_0.u` | `c08647f084faeb9e30efb59b2f611256a1acdd445a765b9c28cdf32cc1fc1def` |
| `LW_Tuple.u` | `steamapps/workshop/content/268500/1122974240/Script/LW_Tuple.u` | `d7f5109a549201439579ec5705be71fc8caa78c89ad27976cf1d163802a1c56f` |
| `LW_Tuple.u` | `steamapps/workshop/content/268500/1519841231/Script/LW_Tuple.u` | `484e127978d18f41b8f1b7fa47b54b6a382e0275b8814ede19e7b857c2f2f93a` |
| `LW_Tuple.u` | `steamapps/workshop/content/268500/1731235406/Script/LW_Tuple.u` | `e41e9bddf836fcd1ecb66947fd3569506324f9449c445d08d88445838ae5f4b4` |
| `LW_Tuple.u` | `steamapps/workshop/content/268500/2115077818/Script/LW_Tuple.u` | `d21a8545f6c394fa1c91c8eb0428b0e4bee1e71825e30ab3e029c52098ccc91d` |
| `LW_Tuple.u` | `steamapps/workshop/content/268500/2165999454/Script/LW_Tuple.u` | `85eca487d673bda9a1bc736fa0da6217b28e4c29647e84c0671f7a1907afc9bf` |
| `LW_Tuple.u` | `steamapps/workshop/content/268500/2285967646/Script/LW_Tuple.u` | `906731c377aace0a8aa3d6d086f8785e85b3687bd68be71f4507ee1c0688b86a` |
| `LW_Tuple.u` | `steamapps/workshop/content/268500/2368109302/Script/LW_Tuple.u` | `cf176027e62dae06c30a499b531648c9608565bb107b261e55166e639a790b1c` |
| `LW_Tuple.u` | `steamapps/workshop/content/268500/2663990965/Script/LW_Tuple.u` | `389690d3744411902ab3c944058c2de88095c986192dc7d2fb7f11114bee52d8` |
| `LW_Tuple.u` | `steamapps/workshop/content/268500/2819129273/Script/LW_Tuple.u` | `fe24a29add84b025a0e760fd905c5b3fccea5fb84f176351db8cfae410354260` |
| `LW_Tuple.u` | `steamapps/workshop/content/268500/2832773856/Script/LW_Tuple.u` | `8d2b1ed11c78eb75c67d35be58be579af706a8a837f19228a0412804b1980fda` |
| `LW_Tuple.u` | `steamapps/workshop/content/268500/3209556182/Script/LW_Tuple.u` | `cb9fb0e2f00d6173b7cdcba3d35abc8fd40b564e600e226385b121b048162020` |
| `LW_Tuple.u` | `steamapps/workshop/content/268500/3255703451/Script/LW_Tuple.u` | `eec37614ccf5181d072902b2433057f332803d07c0ee2f0ef0ded8ed593eca64` |
| `LW_Tuple.u` | `steamapps/workshop/content/268500/3647614305/Script/LW_Tuple.u` | `476216260ecebdb96c8f0a3f49bf36f519f8c675f951b012354301a9b2551209` |
| `LW_Tuple.u` | `steamapps/workshop/content/268500/934236622/Script/LW_Tuple.u` | `447cb7dbc77b070a0a3f2b4f02c66646d0da98310ec267fcbcd2f97fc8c56415` |
| `LW_Tuple.u` | `steamapps/workshop/content/268500/2377251739/Script/LW_Tuple.u` | `1778f4078db9ab09022834bea1d6a700d85e31f49d0f7eb7db9d2fee0a1b14f3` |
| `MeristBuffMe.u` | `steamapps/workshop/content/268500/3255703451/Script/MeristBuffMe.u` | `a3777cf70d7d20df1eaa050e5a0caa4b5c41822039e985e0302366aa9bee345c` |
| `MeristBuffMe.u` | `steamapps/workshop/content/268500/3647614305/Script/MeristBuffMe.u` | `05ba169e0e296fcd12cc3a3532d308d52bd0fc7330d3f0474c219a61a7d3b343` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/1122974240/Script/ModConfigMenuAPI.u` | `2ddb8e3ad49a21a4406011ee48717c9b9a92f3b5ff61fb0b9ac67bce7c46fb3a` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/1124410215/Script/ModConfigMenuAPI.u` | `2216627c47171c925b5a7ae811ffa99f1d8b09262cc253564c87ba257bfe9669` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/1126395106/Script/ModConfigMenuAPI.u` | `549ba0b05484a779facf80b51f39fd663692a6e13fb83761e6126d340f2f54c8` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/1273848330/Script/ModConfigMenuAPI.u` | `5529645da9dbd9a8d1cc114584a9a6607b0237d7673bcf0330269326b46ee8cc` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/1276342555/Script/ModConfigMenuAPI.u` | `f64a4322458be8ea23aec89149961da1f06db6609d80d5088a58e60bbb42a986` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/1440233515/Script/ModConfigMenuAPI.u` | `867c4effed2a00649bf21ceff57a65a2d811f24aa541be420c7942ab7ce157a4` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/1737532501/Script/ModConfigMenuAPI.u` | `f5d577878e7def1e416aed66369b82b2218d9dba981edbed9a58df75eb9ef36c` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/1782917748/Script/ModConfigMenuAPI.u` | `a18e23c865786ba87d6fd9560fbbde25f7141538a4edec8119dbf7322fc3e836` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/2405013108/Script/ModConfigMenuAPI.u` | `e59cc52a5f876dd9f7807bd4fcbc5782fba1725f4277d13f3547b29642c917f0` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/2550561145/Script/ModConfigMenuAPI.u` | `49c158796f127b0d43d6339ed233b0d76ee4db159f221534b4a220d74f5c9322` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/2569592723/Script/ModConfigMenuAPI.u` | `8bbe01de3d8ec546076261e9f1507eaba68f748d32272ab6a23745426ba267d7` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/2571476425/Script/ModConfigMenuAPI.u` | `0e4d47de5747eca8bcfa8be4c72cf64f3634731aec818e0d244af38e8c40ba94` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/2663990965/Script/ModConfigMenuAPI.u` | `b2e03649083dd2dd0d0be4a883ad055427a92308977db924178ee3efc63ebd76` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/2995251401/Script/ModConfigMenuAPI.u` | `fbed8e606624c7a708a5839baf877289d7d12f144a39e2425049c8756cd994f8` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/2995259605/Script/ModConfigMenuAPI.u` | `cbdd213ec5fb2b83d791832f3f1621c022382698d91be47c5f9a010a814a512a` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/3002469584/Script/ModConfigMenuAPI.u` | `5d1e274595237e2251f045bb2c2469b92f2e70c2e03a3a4806a70409de1a7ad9` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/3706139879/Script/ModConfigMenuAPI.u` | `c032ceca4b4b2c8d5f174bf318c1b53afef6f2e69bb8b80948ad6e5a09a98507` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/648410303/Script/ModConfigMenuAPI.u` | `a37c2f88b1f79a43f0bcaebccbad219e6a274f8e31c0e7eb34b43940a84057bb` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/667104300/Script/ModConfigMenuAPI.u` | `9d9bc098d662ed5b05aeeae04e80f9e77bcdb59b4000b592220677c5450c6dc3` |
| `ModConfigMenuAPI.u` | `steamapps/workshop/content/268500/2438621356/Script/ModConfigMenuAPI.u` | `11cd82af953b1b970509725cfcf37e677119f7a34563a6094ce82a780038b2c4` |
| `TLE.u` | `steamapps/common/XCOM 2/XCom2-WarOfTheChosen/XComGame/Script/TLE.u` | `56805b276f4b602ad149ae955c93733cf2ce5987d184f4868b251d0debdcee6f` |
| `TLE.u` | `steamapps/common/XCOM 2/XCom2-WarOfTheChosen/XComGame/DLC/TLE/Script/TLE.u` | `c6c1d705c3859558101991c750869ed15b294f35c97d75125bcf877e69fda7ec` |
| `WallClimbOverride.u` | `steamapps/workshop/content/268500/1561030099/Script/WallClimbOverride.u` | `9f4502844e56699aac0b158dd77cba9b34a7cbc487e8921f6d779bda0cea2700` |
| `WallClimbOverride.u` | `steamapps/workshop/content/268500/2663990965/Script/WallClimbOverride.u` | `49bccdd2516acf988acb813d99b0b14d140f4037c2fbd1e96bab23918550cf79` |
| `WallClimbOverride.u` | `steamapps/workshop/content/268500/3255703451/Script/WallClimbOverride.u` | `bf02bbf8da39bdd87b208b79b5be32337149ca4b1f5f04f5b4cec960ebc98186` |
| `XCom_DLC_Day0.u` | `steamapps/common/XCOM 2/XCom2-WarOfTheChosen/XComGame/Script/XCom_DLC_Day0.u` | `d253f36966f30801db7d94371a7fbd77da09c602ef7dd4aea29f5726684200e6` |
| `XCom_DLC_Day0.u` | `steamapps/common/XCOM 2/XCom2-WarOfTheChosen/XComGame/DLC/XCom_DLC_Day0/Script/XCom_DLC_Day0.u` | `40104b55b6baaad0b2a5cca27cf66e237f35f8d6b140e91b880125139324553a` |
| `XModBase_Core_2_0_1.u` | `steamapps/workshop/content/268500/1519841231/Script/XModBase_Core_2_0_1.u` | `e050d21ada869553c32574883a3a23c8d0687fceebad2e318324147083472d87` |
| `XModBase_Core_2_0_1.u` | `steamapps/workshop/content/268500/1731235406/Script/XModBase_Core_2_0_1.u` | `d09721e3b2b4c9730058146f006d1401312672a710e5cc2267be1ef3575250e8` |
| `XModBase_Core_2_0_1.u` | `steamapps/workshop/content/268500/2115077818/Script/XModBase_Core_2_0_1.u` | `b789fc820b46c65607f22e876ccf3424e2f28492f96f5391570f169e278d24dc` |
| `XModBase_Core_3_0_0.u` | `steamapps/workshop/content/268500/2663990965/Script/XModBase_Core_3_0_0.u` | `0492e477144a86de52df412cf6cbeb33073bc796ca145ff94461e9f79d771e98` |
| `XModBase_Core_3_0_0.u` | `steamapps/workshop/content/268500/3255703451/Script/XModBase_Core_3_0_0.u` | `85503e8a486d4a737e7cfa4c84300d4d33ebf8e4e890f03b02b4125761076b17` |
| `XModBase_Interfaces.u` | `steamapps/workshop/content/268500/1519841231/Script/XModBase_Interfaces.u` | `4107b722f85727b6a1a32121c249393639ce6b86ec0cd5bd6710d8102460887d` |
| `XModBase_Interfaces.u` | `steamapps/workshop/content/268500/1731235406/Script/XModBase_Interfaces.u` | `c4a2879acbb0f60416f4a7eb8662932b7a05d31d2d8a5769c366491e88db538f` |
| `XModBase_Interfaces.u` | `steamapps/workshop/content/268500/2115077818/Script/XModBase_Interfaces.u` | `8a849fe8570dc1fc688e8b1cdbc48e4cc23d0fdd6db41ffd91004193aad0bc4b` |
| `XModBase_Interfaces.u` | `steamapps/workshop/content/268500/2663990965/Script/XModBase_Interfaces.u` | `fdedaf8553012da984bab38cdb827665c549026846be5524f9188ccb9a30256a` |
| `XModBase_Interfaces.u` | `steamapps/workshop/content/268500/3255703451/Script/XModBase_Interfaces.u` | `303b826a0e66a74825515ea6d89d9bc2d5ac1d55148a7cc594528caeb057e8de` |
| `XModBase_Interfaces.u` | `steamapps/workshop/content/268500/3647614305/Script/XModBase_Interfaces.u` | `05c21bbb5b3b86df961e10774394aa0300b656e9fe69d6b3152d25bbe42ed796` |

</details>

### 같은 검증을 반복하는 방법

1. 설치 절차에 따라 rev002만 선택하고 게임을 시작한다. `Launch.log`에서 `CoarseEnemyEquipment is abstract`와 Omega의 잘못된 `ForcedBossLeader` 줄이 발생하는지 확인한다. AI는 LWOTC가 주 메뉴에 진입해 행동을 다시 구성한 뒤 검사한다.
2. 빠른 전술 시작에서 XCOM 병사 근처에 `FrostLancer_M1`과 `AHWOutsiderMagna`를 **적 팀**으로 배치해 교전시킨다. 전술 이력에서 랜서의 `MZ_FDFrostAxeSlash`, 단서 추적자의 이동·사격·경계 중 가능한 행동을 확인한다. 습격자 특공대는 발각 직후 첫 사격·도약 조건을 막은 뒤 이동 가능한 지형에서 다음 후보를 확인한다.
3. 포지는 ZERO SANITY를 각각 켜고 끈 전략 저장에서 일반 보스와 Extreme 전용 조우를 따로 생성한다. 방송탑은 보호 코덱스와 단독 드론을 각각 확인한다. 최종 요새는 임무 `GP_FortressShowdown_LW`의 실제 포털을 열어 정화팀·단일 아바타·이중 아바타의 마지막 병력과 아바타 수를 확인한다.

## 보관된 검증 기록

아래 발췌에는 시험 당시의 시간, 내부 식별자와 표적 번호가 남아 있다. 요새 여섯 포털은 게임의 추첨 함수와 SDK 스포너로 검사했다. 캠페인에서 포털을 실제로 열고 전술 저장을 다시 불러오는 사례는 해당 진행도의 저장으로 재현해야 하며, rev002에서는 미실행이다.

- [rev001의 시작 오류](#rev001control)
- [일반 전술 전투](#playedfinal)
- [사령관 전투와 추가 추첨](#commanderfinal)
- [누락 루트 랜서의 실제 도끼 공격](#visibletarget)
- [첫 요새 추첨](#nativeportals)
- [최종 SDK 빌드](#releasefinal)
- [SDK 71개 검사](#qaverified)

## 검증 로그 발췌

각 항목은 해당 시험에서 기록한 로그 행이다. 타임스탬프와 게임 이력 번호는 각각의 실행을 기준으로 한다.

### Rev001Control

```text
[0034.23] Critical: appError called: Can't create object None: class CoarseEnemyEquipment is abstract
```

### PlayedFinal

```text
[0218.60] ScriptLog: R2P|ACT|604|FrostLancer_M1|MZ_FDFrostAxeSlash|2227
[0230.60] ScriptLog: R2P|ACT|656|AHWOutsiderMagna|PistolOverwatch|3868
```

### CommanderFinal

```text
[0130.23] ScriptLog: R2P|SETDIFF|2
[0227.81] ScriptLog: R2P|ACT|608|FrostLancer_M1|MZ_FDFrostAxeSlash|2227
[0121.85] ScriptLog: R2P|DRAWEND|LIST_FinalShowdown_T1RNF
[0121.86] ScriptLog: R2P|DRAWEND|LIST_FinalShowdown_T2RNF
[0121.86] ScriptLog: R2P|DRAWEND|LIST_FinalShowdown_T3RNF
[0121.86] ScriptLog: R2P|DRAWEND|LIST_FinalShowdown_PurgeTeam
[0121.86] ScriptLog: R2P|DRAWEND|LIST_FinalShowdown_AvatarTeam
[0121.87] ScriptLog: R2P|DRAWEND|LIST_FinalShowdown_DualAvatarTeam
```

### VisibleTarget

```text
[0166.67] ScriptLog: R2P|ACTORROOT|X2CharacterTemplate_513|XGAIBehavior_CoarseFrost|GenericAIRoot|2.0000|True
[0229.67] ScriptLog: R2P|ACT|674|FrostLancer_M1|MZ_FDFrostAxeSlash|2179
```

### NativePortals

```text
[0122.34] ScriptLog: R2P|DRAW|LIST_FinalShowdown_T1RNF|Showdown_T1RNF_CodexSwarm_LW_TJ_Req_FinalTier|26
[0122.34] ScriptLog: R2P|DRAW|LIST_FinalShowdown_T1RNF|Showdown_T1RNF_CodexSwarm_LW_TJ_Req_FinalTier_ExtraRoll|26
[0122.34] ScriptLog: R2P|DRAWEND|LIST_FinalShowdown_T1RNF
[0122.35] ScriptLog: R2P|DRAWEND|LIST_FinalShowdown_T2RNF
[0122.35] ScriptLog: R2P|DRAWEND|LIST_FinalShowdown_T3RNF
[0122.35] ScriptLog: R2P|DRAWEND|LIST_FinalShowdown_PurgeTeam
[0122.35] ScriptLog: R2P|DRAWEND|LIST_FinalShowdown_AvatarTeam
[0122.35] ScriptLog: R2P|DRAWEND|LIST_FinalShowdown_DualAvatarTeam
```

### ReleaseFinal

```text
[0005.29] Log: Success - 0 error(s), 0 warning(s) (0 Unique Errors, 0 Unique Warnings)
```

### QaVerified

```text
[0007.76] ScriptLog: COARSE-QA 71 checks 0 failures
```
