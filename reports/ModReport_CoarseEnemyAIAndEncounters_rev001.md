# LWOTC Coarse 적 AI와 Tedjam 임무 통합 · rev001

적이 행동을 건너뛰거나 유효한 표적을 놓치는 분기를 고쳤다. 나이트메어는 일반 근접 표적도 끝까지 평가하고, 어벤저 방어전에서는 자신의 잠복 해제 능력을 사용한다. Tedjam 플러그인 수정에서 정한 일반 병력 교대, 스토리 임무 편성, 최종 요새 포털의 강화·명단 복원·후반 Requiem 추가 추첨을 로컬 모드 하나에 담았다.

- 모드 이름은 **LWOTC Coarse - Enemy AI and Encounters**, 런처 식별자는 `CoarseEnemyAIAndEncounters`다. [배포 폴더](../rev001/CoarseEnemyAIAndEncounters/)
- 기준은 Windows WotC, 설치된 LWOTC Experimental 및 Ted Jam, Workshop의 **Requiem Legion: Coarse Edition** 배포본 `3555944655`다. 과거 수정본과 현재 원본을 별도로 읽고 마지막에 대조했다. 이전 Golden Path 오버라이드 AI 설정 268개 행을 모두 포함하며, 이번 점검으로 33개 행을 추가했다. 행 수에는 UE3 배열의 삭제·추가 연산이 포함된다.
- 수정한 파일은 `.XComMod` 1개, `Config`의 INI 10개, `Src`의 UnrealScript 4개, `Script`의 컴파일 패키지 1개다. Workshop이나 게임 원본에 덮어쓸 파일은 없다.

## 적용 방법

1. 런처의 로컬 모드 검색 경로에 `rev001`을 추가하고 새로 고친다. 이 경로를 Workshop 경로 다음에 둔다. 모드 목록에서 **LWOTC Coarse - Enemy AI and Encounters**를 켠다.
2. Workshop ID **3555944655**와 원본 **Totally Reasonable Definitely Not Psychotic Tedjam Plugin** **3835619377**을 함께 켠다. 원본 플러그인이 ZERO SANITY 옵션(`ZeroSanity`)과 기본 임무 처리를 등록한다. Coarse의 내부 모드 ID는 `AHarderWarAbsurdAliens`다. 확인 시점의 `XComModOptions.ini`에는 원본 Tedjam과 나머지 필수 ID 5개가 있었고 Coarse ID는 없었다.
3. `Config/XComGame.ini`의 필수 모드는 Community Highlander, LWOTC, Ted Mod Jam for LWOTC, Coarse, `ARFMDarkEvents`, `ARFMAdventPack`, 원본 Tedjam 플러그인이다. 이전에 쓰던 Custodian 등 병력 제공 모드도 함께 사용한다. 이전 로컬 통합본 `LWOTCEnemyTierAIOverride`, `LWOTCEnemyTierAIGoldenPathOverride`, `LWOTCFortressShowdownReinforcementOverride`, `LWOTCFortressShowdownEliteReinforcements`, `LWOTCFortressShowdownLateRequiem`은 끈다.
4. 게임을 재시작하고 임무 생성 전의 전략 세이브로 확인한다. 이미 전술 세이브에 저장된 적은 생성 당시의 편성을 갖는다. 작업 중 사용자 런처 설정이나 캠페인 세이브를 변경하지 않았다.

## 적 전술 AI와 장비

