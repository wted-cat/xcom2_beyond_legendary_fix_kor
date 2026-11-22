# Enemy AI Fixes rev005 전술 검증 보고서

Coarse Edition 전설 난이도에서 **위태로운 갈망(That Perilous Yearning)**을 켜면 바샤르 뮤톤이 장착한 장비 21종을 첫 사격 판단에 사용한다. 최고 명중률이 70%를 **초과**하고 탄약과 표적이 있으면 사격을 시도한다. 조건이 맞지 않으면 다음 행동을 평가한다. 주무기가 필요한 장비 공격은 뮤톤의 소총을 사용하고, 사제·크리살리드·선택받은 자의 카드 효과는 실제 행동과 명중 결과를 기준으로 발동한다.

[설치할 rev005 모드](../rev005/CoarseEnemyAIAndEncounters) · [rev004에서 이어받은 변경](ModReport_CoarseEnemyAIAndEncounters_rev004.md)

전술 실행 14회에서 실제 적 턴 45턴을 기록했다. 장비 21종의 다섯 상황(105건)은 같은 적 턴에 참여한 개체별 기록이다. 아래 전투표와 별도로, 효과 비교 29건은 입력을 맞춰 같은 엔진 함수에서 원본과 수정본의 반환값·상태를 비교했다. [수정 전 장비·첫 사격 기록](evidence/rev005/BasharBaseline.txt)

전술표에서 ‘복제’는 추억: 성례(`TPYDuplicateUnit`), ‘지휘’는 감각: 권위(`TPYChosenCommand`)다. 각 괄호는 그 행동을 받은 표적을 표시한다.

## 실제 전투 조건

Steam판 WotC 전술 빠른 시작에서 전설(내부값 3)과 `ARFMPerilousYearning=True`를 확인했다. LWOTC, Requiem Legion: Coarse Edition(`3555944655`), TPY(`2795578857`), Totally Reasonable Definitely Not Psychotic Tedjam Plugin(`3835619377`)을 포함한 로컬 모드 390개를 참조했다. 전술 전용 사본에 외계인 팀으로 적을 배치하고 XCOM 턴을 종료했다. 게임 엔진은 8917이며 Highlander 본체·Core·Engine·`XComGame`·`DLC_2`는 모두 `1.32.0 (1cba26)`을 보고했다.

검증 도구는 장비·캠페인 강화·탄약·재사용 대기·병사 위치를 준비했다. 실제 적의 능력 선택과 이동은 게임 AI가 맡았다. 로그에서 `WORLD`는 난이도와 옵션, `RULE`은 팀 턴, `ACT`는 제출된 능력·표적·전후 행동력·이동 경로, `BEFORE`는 턴 직전 시야다. XCOM 턴에는 적 행동력이 0일 수 있어 우선순위 판정에는 외계인 턴의 실제 기록을 사용했다.

## 바샤르 장비 21종의 행동

두 장비 표의 첫 열은 원본 `ARFM_Items_Yearning.uc`에 등록된 장비 식별자다. 같은 이름을 로그의 장비 목록에서 찾을 수 있다.

7기씩 세 전투에서 장비를 하나씩 넣은 뮤톤을 게임의 일반 유닛·능력 초기화 절차로 생성했다. 첫 턴은 정상 탄약, 둘째 턴은 주무기 탄약 0으로 시작했다. 셋째 턴에는 XCOM과 로스트를 떨어뜨리고 시야를 제한했다. **21기 모두 생존했고, 셋째 턴 직전 21기 모두 보이는 적 목록이 비었다.** 명중률·거리·수류탄 착탄 지점과 다음 행동의 여건은 개체마다 달랐다.

| 장비 | 정상 탄약·표적 있음 | 시작 탄약 0 | 시작 시 보이는 적 0 |
|---|---|---|---|
| `YearningGigatankBashar` | 사격 | 이동 → 총검 | 재장전 → 이동 |
| `YearningHyperRegenBashar` | 사격 | 재장전 → 이동 | 이동 |
| `YearningMassFireBashar` | 사격 → 이동 → 사격 | 재장전 → 사격 ×2 | 이동 |
| `YearningSoulborneBashar` | 이동 → 사격 → 태세 Soul → 로제석 후속 사격 | 재장전 → 제압 사격 | 이동 |
| `YearningOppressorBashar` | 사격 → 태세 Edge | 이동 → 총검 → 태세 Edge | 재장전 → 이동 |
| `YearningGrailBashar` | 사격 → Adamite 효과 → 태세 `YearningGrailBashar` | 이동 → 총검 → Adamite 효과 → 태세 `YearningGrailBashar` | 재장전 → 이동 |
| `YearningBrookiteBashar` | 사격 | 이동 → 총검 | 재장전 → 이동 |
| `YearningBloodBashar` | 사격 → 태세 `YearningBloodBashar` | 총검 | 재장전 → 이동 |
| `YearningDawnBashar` | 사격 | 총검 | 재장전 → 이동 |
| `YearningKnockBashar` | 사격 → 태세 `YearningKnockBashar` | 재장전 → 제압 사격 → 태세 `YearningKnockBashar` → 제압 | 이동 |
| `YearningAzuriteBashar` | 사격 | 총검 | 재장전 → 이동 |
| `YearningElbaiteBashar` | 사격 | 재장전 → 제압 사격 → 제압 | 이동 |
| `YearningGrenadierBashar` | 사격 | 총검 | 재장전 → 이동 |
| `YearningErythriteBashar` | 사격 | 재장전 → 사격 | 이동 |
| `YearningFlintBashar` | 사격 → 총검 → 수류탄 | 재장전 → 사격 | 이동 |
| `YearningShigaiteBashar` | 사격 ×3 | 이동 → 총검 → 재장전 → 제압 사격 → 제압 | 이동 |
| `YearningTanzaniteBashar` | 사격 → 경계 사격 | 이동 → 총검 | 재장전 → 이동 |
| `YearningSkyBashar` | 사격 → 태세 `YearningSkyBashar` | 이동 → 총검 → 태세 `YearningSkyBashar` | 재장전 → 이동 |
| `YearningSpeedBashar` | 사격 | 총검 | 재장전 → 이동 |
| `YearningMothBashar` | 사격 → 태세 `YearningMothBashar` | 이동 → 총검 | 재장전 → 이동 |
| `YearningAllSeeingBashar` | 사격 | 이동 → 총검 | 재장전 → 이동 |

태세, 로제석 후속 사격과 경계 사격은 해당 공격 뒤에 발생한 효과·반응을 포함한다. 제압의 내부 트리거와 총검의 약화 처리는 표에서 생략했다. 시가이트는 첫 턴 세 사격에서 차례로 `2→2`, `2→2`, `2→0`이었다. 빈 탄창 턴의 이동과 총검도 `2→2`였으며 시야가 빈 턴에는 실제 이동 경로가 남았다.

21종 모두 장비 식별 조건이 참이었다. 주무기를 요구하는 ARFM 능력 15개 장비·능력 조합에서 실제 무기와 뮤톤 소총 `Muton_WPN`의 객체 번호가 일치했다. 표는 장비 소유자가 직접 취한 행동을 보여준다. 회복·피격·처치·반응을 요구하는 개별 패시브의 모든 발동 조건은 별도다. [장비 1~7](evidence/rev005/BasharFinalA.txt) · [장비 8~14](evidence/rev005/BasharFinalB.txt) · [장비 15~21](evidence/rev005/BasharFinalC.txt)

### 장비 능력의 재사용 대기와 사격의 재사용 대기

최종 배포 패키지로 21종을 한 전장에 다시 배치하고 두 적 턴 모두 탄창을 채웠다. 첫 턴에는 장비가 부여한 능력과 그 추가 능력 가운데 재사용 대기 설정을 가진 능력에만 5턴을 부여했다. 둘째 턴에는 그 상태에서 표준 사격도 5턴 대기로 설정했다. 표준 사격의 5턴 대기는 후속 행동을 관찰하기 위해 이 전투에만 설정한 조건이다. 목록이 비어 있는 장비는 장착 능력에 대기 설정이 없어서 첫 턴이 대조군이다.

자체 재사용 대기 능력이 있는 장비는 `YearningBloodBashar`와 `YearningElbaiteBashar` 두 종이다. 두 장비에서 공통으로 확인한 능력은 `ARFMCapstoneKyanite`다. 나머지 19종도 둘째 적 턴에는 표준 사격의 재사용 대기 5턴을 적용했다.

| 장비 | 대기를 준 장비 능력 | 장비 능력만 대기 | 장비 능력과 표준 사격 모두 대기 |
|---|---|---|---|
| `YearningGigatankBashar` | 해당 없음 | 사격 | 이동 → 총검 |
| `YearningHyperRegenBashar` | 해당 없음 | 사격 | 수류탄 → 제압 사격 → 제압 |
| `YearningMassFireBashar` | 해당 없음 | 사격 ×2 → 수류탄 | 이동 |
| `YearningSoulborneBashar` | 해당 없음 | 사격 → 태세 Soul → 로제석 후속 사격 → 태세 Soul | 수류탄 → 제압 사격 → 태세 Soul → 제압 |
| `YearningOppressorBashar` | 해당 없음 | 사격 → 태세 Edge | 이동 → 수류탄 |
| `YearningGrailBashar` | 해당 없음 | 사격 → Adamite 효과 → 태세 `YearningGrailBashar` | 이동 → 수류탄 |
| `YearningBrookiteBashar` | 해당 없음 | 사격 | 이동 → 총검 |
| `YearningBloodBashar` | `ARFMCapstoneKyanite` | 사격 → 태세 `YearningBloodBashar` | 이동 → 총검 → 태세 `YearningBloodBashar` |
| `YearningDawnBashar` | 해당 없음 | 사격 → 태세 `YearningDawnBashar` | 이동 → 총검 → 태세 `YearningDawnBashar` |
| `YearningKnockBashar` | 해당 없음 | 사격 → 태세 `YearningKnockBashar` | 이동 → 제압 사격 → 태세 `YearningKnockBashar` → 제압 |
| `YearningAzuriteBashar` | 해당 없음 | 사격 | 이동 → 총검 |
| `YearningElbaiteBashar` | `ARFMCapstoneKyanite` | 사격 | 이동 → 제압 사격 → 제압 |
| `YearningGrenadierBashar` | 해당 없음 | 사격 | 이동 → 총검 |
| `YearningErythriteBashar` | 해당 없음 | 사격 | 이동 → 총검 |
| `YearningFlintBashar` | 해당 없음 | 사격 → 수류탄 | 이동 → 총검 → 제압 사격 |
| `YearningShigaiteBashar` | 해당 없음 | 사격 ×3 | 이동 |
| `YearningTanzaniteBashar` | 해당 없음 | 사격 → 경계 사격 | 이동 → 제압 사격 → 제압 |
| `YearningSkyBashar` | 해당 없음 | 사격 → 태세 `YearningSkyBashar` | 이동 → 제압 사격 → 태세 `YearningSkyBashar` → 제압 |
| `YearningSpeedBashar` | 해당 없음 | 사격 | 이동 → 총검 |
| `YearningMothBashar` | 해당 없음 | 사격 → 태세 `YearningMothBashar` | 이동 → 제압 사격 |
| `YearningAllSeeingBashar` | 해당 없음 | 사격 | 이동 → 제압 사격 → 제압 |