| 대상 | 플레이 중 동작과 실패 시 처리 | 확인 위치 |
|---|---|---|
| Coarse 나이트메어 | 기본판·LW 어벤저 방어전의 잠복 해제 분기를 실제 캐릭터 루트에 연결했다. 일반 교전에서 기존 민간인 우선순위를 유지한다. 그다음 근접 후보 전부를 평가하며 경계·제압은 점수 보너스로 작동한다. 공격 가능한 대상이 없으면 기존 추적·이동 분기로 진행한다. | `Config/XComAI.ini`의 `AHWChryssalidMagna::CharacterRoot`, `NightmareRedAbilitySelector`, `SelectBestTargetForNightmareMelee` |
| 헌터·워록·Frost·공통 행동 | 헌터의 중복된 자식 번호·무기별 표적 선택, 워록의 자기 호출, Frost 계열의 누락 참조, Fan Fire 대소문자 중복, 공포·선택받은 자 경계 재등록, VIP 루트 괄호를 정리했다. 선택 플러그인의 이름과 우선순위를 적용한 최종 행동 트리에서 확인했다. | `Config/XComAI.ini`의 `TPYChosenWarlockFlush`, `UpdateChosenOverwatchEffectVar`, `VIPRoot` 및 LW `OverrideBehaviors` |
| ADVENT Medic·Praetorian·Frost Adder·Cryo Priest | 의무병은 앞에 체력 60%를 넘는 후보가 있어도 뒤의 치료 대상을 검사한다. Praetorian은 명령 실행 분기로 이어지고, Frost Adder는 결박 유지, Cryo Priest는 냉기 수류탄 최소 2표적 기준을 사용한다. 스나이퍼·Raptor 전용 사격과 Blood Tide 반응 순서도 포함한다. | `Config/XComAI.ini`의 `EvaluateTargetsAdventMedikit`, `AHWPraetorianLieutenantsOrders`, `FrostAdder_RedAbilitySelector`, `CryoPriestGrenadeProfile`, `ARFMDE_BloodTideReaction` |
| Coarse 특수 적 | Andromelid의 엄폐 행동, Taipan 권총의 측면 표적, Niven·Seraph·Mechapede의 표적 평가를 포함했다. Altar Desolate와 Cyberdisc Death Blossom은 원본 효과 정의로 인해 유효한 범위 후보가 잘못 탈락하는 검사를 해제했다. 일반 Desolate·Death Blossom은 최소 1표적, 테러용 Desolate는 최소 4표적이다. | `Config/XComAI.ini`의 `TaipanHuntPistol`, `MechapedeTargetEvaluations`, `AHWAltarDesolateProfile`, `AHWAltarDesolateTerrorProfile`, `AHWDeathBlossomProfile` |
| Calendarium 및 ARFM 장비 | 장비가 요구하는 Highlander, Sectoid Launcher Fuse, Avatar Power가 없을 때 원본 생성 함수 `CreateARFMTPY_JANHighlander`, `CreateARFMPYP_SectoidLauncherFuse`, `CreateARFMDESW_AvatarPower`로 등록한다. Wall은 MegaTank, WholeHearted는 MassFire를 지급한다. 원본의 잘못된 이름으로 객체를 다시 생성하면 기존 능력까지 바뀌는 현상을 SDK에서 재현했다. Wall과 MassFire는 처음부터 전용 객체 이름을 사용한다. MassFire는 원본의 원뿔, 탄약, 재사용 대기시간, 환경 피해 설정을 사용하며 기존 MassBombard도 보존한다. | `Src/CoarseEnemyAIAndEncounters/Classes/CoarseEnemyEquipment.uc`의 `RepairTemplates`, `RegisterMassFire` |
| 보호막과 Spectral Bug | 원본이 같은 Kinetic Plating 객체를 두 번 넣은 경우에만 두 번째 자리를 보호막 피해 감소로 바꾼다. 현재 보호막이 양수일 때 남은 피해와 설정값 중 작은 만큼 감소한다. Spectral Bug 근접 무기 12종에서는 실제 `ARFMBugFeedback`가 없고 유효한 `ARFMSpectralSlash`가 있을 때만 끊어진 지급을 제거한다. 폭발형의 자폭과 다른 모드가 공급하는 실제 Feedback을 유지한다. | `CoarseEnemyEquipment.uc`의 `RepairShieldEffect`, `RemoveMissingFeedback` 및 같은 소스 폴더의 `X2Effect_CoarseBasharShield.uc` |

## Tedjam의 병력 교대와 스토리 임무