두 추가 상황에서 확인한 개체별 행동 기록은 42/42건이다. 둘째 턴 시작 직전 탄약이 있는 상태에서 표준 사격이 `AA_CoolingDown`으로 거부된 개체는 21/21기였다. 후속 사격·반응 능력은 표준 사격과 별도 능력으로 집계했다. [장비별 재사용 대기 전투](evidence/rev005/BasharCooldowns.txt)

## 원본 설명·코드와 rev004 대비 수정

원본 `2795578857/Config`의 INI 24개와 `Localization`의 INT 3개를 다시 읽었다. `ARFMDarkEvents.int`의 56개 묶음에서 168개 버튼의 영문 이름·설명을 찾아 실제 발동 함수와 대조했다. 앞선 버전에서 버튼 연결을 고친 경우 현재 연결까지 추적했다. 능력 설명 `XComGame.int`, 원본 `ARFM_DESW_Abilities`, `ARFM_PYP_Abilities`, `ARFM_TPY_ChosenPowers`, `ARFM_Items_Yearning`, 개별 효과와 AI 노드의 조건도 비교했다.

| 대상 | 원본 근거와 rev005의 동작 |
|---|---|
| 바샤르 첫 사격 | 원본 `TPY_MutonShouldShootFirstAction`이 요구한 `ARFMBasharBoost`를 생성하는 원본 코드가 없었고, 수정 전 장비 7종 모두 해당 표식이 없었다. 기존 효과가 있으면 인정하고 실제 장비 21종도 판별한다. 원본의 최고 명중률 조건인 70% 초과과 사격 가능 조건을 유지했다. |
| 바샤르 공격 무기 | 장비가 부여한 능력은 게임의 일반 초기화에서 장비 자체를 출처로 받을 수 있다. `CoarseYearningEquipment`는 주무기를 요구하는 능력의 현재 출처가 바샤르 장비이면 해당 유닛의 주무기로 연결한다. 전술 도중 지급, 처음부터 장착한 유닛, 기존 전술 저장을 불러오는 경로에 적용한다. |
| 사제·아바타·워록 | 효과를 부여한 중립 패시브 대신 실제 사용한 능력을 검사한다. 사제·아바타는 사이오닉 능력과 원본에 명시된 성전사 M1~M3의 소모 비용을 돌려받는다. 워록은 원본의 명중 요건을 적용한다. |
| 첫 사격과 스턴 랜스 | 스마트 탄약은 그 턴의 첫 표준 사격에 한 번 적용한다. 다른 공격은 그 기회를 소모하지 않는다. 경찰의 과잉 진압은 스턴 랜스에 행동력을 실제로 썼을 때 한 턴에 한 번 행동력 하나를 돌려준다. 마지막 행동력 하나로 공격했을 때도 발동한다. |
| 기계 유닛 | 고급 전술 처리기는 `DoNotConsumeAllEffects`에서 일반 행동력의 비용과 허용 종류를 보존한다. 일반 행동력 하나가 드는 턴 종료 사격을 하면 하나만 소모한다. 무료 행동이나 남은 행동력 전부가 유일한 비용인 특수 행동에는 원래 비용을 적용한다. 같은 대상을 연속 공격할 때의 명중 보너스도 유지한다. |
| 크리살리드·페이스리스·버서커·섹토이드·바이퍼 | 크리살리드는 공격이 명중하거나 치명타가 나면 행동력 하나를 얻는다. 생체 개조는 치명타 때 소비한 행동력을 돌려준다. 원본에서 요구하던 측면 조건과 행동력 두 개 고정 지급을 바로잡았다. 미끄러운 추적자들은 실제 치명타 때 공격자에게 `Untouchable` 1회, 표적에게 파열 1을 적용한다. |
| 탄자나이트·시가이트 | 실제 공격 후 경계용 행동력을 받고, 시가이트는 표적이 없는 이동을 포함한 턴의 첫 두 유료 행동을 돌려받는다. |
| 황수정·자수정·조이사이트 | 황수정은 측면, 자수정은 고지대에서 명중·치명타를 확인한다. 조이사이트는 빗나간 적에게 원한을 쌓고, 같은 표적에 명중할 때 원본 상한까지 피해에 반영한 뒤 그 표적의 원한을 지운다. |
| 선택받은 자의 헌신 ‘기억’(Rememberance) | 실제 공격·반응 사격의 이름과 명중 결과를 확인한다. 원본에 있는 패배 횟수 문턱, 무작위 보너스와 치명타 규칙을 유지했다. |

바샤르의 장착 여부는 `HasBasharEquipment`, 주무기 연결과 저장 복구는 `RepairBasharAbilityWeapons`와 `RestoreBasharAbilityWeapons`에서 확인할 수 있다. [바샤르 장비 판정과 무기 연결 소스](../rev005/CoarseEnemyAIAndEncounters/Src/CoarseEnemyAIAndEncounters/Classes/CoarseYearningEquipment.uc)

## 선택받은 자의 첫 행동과 후속 행동

어쌔신·헌터·워록 M3을 함께 둔 첫 전투에서는 세 유닛에 복제와 지휘를 준비했다. 다음 턴에는 두 능력에 재사용 대기 5를 부여하고 광역 공격을 허용했다. 셋째 턴에는 적대 표적을 시야 밖으로 옮기고 복제·지휘는 다시 사용할 수 있게 했다. 아군을 노리는 능력은 적이 보이지 않아도 사용할 수 있다. 지휘로 행동한 유닛은 자신의 차례에 다시 행동할 수 있다.

| M3 | 두 능력 사용 가능 | 복제·지휘 대기 | 적대 표적을 시야에서 제거 |
|---|---|---|---|
| 어쌔신 | 복제(`AdvStunLancerM1`) → 지휘(`ChosenSniperM3`) → 작별의 비단(`PartingSilk`)(`Soldier`) | 병사 납치(`Soldier`) | 복제(`AdvTrooperM1`) → 지휘(`Sectoid`) → 이동 |
| 헌터 | 이동 → 복제(`AdvTrooperM1`) → 지휘(`AdvStunLancerM1`) → 헌터 소총 사격(`TheLostHowlerHP7`) | 이동 | 복제(`AdvStunLancerM1`) → 지휘(`AdvTrooperM1`) → 이동 |
| 워록 | 복제(`AdvTrooperM1`) → 지휘(`Sectoid`) → 아군 보호막(`Sectoid`) → 사격(`Soldier`) | 이동 → 눈부신 영광 | 복제(`AdvTrooperM1`) → 지휘(`AdvTrooperM1`) → 이동 |

어쌔신이 복제와 지휘를 연이어 택한 사례가 두 전투에 남았다. 헌터에게 지휘가 떨어지면 먼저 추가 이동을 할 수 있다. 별도 전투에서는 헌터가 자기 행동의 첫 수로 추적 사격을 사용했다. 워록은 복제·지휘 대기 중 이동한 뒤 `TPYChosenGroundpound`를 실행했다. [세 선택받은 자](evidence/rev005/ChosenFinal.txt) · [추적 사격을 포함한 첫 전투](evidence/rev005/ChosenBefore.txt)

### 어쌔신 단독·저격수 추적

첫 턴은 시험용 아군이 없는 상태, 둘째 턴은 근접·광역기, 셋째 턴은 적대 시야 제한이다. 넷째 턴부터 아군을 추가하고 비은폐 저격소총 병사를 배치했다. 처음 세 턴에 소환한 외계인 시험 유닛은 어쌔신 한 기였다.

| 실제 외계인 턴 | 유닛 | 관찰한 순서 |
|---|---|---|
| 1 | 어쌔신 | 수류탄 → 아스트랄 도약 → 사격(`Soldier`) |
| 2 | 어쌔신 | 작별의 비단(`PartingSilk`)(`Soldier`) |
| 3 | 어쌔신 | 이동 |
| 4 | 어쌔신 | 수류탄 → 아스트랄 도약 → 사격(`Soldier`) |
| 5 | 어쌔신 | 작별의 비단(`PartingSilk`)(`Soldier`) |

`TPYAssassinStalk`의 원본 요건은 변화 헌신, 저격소총을 든 비은폐 표적과 시야다. 행동 트리는 남은 다른 적도 요구한다. 실제 강화 상태와 소총 추가 결과, 재사용 대기는 `CHANGESTATE`, `SNIPER`, `AVAIL`에서 대조할 수 있다. [어쌔신 단독 전투](evidence/rev005/AssassinSolo.txt)

### 특수 능력이 여럿인 경우

첫 턴에는 복제·지휘·근거리 파동과 어쌔신의 수류탄, 둘째 턴에는 눈부신 영광, 셋째 턴에는 순간이동을 허용했다. 셋째 턴의 어쌔신은 체력이 낮다. 넷째 턴에는 상위 특수기들을 재사용 대기 상태로 두고 저격소총 병사를 투입했으며, 다섯째 턴에는 저격수 추적 자체도 재사용 대기에 넣었다.