- 일반 병력은 적 전력 수준(FL)에 따라 교대한다. `DefaultFollowers_LW`와 `AdventFollowers_LW`에서 드론 M1은 FL 7, 트루퍼 M2는 11, 척탄병 M2는 12, 로켓병 M2는 13까지 양수 가중치를 가진다. 다음 단계부터 각 하위형이 빠진다. 보호 대상 임무와 전용 편성은 각각의 출현표를 사용한다. `Config/XComEncounterLists.ini`, `XComEncounters.ini`, `XComSchedules.ini`, `XComMissionDefs.ini`가 이 경로를 연결한다.
- Berserker Omega Bridge가 실제로 공급한 `BerserkerOmega`는 테러·일반·ADVENT 지휘관의 보호 목록 세 곳에도 원본과 같은 FL·가중치로 한 번 들어간다. 확인한 브리지 값은 FL 16부터, 가중치 1이다. 캐릭터나 해당 원본 항목이 빠진 조합은 그대로 둔다. `X2DLCInfo_CoarseEncounters.uc`의 `IncludeOmegaInProtectedList`에서 처리한다.
- 블랙사이트·포지·사이오닉 게이트·방송탑의 `GoldenPath1_LW`~`GoldenPath4_LW`에 이전 수정의 강화 조합을 적용한다. ZERO SANITY는 원본 옵션을 따른다. 포지의 `WithTerror`가 일반 `OPN`보다 먼저 평가되고, 방송탑 보호 코덱스는 원래 전용 편성을 쓴다. 방송탑 단독 드론은 옵션과 관계없이 Cyberdisc로 바뀐다.
- 포지 **Extreme 전용 보스**는 ZERO SANITY를 꺼도 Mechapede 1기와 Cyberdisc 2기를 배치한다. 옵션을 켜면 Grandmaster 1기와 Exalted Custodian 2기를 더한다. 같은 일정의 **일반 보스**는 원본 Tedjam이 설정한 Mechapede 1기와 Gunship 2기를 쓴다. 전용 보스는 FL 0~7, 8~15, 16~99에서 각각 유효한 변형이 한 개다. 내부 ID `FL1_7`의 최소 제한은 0이다.
- `Config/XComGame.ini`와 `X2DLCInfo_CoarseEncounters.uc`의 `PostEncounterCreation`이 원본 Tedjam 처리 후 해당 슬롯을 교체한다. 다른 임무·조우는 넘어온 명단을 그대로 사용한다. 원본 플러그인의 다른 스토리·선택받은 자 요새 처리도 계속 실행된다. [Community Highlander의 DLC 실행 순서](https://x2communitycore.github.io/X2WOTCCommunityHighlander/misc/DLCRunOrder/)

## 최종 요새 포털 증원

대상은 `GP_FortressShowdown_LW`에서 맵 스크립트가 부르는 아래 여섯 목록이다. 선택된 명단은 스포너별로 담았다가 후순위 훅에서 한 번 복원한다. 동시에 걸린 다른 스포너의 명단, 전투 시작 배치, 별도 선택받은 자 증원에는 개입하지 않는다. Perilous Yearning 등 중간 훅이 대상 포털의 명단을 바꿔도 원래 추첨 결과를 복원한다. `X2DLCInfo_CoarsePortalCapture.uc`의 `PostReinforcementCreation`과 `RestoreRoster`에서 확인할 수 있다.

| 포털 | 기본 고유 편성 | 추가 슬롯 적용 전 추첨 항목 | 최종 포털 인원 |
|---|---:|---:|---:|
| T1 일반 증원 | 8 | 14 | 3~4 |
| T2 일반 증원 | 10 | 16 | 3 |
| T3 일반 증원 | 6 | 8 | 3 |
| 정화팀 | 2 | 2 | 3 |
| 아바타 1기 | 7 | 10 | 7~8 |
| 아바타 2기 | 7 | 7 | 5 |

- 일반 증원·아바타 호위의 기존 상위형 교체와 강화 편성의 추가 추첨을 반영했다. 모든 후보가 유효할 때 강화 편성의 비중은 T1이 12/14, T2가 12/16, T3가 4/8, 단일 아바타가 6/10, 이중 아바타가 7/7이다. `Config/XComEncounters.ini`와 `XComLW_Overhaul.ini`의 `ReplacementEncounterBuckets`가 원래 편성과 가중치를 정한다.
- 정화팀·단일 아바타·이중 아바타만 후반 Requiem **1기**를 추가한다. 후보는 `AHWLegate`, `AHWMechapede`, `AHWBerserkerMagnaT4`, `AHWIncubatorMagnaT4`, `AHWHeavyMechtoidT4`, `AHWCyberdiscT4`다. 세 목록의 기존 추첨 항목 19개 각각을 여섯 갈래로 확장해 114개가 된다. 후보별 비중은 1/6이고 기존 아바타 수와 편성 간 비중을 보존한다.
- `Config/XComCoarseEncounters.ini`의 `LateRequiemPool`에서 후보를 조정한다. 등록된 서로 다른 템플릿 6개가 필요하다. 후보 누락·중복이면 기존 목록을 사용한다. 특정 포털의 기본 편성이 없거나 고정 인원이 맞지 않으면 해당 포털의 목록 전체를 보존한다. 재호출 시 슬롯을 추가로 늘리지 않는다. `X2DLCInfo_CoarseEncounters.uc`의 `OnPostTemplatesCreated`와 `AddLateRequiemSlot`에서 판정한다.

## 검증

현재 설치 자료에서 WotC의 AI 설정·DLC 설정 3개와 Workshop 43개 모드의 AI 설정 70개를 읽었다. 프로젝트에서 비활성으로 지정한 배포본을 제외하고 Coarse를 명시적으로 포함했다. 동일 항목은 Workshop 폴더 번호순과 로컬 후순위로 병합하고, LWOTC의 `UIScreenListener_Shell.UpdateAIBehaviors`가 수행하는 삭제·추가·조건부 교체 우선순위를 적용했다. 아래의 행동 트리 수치는 이 구성에 대한 정적 결과다.

| 검증 방식 | 재현 조건·절차 | 기대 결과 | 관찰한 결과 | 상태 |
|---|---|---|---|---|
| 정적 AI 병합 | 통합본 적용 전후의 FName, 자식 참조, 번호, 구문, 재귀를 대조. Ted Jam Requiem Plugin 및 Reshi를 각각 켜고 끈 네 조합으로 반복 | 최종 이름이 하나씩이고 유효한 분기로 연결 | 기본 점검 구성에서 중복 이름 24→0, 미해결 자식 참조 발생 57→0, 번호 오류 7→0, 구문 오류 1→0, 순환 1→0. 네 조합 모두 최종 행동 6,006개에서 이 다섯 항목 0건 | 통과 |
| 표적 선택 모의 검사 | 게임의 후보 초기화·양수 점수 채택을 따라 일반 후보만, 일반 뒤 제압, 경계 뒤 일반, 혼합, 빈 목록을 순회 | 일반 후보를 채택하고 더 높은 보너스를 우선. 빈 목록은 표적 없음 | 5/5 일치. 원본은 일반 후보가 앞에 있는 두 후보 사례에서 유효 후보를 놓침 | 통과 |
| 정적 출현표 | 두 일반 부하 목록에서 네 병종의 교대 직전부터 FL 99까지 양수 가중치를 확인. 각 설정 내 `ETP_` 참조 교차 검사 | 네 경계 일치, 조우·일정·목록 연결 | 경계 8건 일치. `ETP_` 조우 224개, 버킷 93개, 일정 28개, 출현 목록 9개에서 신규 미해결 참조 0건 | 통과 |
| 스토리 분기 모의 검사 | 최종 스크립트를 읽어 4개 임무군·포지 원본 및 변형·보호 코덱스·임무 미지정에 ZERO SANITY 켬/끔을 적용. 포지 일반 보스는 원본 플러그인과 대조 | 전용 보스·추가 병력·우선순위·예외 슬롯 일치 | 44/44 일치. FL 0~99 각 값에서 포지 Extreme 변형 1개. 이전 Golden Path 수정본과 스토리 함수 일치 | 통과 |
| 정적 요새 추첨 | LWOTC가 마지막 `ReplacementEncounterBuckets`를 적용한 뒤 각 항목의 편성·고정 인원·아바타를 확인 | 기본 고유 편성 40개. 후반 세 포털에서 인원만 1 증가 | 여섯 목록의 항목 수 14/16/8/2/10/7. 후반 세 목록에서 기존 아바타 0/1/2기 보존 | 통과 |
| WotC SDK 빌드·패키지 | 격리 WotC SDK에서 실제 `ARFMDarkEvents.u`로 컴파일. 출력 파일을 다시 열어 내장 소스·기본값 및 외부 참조 대조 | 클래스 4개가 소스와 일치하고 참조 해석 | 최종 모드 컴파일 오류 0, 경고 0. 패키지 845/120, 내장 소스 4개와 보호막 효과 기본값 일치. import 207개, export 148개. 참조 공급 패키지 Core·Engine·XComGame·ARFMDarkEvents 확인 | 통과 |
| WotC SDK 실행 | 최종 바이너리를 로드. 포털 6종·중첩 스포너·명단 한 번 소비·대상 밖, 여섯 후보와 가중치·중복 실행·누락 편성, 방송탑과 Omega, 장비 등록·보호막을 실제 WotC 객체로 검사 | 로스터와 원래 가중치 보존, 누락 시 원복, 선택 장비 보존. 감소량 6에서 보호막 있으면 피해 10→4·3→0, 보호막 없으면 10→10 | `COARSE-QA 54 checks 0 failures`. 원본과 같은 잘못된 UObject 이름을 사용한 중간판에서 Wall과 WholeHearted 검사가 실패했고 최종판에서 통과. 다른 모드의 MassBombard와 기존 보너스 능력도 보존 | 통과 |
| 인게임 전술 AI | Coarse와 필수 모드를 켠 시험 캠페인에서 일반 표적과 경계·제압 표적을 함께 둔 나이트메어, 부상 아군을 둔 Medic, 헌터·워록 행동, Altar·Cyberdisc 범위 공격 관찰 | AI가 유효한 조건에서 행동하고 대상이 없으면 다음 분기로 진행 | 해당 구성의 실제 전술 턴 미관찰 | 미실행 |
| 인게임 임무·세이브 | 임무 생성 전 전략 세이브를 두 사본으로 나누어 ZERO SANITY 켬/끔으로 포지와 방송탑 생성. 최종 요새에서 일반·정화·아바타 포털 발동 후 전술 저장·불러오기 | 표와 같은 편성·아바타 수. 재진입 후 추가 슬롯 누적 없음 | 실제 캠페인·저장 재진입 미실행. 현재 런처 선택 파일에는 Coarse ID가 빠져 있음 | 미실행 |

배포 패키지 `Script/CoarseEnemyAIAndEncounters.u`는 72,487바이트이며 SHA-256은 `df88e5b908351665f02a6b8afbf7756e46fe14c89575c707cc37a0b94c119e91`이다. 최종 배포 파일 16개를 모두 다시 읽었다.

SDK 준비 시 ARFM 배포 패키지가 참조하는 `XComGameState_BattleData.AllowedAbilities`와 `DisallowedAbilities`의 접근 범위를 격리한 SDK 소스에서 맞췄다. 이 과정의 기반 패키지 재빌드는 오류 0건, 에디터 콘텐츠 누락 등을 포함한 경고 2,031건이었다. SDK 실행 검사는 능력 설명을 확장할 때 캠페인 UI의 `AbilityTag`가 없는 경고도 기록했다. 캠페인 화면의 설명·아이콘 표시는 인게임 확인 항목으로 남는다. 배포 대상은 통합 모드 패키지 한 개다.

<details>
<summary>SDK 동작 검사 54건을 재현하는 UnrealScript</summary>

WotC SDK 작업 사본에서 `Development/Src/CoarseIntegrationCheck/Classes/CoarseRulesCommandlet.uc`에 아래 소스를 둔다. Highlander 기반 `XComGame.u`, 원본 `ARFMDarkEvents.u`, 배포 모드 패키지를 SDK가 읽을 수 있게 하고 배포본 `XComCoarseEncounters.ini`와 원본 모드의 전용 설정을 작업 사본에서 읽도록 한다. 작업 사본에 `CoarseIntegrationCheck`라는 SDK용 모드를 만들고 `make -mods CoarseIntegrationCheck <작업 사본 안의 검사 모드 경로>`로 컴파일한다. 원본 게임·SDK 콘텐츠는 읽기 전용 검색 경로로 연결한다. `XComGame.com run CoarseIntegrationCheck.CoarseRules -nullrhi -unattended -nopause -nohomedir -nosteam`으로 실행하면 마지막 로그에서 검사 수와 실패 수를 볼 수 있다.

```unrealscript
class CoarseRulesCommandlet extends Commandlet dependson(XGGameData, XComAISpawnManager);
var X2Effect_Persistent TestEffect;
var XComGameState_Unit TestShieldedUnit;


var int Checks, Failures;

function Check(bool Result, string Label)
{
    ++Checks;
    if (!Result)
    {
        ++Failures;
        `log("QA FAIL" @ Label);
    }
}