| 실제 외계인 턴 | 유닛 | 관찰한 순서 |
|---|---|---|
| 1 | 어쌔신 | 복제(`AdvTrooperM1`) → 파쇄 → 사격(`Soldier`) |
| 1 | 헌터 | 추적 사격(`Soldier`) → 복제(`AdvStunLancerM1`) → 지휘(`ChosenAssassinM3`) → 헌터 소총 사격(`Soldier`) → 권총 사격(`Soldier`) |
| 1 | 워록 | 복제(`AdvStunLancerM1`) → 지휘(`ChosenSniperM3`) → 아군 보호막(`Sectoid`) → 사격(`Soldier`) |
| 2 | 어쌔신 | 병사 납치(`Soldier`) |
| 2 | 헌터 | 추적 사격(`Soldier`) → 이동 |
| 2 | 워록 | 이동 → 사격(`Soldier`) |
| 3 | 어쌔신 | 아스트랄 도약 → 사격(`Soldier`) |
| 3 | 헌터 | 아스트랄 도약 → 헌터 소총 사격(`TheLostHP3`) |
| 3 | 워록 | 아스트랄 도약 → 사격(`TheLostHP2`) |
| 4 | 어쌔신 | 사격(`Soldier`) |
| 4 | 헌터 | 추적 사격(`Soldier`) → 권총 사격(`TheLostHP3`) → 헌터 소총 사격(`Soldier`) |
| 4 | 워록 | 아군 보호막(`AdvTrooperM1`) → `TeleportAlly`(`AdvTrooperM1`) → 이동 |
| 5 | 어쌔신 | 이동 |
| 5 | 헌터 | 추적 사격(`Soldier`) → 권총 사격(`Soldier`) → 헌터 소총 사격(`TheLostHP3`) |
| 5 | 워록 | 이동 |

특수 행동 묶음의 원본 순서는 수류탄 → 복제 → 근접 파동 → 지휘 → 눈부신 영광 → 공격·방어 순간이동이다. 헌터의 첫 행동은 이 묶음보다 추적 사격을, 워록은 소환을 먼저 검사한다. 표에는 각 희귀 분기가 항상 발동한다는 보장 대신 실제로 실행된 순서를 실었다. [특수 능력 경쟁 전투](evidence/rev005/ChosenSpecials.txt)

## 사제·악몽·습격자 특공대

| 전투·대상 | 첫 적 턴 | 둘째 적 턴 | 셋째 적 턴 |
|---|---|---|---|
| 여러 아군이 있는 사제 | 이동 → 성전사(`AdvRaptorM2`) | 재장전 → 이동 | 이동 |
| 단독 사제 | 사격(`Soldier`) | 이동 | 이동 |
| 악몽 | 악몽의 강습(`Soldier`) | 전사 | 전사 |
| 경계·제압 병사가 있는 악몽 | 악몽의 강습(`Soldier`) ×3 → 이동 | 이동 | 잠복 → 굴 파기 |
| 습격자 특공대 | 사이오닉 타격(`Soldier`) | 이동 → 재장전 | 이동 → 재장전 |
| 발각 전 도약 대기·탄약 0 습격자 특공대 | 사이오닉 타격(`Soldier`) | 이동 → 재장전 | 이동 → 재장전 |
| 어드밴트 서리 사제 M2 | 이동 → 냉기 방사 | 이동 | 이동 |
| 사도(M1) | 스턴 랜스(`Soldier`) | `AHWRequiemPinions1` | 이동 → `AHWArchonReaction` |

아군과 함께 있는 사제는 이동한 뒤 습격자 특공대를 성전사 대상으로 골랐다. 혼성 전투의 둘째 턴에는 성전사 재사용 대기 5와 주무기 탄약 0이 함께 적용됐고, 사제는 재장전한 뒤 이동했다. 단독 사제 전투에서는 탄약을 따로 비우지 않았다. 처음 위치에서 조회한 후보와 이동 후 시전한 표적이 달랐으므로 시작 위치의 후보 목록을 최종 선택으로 간주하지 않았다. 악몽은 첫 전투에서 병사에게 악몽의 강습을 썼다. [혼성 전투](evidence/rev005/Targeting01.txt) · [단독 사제](evidence/rev005/PriestSolo.txt)

경계·제압 시험 1턴에서 지정 병사 `2143`의 준비 상태는 경계용 행동력 하나였고 제압을 가하는 상태는 아니었다. 별도 아군 유닛 `3843`의 피제압 상태는 False였다. 강습 표적 2143 (지정 병사 당시 경계 행동력 0·제압 False·가시 True) / 강습 표적 2150 / 강습 표적 2157 [표적 후보와 결정 직전 상태](evidence/rev005/NightmareThreats.txt)

경계·제압 시험 2턴에서 지정 병사 `2150`의 준비 시점에는 경계용 행동력이 없었고 제압을 가하는 상태였다. 별도 아군 유닛 `3843`의 피제압 상태는 True였다. 이 턴에 해당 악몽의 강습 시전 기록이 없었다. [표적 후보와 결정 직전 상태](evidence/rev005/NightmareThreats.txt)

일반 발각에서 습격자 특공대는 첫 정규 적 턴 전에 습격자 점프를 실행했다. 별도 발각 시험의 기록은 탄약 0, 점프 재사용 대기 5, 앞선 발각 처리 False였다. 첫 정규 적 턴 전 실제 행동은 이동이었다. 현재 활성 설정은 발각 첫 후보에서 방어 도약 50과 후퇴 50을 사용하며, 실패하면 이어지는 조건을 본다. [발각 직전부터의 전투 기록](evidence/rev005/RaptorBlocked.txt)

## 실제 결정 순간을 따로 확인한 사례

전술 완료 표식까지 기록된 독립 실행은 14회이며 실제 외계인 턴 45턴을 포함한다. 여기에는 수정 전 바샤르 대조 전투가 포함된다. 최초의 선택받은 자 탐색 실행은 이 합계에서 제외했다. 기본 세 상황의 장비별 63건과 추가 두 상황의 장비별 기록은 개체 단위이므로 전술 턴 수와 다른 수치다.

`YearningSoulborneBashar` 뮤톤의 실제 AI 기록에서 `CoarseHasBasharEquipment`, `CoarseIsBashar`, `TPY_HighAimShot`, `TPY_MutonShouldShootFirstAction` 네 노드가 모두 성공했다. 뮤톤이 일반 사격도 할 수 있다는 사실만으로 전용 첫 행동 분기가 실행됐다고 판정하지 않았다. [행동 노드와 사격 기록](evidence/rev005/PaymentsTurns.txt)

M2의 발각 직전 기록 번호는 436, 이어진 이동 기록은 439였다. 실제 병합된 `TryShootOrJumpOrMoveOption`에도 방어 도약과 후퇴 두 후보가 50·50으로 등록되어 있었다.

습격자 특공대 M1 발각 직전 탄약 3, 도약 대기 0, 이전 발각 처리 False. 첫 외계인 턴 전 기록은 습격자 점프이었고 첫 정규 적 턴에는 사이오닉 타격을 기록했다. [등급별 발각 전투](evidence/rev005/BasharCooldowns.txt)

습격자 특공대 M3 발각 직전 탄약 0, 도약 대기 5, 이전 발각 처리 False. 첫 외계인 턴 전 기록은 이동이었고 첫 정규 적 턴에는 이동 → 재장전을 기록했다. [등급별 발각 전투](evidence/rev005/BasharCooldowns.txt)

보충 전투에 배치한 저격소총 병사의 번호는 2143였다. 이 보충 전투에서 저격수 추적의 실제 시전은 관찰되지 않았다. [능력 우선순위 보충 전투](evidence/rev005/ChosenSpecials.txt)

독립 전투 셋째 턴에는 살아 있는 병사에게 저격소총을 주고 변화 헌신을 획득한 새 어쌔신을 소환했다. 상위 특수기는 재사용 대기 상태였다. 저격수 추적 후보는 2143, 2150이었다. 실제 행동은 그림자처럼(저격수 추적)(`Soldier`) → 사격(`Soldier`)이었다. 병사 2143의 위치는 (25,55,1)였다. 어쌔신은 (23,53,1)에서 (26,55,1)로 이동했다. 이어서 같은 병사에게 표준 사격을 했다. [어쌔신 표적과 착지 기록](evidence/rev005/NightmareGuarded.txt)

별도 두 턴에서는 강화 카드가 없는 악몽, 높은 체력의 병사, 독립된 제압 수혜 유닛을 배치했다. 첫 턴에는 경계용 행동력을 유지하도록 일반 반응 사격을 대기에 두고 외계인 턴 시작에 상태를 확인했다. 둘째 턴에는 다른 병사에게 원본 제압 효과를 적용했다. 후보의 번호·시야·경계용 행동력·제압 상태를 공격과 대조했다. 첫 전투에서는 지정 경계 병사가 공격 확정 직전에 경계 행동력 0이었다.

| 대조 턴 | 지정 병사 · 외계인 턴 시작 상태 | 악몽 행동 | 강습 직전 지정 병사의 상태 |
|---|---|---|---|
| 1 | 2143 · 경계 1, 제압 False | 악몽의 강습(`Soldier`) | 실제 표적 2143, 경계 1, 제압 False, 가시 True |
| 2 | 2150 · 경계 0, 제압 True | 악몽의 강습(`Soldier`) → `AHWNightmareReaction` | 실제 표적 2150, 경계 0, 제압 True, 가시 True |

첫 턴에는 보이는 병사 3명 중 경계 중인 병사를 골랐다. 둘째 턴에는 보이는 병사 3명 중 아군을 제압 중인 병사를 골랐다.

각 표적 선택은 이 전투의 거리·체력·시야와 당시 가능한 행동에서 관찰한 결과다. [경계·제압 유지 대조 전투](evidence/rev005/NightmareGuarded.txt)

세라프 보충 시험에서는 병사에게 실제 출혈 효과를 적용했지만 이 전투에 `AHWShinanimMercy1` 시전 기록은 없었다. 어드밴트 서리 사제와 세라프 시험 결과까지 일반 어드밴트 사제의 성전사 결과로 합산하지 않았다.