function TestPortals()
{
    local XComGameState_BattleData Battle;
    local XComGameState_AIReinforcementSpawner One, Two;
    local PodSpawnInfo Pod, Nested;
    local array<name> Buckets;
    local name Bucket, ID;

    Battle = new class'XComGameState_BattleData';
    One = new class'XComGameState_AIReinforcementSpawner';
    Two = new class'XComGameState_AIReinforcementSpawner';
    Battle.MapData.ActiveMission.sType = "GP_FortressShowdown_LW";
    One.bKismetInitiatedReinforcements = true;
    Two.bKismetInitiatedReinforcements = true;
    Buckets.AddItem('LIST_FinalShowdown_T1RNF');
    Buckets.AddItem('LIST_FinalShowdown_T2RNF');
    Buckets.AddItem('LIST_FinalShowdown_T3RNF');
    Buckets.AddItem('LIST_FinalShowdown_PurgeTeam');
    Buckets.AddItem('LIST_FinalShowdown_AvatarTeam');
    Buckets.AddItem('LIST_FinalShowdown_DualAvatarTeam');
    foreach Buckets(Bucket)
    {
        ID = 'ResolvedPod';
        One.SpawnInfo.EncounterID = Bucket;
        Pod.SelectedCharacterTemplateNames.Length = 0;
        Pod.SelectedCharacterTemplateNames.AddItem('AdvPsiWitchM3');
        Pod.SelectedCharacterTemplateNames.AddItem('AHWLegate');
        class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarsePortalCapture'.static.PostReinforcementCreation(ID, Pod, 20, 20, Battle, One);
        Pod.SelectedCharacterTemplateNames[1] = 'AdvTrooperM1';
        Pod.SelectedCharacterTemplateNames.AddItem('UnexpectedGuard');
        class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarseEncounters'.static.PostReinforcementCreation(ID, Pod, 20, 20, Battle, One);
        Check(Pod.SelectedCharacterTemplateNames.Length == 2 && Pod.SelectedCharacterTemplateNames[0] == 'AdvPsiWitchM3' && Pod.SelectedCharacterTemplateNames[1] == 'AHWLegate', "restore" @ Bucket);
        Pod.SelectedCharacterTemplateNames[1] = 'Changed';
        class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarseEncounters'.static.PostReinforcementCreation(ID, Pod, 20, 20, Battle, One);
        Check(Pod.SelectedCharacterTemplateNames[1] == 'Changed', "consume" @ Bucket);
    }
    One.SpawnInfo.EncounterID = Buckets[0];
    Two.SpawnInfo.EncounterID = Buckets[3];
    Pod.SelectedCharacterTemplateNames[0] = 'Outer';
    Nested.SelectedCharacterTemplateNames.AddItem('Inner');
    class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarsePortalCapture'.static.PostReinforcementCreation(ID, Pod, 20, 20, Battle, One);
    class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarsePortalCapture'.static.PostReinforcementCreation(ID, Nested, 20, 20, Battle, Two);
    Pod.SelectedCharacterTemplateNames.Length = 0;
    Nested.SelectedCharacterTemplateNames.Length = 0;
    class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarseEncounters'.static.PostReinforcementCreation(ID, Nested, 20, 20, Battle, Two);
    class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarseEncounters'.static.PostReinforcementCreation(ID, Pod, 20, 20, Battle, One);
    Check(Pod.SelectedCharacterTemplateNames[0]=='Outer' && Nested.SelectedCharacterTemplateNames[0]=='Inner', "overlapping spawners");
    Battle.MapData.ActiveMission.sType = "Other";
    CheckExcluded(Pod, Battle, One, "other mission");
    Battle.MapData.ActiveMission.sType = "GP_FortressShowdown_LW";
    One.bKismetInitiatedReinforcements = false;
    CheckExcluded(Pod, Battle, One, "non-map reinforcement");
    One.bKismetInitiatedReinforcements = true;
    One.SpawnInfo.EncounterID = 'Unrelated';
    CheckExcluded(Pod, Battle, One, "other portal");
}