## 효과의 실행 검사

아래 게임 내부 회귀 검사에서는 같은 게임의 원본 능력 생성 함수로 만든 효과와, rev005가 실제 능력 템플릿에 등록한 효과에 동일한 공격·표적·행동력 상태를 전달했다. 원본과 수정본의 결과는 별도 상태에서 읽고 폐기했다. 이 방식은 전투에서 우연히 나오기 어려운 치명타·고저차·패배 횟수의 경계값을 시험한다. 실제 AI가 고른 능력은 앞의 턴별 표와 아래 카드 전투 행에만 집계했다.

같은 입력 29개에서 원본은 12개가 기대와 달랐고, rev005는 29개 모두 일치했다. 고지대·평지에서의 명중과 빗나감, 측면 명중, 마지막 행동력 하나로 사용하는 스턴 랜스를 포함했다.

| 카드·효과 | 실행한 비교 수 | 원본이 기대와 달랐던 비교 | rev005 결과 |
|---|---:|---:|---|
| 새로운 품종 (`ARFMDESW_ChryssalidSteroids`) | 3 | 2 | 3/3 일치 |
| 생체 개조 (`ARFMDESW_FacelessJelly`) | 2 | 1 | 2/2 일치 |
| 미끄러운 추적자들 (`ARFMDESW_SlipperyStalkers`) | 2 | 1 | 2/2 일치 |
| 신념의 힘 (`ARFMDESW_PriestProtein`) | 2 | 0 | 2/2 일치 |
| 스마트 탄약 (`ARFMDESW_Woodpecker`) | 3 | 1 | 3/3 일치 |
| 경찰의 과잉 진압 (`ARFMPYP_PoliceBrutality`) | 3 | 2 | 3/3 일치 |
| `ARFMDESW_WarlockPsyBooster` | 2 | 1 | 2/2 일치 |
| 탄자나이트 캡스톤 (`ARFMCapstoneTanzanite`) | 2 | 1 | 2/2 일치 |
| 시가이트 캡스톤 (`ARFMCapstoneShigaite`) | 2 | 0 | 2/2 일치 |
| 황수정 로드스톤 (`ARFMLodestoneCitrine`) | 2 | 1 | 2/2 일치 |
| 자수정 로드스톤 (`ARFMLodestoneAmethyst`) | 3 | 1 | 3/3 일치 |
| 조이사이트 캡스톤 (`ARFMCapstoneZoisite`) | 2 | 1 | 2/2 일치 |
| 헌신: 기억 (`ARFMDedicationRememberance`) | 1 | 0 | 1/1 일치 |

기존 저장 상태의 무기 연결을 재현해 로제석 능력의 출처를 보조 장비로 되돌린 다음 실제 저장 불러오기 훅을 두 번 호출했다. 최초 출처 4173은 장비 4173과, 복구 후 4170은 소총 4170과 일치했다. 두 번째 호출 전후의 게임 상태 기록 번호는 637와 637였다. 사용자의 기존 저장 파일을 여는 시험은 별도로 수행하지 않았다.

기계 카드의 표준 사격을 실제 비용 처리 함수에 전달했다. 아래 숫자는 시작 시 행동력 하나·두 개·세 개였을 때 각각 남은 행동력이다.

• `AdvMEC_M1` — 기계 카드 표식 True, 결과 0, 1, 2, 기대 0, 1, 2.

• `Soldier` — 기계 카드 표식 False, 결과 0, 0, 0, 기대 0, 0, 0.

원한 3점을 표적에게만 넣은 비교에서 명중 시 추가 피해는 원본 0, rev005 3였다. 빗나감 비교에서는 추가 피해 0도 검사했다.

선택받은 자의 원본 패배 횟수를 잠시 6·7·9·10·13으로 설정하고 각 경우에 치명타가 난 반응 사격의 비용 처리를 실행한 뒤 원래 값으로 복구했다. 횟수는 실제 캠페인 플레이로 누적한 것이 아니다.

| 패배 횟수 | 비교 횟수 | 경계 행동력 복구 횟수 | 추가 행동력 최솟값~최댓값 |
|---:|---:|---:|---|
| 6 | 1 | 0 | 0~0 |
| 7 | 1 | 1 | 0~0 |
| 9 | 1 | 1 | 0~0 |
| 10 | 16 | 16 | 0~1 |
| 13 | 16 | 16 | 0~2 |

### 강화 카드를 켠 실제 적 턴

| 시험 유닛 | 첫 턴 | 둘째 턴 | 셋째 턴 |
|---|---|---|---|
| 사제 | 사격(`Soldier`) | 이동 | 이동 |
| MEC | 사격(`TheLostHP2`) → 마이크로 미사일 | 사격(`Soldier`) ×2 | 재장전 → 이동 |
| 스턴 랜서 | 스턴 랜스(`Soldier`) ×2 | 스턴 랜스(`Soldier`) ×2 | 이동 |
| `YearningSoulborneBashar` 뮤톤 | 사격(`Soldier`) → 태세 Soul(`Soldier`) → 로제석 후속 사격(`Soldier`) → 태세 Soul(`Soldier`) → 사격(`Soldier`) → 태세 Soul(`Soldier`) → 로제석 후속 사격(`Soldier`) → 태세 Soul(`Soldier`) | 사격(`Soldier`) → 태세 Soul(`Soldier`) → 로제석 후속 사격(`Soldier`) → 태세 Soul(`Soldier`) → 재장전 → 사격(`Soldier`) → 태세 Soul(`Soldier`) → 로제석 후속 사격(`Soldier`) → 태세 Soul(`Soldier`) | 이동 |

게임 상태에서 실제 적용을 확인한 관련 카드 표식은 `AdvMEC_M1 / ARFMDESW_RoboMadness`, `AdvPriestM1 / ARFMDESW_PriestProtein`, `AdvStunLancerM1 / ARFMPYP_PoliceBrutality`, `Muton / ARFMDESW_Woodpecker`. [카드 전투·비용·피해 비교](evidence/rev005/PaymentsTurns.txt)

## 재현과 확인 범위

1. 같은 식별자를 쓰는 기존 수정본과 교체하여 rev005 하나를 활성화한다. LWOTC, Coarse Edition, 2795578857, Tedjam과 해당 의존 모드를 사용한다. 전설에서 위태로운 갈망을 선택한다.
2. 검증용 전술 사본에서는 시험 유닛과 표적을 배치하고 XCOM 턴을 넘겼다. 바샤르는 한 뮤톤에 한 장비를 넣고 탄약·시야를 바꿨다. 선택받은 자는 M3을 사용했다. 사제는 아군 유무와 성전사 대기, 습격자 특공대는 발각 전 점프/탄약, 악몽은 실제 병사의 경계용 행동력·제압 효과를 바꿔 준비했다.
3. 재현 시 게임 상태에서 외계인 턴 번호, 시전자·표적 번호, 행동력 전후, 이동 경로를 함께 확인한다. 장비의 자동 후속 효과와 아군이 지휘로 얻은 행동은 별도 사건으로 읽는다.

빠른 시작에서 역할·거리·표적·행동력을 통제한 전술 시험이다. 캠페인 전체를 다시 플레이해 얻는 모든 지도·지형·병종·패배 횟수·난수 조합, 모든 동률 표적의 선택 빈도, 각 바샤르 패시브의 모든 피격·처치·사망 연출은 미실행이다. 전체 선택지에서 읽은 설명과 코드의 연결은 실제 적 턴에서 관찰한 행동과 별도로 해석해야 한다. [기존 장기 캠페인 및 선택지 검증](ModReport_CoarseEnemyAIAndEncounters_rev004.md)

후속 버전에서는 보복 임무의 제단, 니벤의 치료처럼 rev005까지 실제 후속 결과가 남지 않은 행동을 별도로 시험했다. [rev006 전술 검증](ModReport_CoarseEnemyAIAndEncounters_rev006.md)

## 배포 파일 확인

rev004의 완전한 설치본을 이어받았다. `Config/XComAI.ini`, `CoarseYearningEquipment`, `CoarseYearningCardEffects`, `X2DLCInfo_CoarseEncounters`, 전용 AI 조건 및 효과 클래스와 빌드한 `Script/CoarseEnemyAIAndEncounters.u`가 변경 범위다. 설정·전체 소스·배포 스크립트 총 51개 파일을 대조했다. 시험 시나리오와 진단 도구는 별도 검증 폴더에 있다.

패키지 표를 직접 열어 이름 1,304개, 내보내기 944개, 가져오기 758개와 배포 소스 37개 클래스 전체를 대조했다. 가져온 패키지는 `ARFMDarkEvents`, `Core`, `Engine`, `XComGame`이다. 최종 WotC SDK 스크립트 컴파일은 오류 0, 경고 0이다. 최종 `.u`의 SHA-256은 `8469d3b6224f2fad2d0fc5c583f4bc8fc706f46045ad9b862dc532085126be2d`이다. 런타임 등록은 `Config/XComEngine.ini`의 `NonNativePackages`, SDK 등록은 `Config/XComEditor.ini`의 `ModPackages`에서 확인했다. 선택받은 자 단독·사제 단독·발각·표적·카드·희귀 능력 전투와 21종 재사용 대기 보충 전투는 최종 패키지로 실행했다. 첫 장비 두 조는 중간 빌드 Release03, 셋째 조 및 첫 선택받은 자 합동 전투는 Release04에서 실행했다. Release04에서 기계 카드·스턴 랜스 비용을 조정했고 Release05에서 세 종의 명중·치명타 카드 효과를 보완했다. 장비 판정·주무기 연결 및 장비 21종 전투에서 작동한 바샤르 효과 코드는 같았다. 앞선 일반 혼성 전투는 Release02였다. 프로그램이 기록한 모드 등록 경로와 실제 클래스 동작을 확인했고, 운영체제가 연 `.u`의 절대 경로 자체는 별도로 추적하지 않았다. [최종 SDK 빌드](evidence/rev005/Release05.txt)