function CheckExcluded(out PodSpawnInfo Pod, XComGameState_BattleData Battle, XComGameState_AIReinforcementSpawner Spawner, string Label)
{
    local name ID;
    ID='OtherResolved';
    Pod.SelectedCharacterTemplateNames[0]='Original';
    class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarsePortalCapture'.static.PostReinforcementCreation(ID,Pod,20,20,Battle,Spawner);
    Pod.SelectedCharacterTemplateNames[0]='Changed';
    class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarseEncounters'.static.PostReinforcementCreation(ID,Pod,20,20,Battle,Spawner);
    Check(Pod.SelectedCharacterTemplateNames[0]=='Changed', Label);
}

function TestVariants()
{
    local XComTacticalMissionManager Manager;
    local ConfigurableEncounter Pod, Expanded;
    local EncounterBucket Bucket;
    local ConditionalEncounter Candidate;
    local int I, Index, Copies;
    local array<name> Extra;
    local name UnitName;
    Extra.AddItem('AHWLegate');
    Extra.AddItem('AHWMechapede');
    Extra.AddItem('AHWBerserkerMagnaT4');
    Extra.AddItem('AHWIncubatorMagnaT4');
    Extra.AddItem('AHWHeavyMechtoidT4');
    Extra.AddItem('AHWCyberdiscT4');
    Check(class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarseEncounters'.default.LateRequiemPool.Units.Length==6, "configured six candidates");
    foreach Extra(UnitName)
    {
        Check(class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarseEncounters'.default.LateRequiemPool.Units.Find(UnitName)!=INDEX_NONE, "configured candidate" @ UnitName);
    }
    Manager=new class'XComTacticalMissionManager';
    Manager.ConfigurableEncounters.Length=0;
    Manager.EncounterBuckets.Length=0;
    Pod.EncounterID='TestAvatar';
    Pod.MaxSpawnCount=2;
    Pod.ForceSpawnTemplateNames.AddItem('AdvPsiWitchM3');
    Pod.ForceSpawnTemplateNames.AddItem('FixedGuard');
    Manager.ConfigurableEncounters.AddItem(Pod);
    Candidate.EncounterID=Pod.EncounterID;
    Bucket.EncounterBucketID='LIST_FinalShowdown_AvatarTeam';
    Bucket.EncounterIDs.AddItem(Candidate);
    Bucket.EncounterIDs.AddItem(Candidate);
    Manager.EncounterBuckets.AddItem(Bucket);
    class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarseEncounters'.static.AddLateRequiemSlot(Manager, Bucket.EncounterBucketID);
    Check(Manager.EncounterBuckets[0].EncounterIDs.Length==12 && Manager.ConfigurableEncounters.Length==7, "two tickets, six distinct variants");
    foreach Extra(UnitName)
    {
        Copies=0;
        foreach Manager.EncounterBuckets[0].EncounterIDs(Candidate)
        {
            Index=Manager.ConfigurableEncounters.Find('EncounterID', Candidate.EncounterID);
            if (Index != INDEX_NONE)
            {
                Expanded=Manager.ConfigurableEncounters[Index];
                if (Expanded.MaxSpawnCount==3 && Expanded.ForceSpawnTemplateNames.Length==3 && Expanded.ForceSpawnTemplateNames[0]=='AdvPsiWitchM3' && Expanded.ForceSpawnTemplateNames[1]=='FixedGuard' && Expanded.ForceSpawnTemplateNames[2]==UnitName)
                {
                    ++Copies;
                }
            }
        }
        Check(Copies==2, "six-way weight" @ UnitName);
    }
    class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarseEncounters'.static.AddLateRequiemSlot(Manager,Bucket.EncounterBucketID);
    Check(Manager.EncounterBuckets[0].EncounterIDs.Length==12 && Manager.ConfigurableEncounters.Length==7, "repeat expansion");
    I=Manager.ConfigurableEncounters.Length;
    Bucket.EncounterBucketID='Incomplete';
    Bucket.EncounterIDs.Length=0;
    Candidate.EncounterID='TestAvatar';
    Bucket.EncounterIDs.AddItem(Candidate);
    Candidate.EncounterID='Missing';
    Bucket.EncounterIDs.AddItem(Candidate);
    Manager.EncounterBuckets.AddItem(Bucket);
    class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarseEncounters'.static.AddLateRequiemSlot(Manager,'Incomplete');
    Check(Manager.ConfigurableEncounters.Length==I && Manager.EncounterBuckets[1].EncounterIDs.Length==2, "missing encounter, atomic fallback");
}

function TestStory()
{
    local XComGameState_MissionSite Site;
    local PodSpawnInfo Pod;
    local name ID;

    Site=new class'XComGameState_MissionSite';
    Pod.SelectedCharacterTemplateNames.AddItem('OriginalDrone');
    ID='Lone_Drone_LW';
    Site.GeneratedMission.Mission.MissionFamily="Other";
    class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarseEncounters'.static.PostEncounterCreation(ID,Pod,1,1,Site);
    Check(Pod.SelectedCharacterTemplateNames[0]=='OriginalDrone', "other mission");
    Site.GeneratedMission.Mission.MissionFamily="GoldenPath4_LW";
    class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarseEncounters'.static.PostEncounterCreation(ID,Pod,1,1,Site);
    Check(Pod.SelectedCharacterTemplateNames[0]=='AHWCyberdisc', "broadcast lone drone");
    ID='GP_Broadcast_Codices_Extreme_LW_PROTECTED';
    Pod.SelectedCharacterTemplateNames[0]='OriginalProtected';
    class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarseEncounters'.static.PostEncounterCreation(ID,Pod,1,1,Site);
    Check(Pod.SelectedCharacterTemplateNames[0]=='OriginalProtected', "protected codex");
}

function TestOmega()
{
    local XComTacticalMissionManager Manager;
    local SpawnDistributionList List;
    local SpawnDistributionListEntry Entry;
    Manager=new class'XComTacticalMissionManager';
    Manager.SpawnDistributionLists.Length=0;
    List.ListID='TerrorLeaders_LW';
    Manager.SpawnDistributionLists.AddItem(List);
    List.ListID='ETP_Original_TerrorLeaders';
    Manager.SpawnDistributionLists.AddItem(List);
    class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarseEncounters'.static.IncludeOmegaInProtectedList(Manager,'TerrorLeaders_LW','ETP_Original_TerrorLeaders');
    Check(Manager.SpawnDistributionLists[1].SpawnDistribution.Length==0,"absent Omega");
    Entry.Template='BerserkerOmega';
    Entry.MinForceLevel=16;
    Entry.MaxForceLevel=99;
    Entry.SpawnWeight=1;
    Manager.SpawnDistributionLists[0].SpawnDistribution.AddItem(Entry);
    class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarseEncounters'.static.IncludeOmegaInProtectedList(Manager,'TerrorLeaders_LW','ETP_Original_TerrorLeaders');
    class'CoarseEnemyAIAndEncounters.X2DLCInfo_CoarseEncounters'.static.IncludeOmegaInProtectedList(Manager,'TerrorLeaders_LW','ETP_Original_TerrorLeaders');
    Check(Manager.SpawnDistributionLists[1].SpawnDistribution.Length==1 && Manager.SpawnDistributionLists[1].SpawnDistribution[0].Template=='BerserkerOmega' && Manager.SpawnDistributionLists[1].SpawnDistribution[0].MinForceLevel==16 && Manager.SpawnDistributionLists[1].SpawnDistribution[0].SpawnWeight==1,"optional Omega once");
}

function TestShield()
{
    local XComGameState_Unit Target;
    local X2Effect_Persistent Shield;
    local EffectAppliedData Params;
    Shield=TestEffect;
    Target=TestShieldedUnit;
    Check(Target.GetCurrentStat(eStat_ShieldHP)==8, "loaded real shield stat");
    Check(Shield.GetPostDefaultDefendingDamageModifier_CH(none,none,Target,none,Params,10.0,none,none)==-6.0, "shielded ten");
    Check(Shield.GetPostDefaultDefendingDamageModifier_CH(none,none,Target,none,Params,3.0,none,none)==-3.0, "shielded three");
    Target=new class'XComGameState_Unit';
    Check(Shield.GetPostDefaultDefendingDamageModifier_CH(none,none,Target,none,Params,10.0,none,none)==0.0, "unshielded");
}


function TestEquipment()
{
    local X2AbilityTemplateManager Abilities;
    local X2ItemTemplateManager Items;
    local X2AbilityTemplate Whole, Wall, Mega, Mass, OriginalMass;
    local X2WeaponTemplate Bug;
    local X2Effect Eff;
    local int CoarseShield, Plating;
    local X2AbilityTemplate OtherBombard;

    Abilities = new class'X2AbilityTemplateManager';
    Items = new class'X2ItemTemplateManager';
    Check(Abilities != none && Items != none, "live template managers");
    if (Abilities == none || Items == none)
    {
        return;
    }

    Whole = class'ARFMDarkEvents.ARFM_Abilities_Calendarium'.static.CreateARFMTPY_JANWholeHeartedPassive();
    Whole.AdditionalAbilities.AddItem('FixtureOtherGrant');
    Abilities.AddAbilityTemplate(Whole, true);
    OtherBombard=new(None, "ARFMTPY_JANMassBombard") class'X2AbilityTemplate';
    OtherBombard.SetTemplateName('ARFMTPY_JANMassBombard');
    OtherBombard.IconImage="FixtureOtherBombard";
    Abilities.AddAbilityTemplate(OtherBombard,true);
    Mega = class'ARFMDarkEvents.ARFM_Abilities_Calendarium'.static.CreateARFMTPY_JANMegaTank();
    Abilities.AddAbilityTemplate(Mega, true);
    Bug = new class'X2WeaponTemplate';
    Bug.SetTemplateName('SpectralBugM2T2_MeleeAttack');
    Bug.Abilities.AddItem('ARFMSpectralSlash');
    Bug.Abilities.AddItem('ARFMBugFeedback');
    Bug.Abilities.AddItem('EngagePsiSelfDestruct');
    Items.AddItemTemplate(Bug,true);
    class'CoarseEnemyAIAndEncounters.CoarseEnemyEquipment'.static.RepairTemplates(Abilities,Items);
    Mass = Abilities.FindAbilityTemplate('ARFMTPY_JANMassFire');
    OriginalMass = Mass;
    Check(Mass != none && Mass.Name=='ARFMTPY_JANMassFire' && X2AbilityMultiTarget_Cone(Mass.AbilityMultiTargetStyle)!=none && X2AbilityCost_Ammo(Mass.AbilityCosts[0]).iAmmo==1 && X2AbilityCost_Ammo(Mass.AbilityCosts[0]).bConsumeAllAmmo,"distinct MassFire cone and ammo");
    Check(Abilities.FindAbilityTemplate('ARFMTPY_JANMassBombard')==OtherBombard && OtherBombard.DataName=='ARFMTPY_JANMassBombard' && OtherBombard.IconImage=="FixtureOtherBombard","original MassBombard preserved");

    Check(Mass != none && Whole.AdditionalAbilities.Find('ARFMTPY_JANMassFire') != INDEX_NONE && Whole.AdditionalAbilities.Find('FixtureOtherGrant') != INDEX_NONE, "partially repaired WholeHearted");
    Wall = Abilities.FindAbilityTemplate('ARFMTPY_JANWallPassive');
    Check(Wall != none && Wall != Whole && Wall.Name == 'ARFMTPY_JANWallPassive' && Wall.AdditionalAbilities.Find('ARFMTPY_JANMegaTank') != INDEX_NONE, "Wall grants plating");
    Check(Abilities.FindAbilityTemplate('ARFMTPY_JANHighlander') != none, "Highlander template");
    Check(Abilities.FindAbilityTemplate('ARFMPYP_SectoidLauncherFuse') != none, "Sectoid Fuse template");
    Check(Abilities.FindAbilityTemplate('ARFMDESW_AvatarPower') != none, "Avatar Power template");
    foreach Mega.AbilityTargetEffects(Eff)
    {
        if (X2Effect_KineticPlating(Eff) != none) ++Plating;
        if (Eff != none && Eff.IsA('X2Effect_CoarseBasharShield')) ++CoarseShield;
    }
    Check(Plating == 1 && CoarseShield == 1, "one plating and one shield reduction");
    Check(Bug.Abilities.Length == 2 && Bug.Abilities.Find('ARFMSpectralSlash') != INDEX_NONE && Bug.Abilities.Find('EngagePsiSelfDestruct') != INDEX_NONE, "spectral slash and detonation kept");
    Whole = class'ARFMDarkEvents.ARFM_Abilities_Calendarium'.static.CreateARFMTPY_JANWallPassive();
    Whole.AdditionalAbilities.AddItem('FixtureOtherGrant');
    Abilities.AddAbilityTemplate(Whole,true);
    class'CoarseEnemyAIAndEncounters.CoarseEnemyEquipment'.static.RepairTemplates(Abilities,Items);
    Check(Whole.AdditionalAbilities.Find('ARFMTPY_JANMegaTank') == INDEX_NONE && Whole.AdditionalAbilities.Find('ARFMTPY_JANMassFire') != INDEX_NONE && Whole.AdditionalAbilities.Find('FixtureOtherGrant') != INDEX_NONE, "bad upstream WholeHearted fixed");
    Check(OriginalMass != none && Abilities.FindAbilityTemplate('ARFMTPY_JANMassFire') == OriginalMass, "existing MassFire preserved");
    OriginalMass = new class'X2AbilityTemplate';
    OriginalMass.SetTemplateName('ARFMBugFeedback');
    Abilities.AddAbilityTemplate(OriginalMass,true);
    Bug.Abilities.AddItem('ARFMBugFeedback');
    class'CoarseEnemyAIAndEncounters.CoarseEnemyEquipment'.static.RepairTemplates(Abilities,Items);
    Check(Bug.Abilities.Find('ARFMBugFeedback') != INDEX_NONE, "real optional feedback retained");
}

event int Main(string Params)
{
    TestPortals();
    TestVariants();
    TestStory();
    TestOmega();
    TestShield();
    if (InStr(Params,"OnlyBase") == INDEX_NONE) TestEquipment();
    `log("COARSE-QA" @ Checks @ "checks" @ Failures @ "failures");
    return Failures;
}

defaultproperties
{
    Begin Object Class=CoarseEnemyAIAndEncounters.X2Effect_CoarseBasharShield Name=ShieldFixture
        DamageReduction=6
    End Object
    TestEffect=ShieldFixture
    Begin Object Class=XComGameState_Unit Name=ShieldedUnitFixture
        CharacterStats(eStat_ShieldHP)=(CurrentValue=8,MaxValue=8,BaseMaxValue=8,Type=eStat_ShieldHP,CachedMaxValueIsCurrent=true)
    End Object
    TestShieldedUnit=ShieldedUnitFixture
}
```

</details>
