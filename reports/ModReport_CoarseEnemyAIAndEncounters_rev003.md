# LWOTC Coarse 적 AI·Tedjam 통합 모드 rev003

전설 난이도에서 **위태로운 갈망(That Perilous Yearning)**을 켜면 선택한 카드가 저장되고, 선택받은 자가 복제·지휘를 사용할 아군을 고르며, 뮤톤은 선택된 바샤르 장비군에서 장비를 받는다. rev003에서는 카드 56장의 버튼 168개가 부여한 태그·해금을 게임 상태에서 검사했다. 선택 화면 168개 버튼을 직접 누르고 저장을 다시 불러온 결과는 rev004에 있다. [선택 화면·저장 기록](ModReport_CoarseEnemyAIAndEncounters_rev004.md)

검사일은 2026년 11월 21일이다. Windows Steam판 선택된 자의 전쟁과 LWOTC를 사용했다.

## 사용 방법

1. 런처의 로컬 모드 검색 경로에 [rev003 폴더](../rev003/)를 Workshop 경로 다음으로 추가한다. 기존 rev002 경로를 빼고 새로 고친 뒤 **LWOTC Coarse - Enemy AI and Encounters**의 위치가 [이번 배포 폴더](../rev003/CoarseEnemyAIAndEncounters/)인지 확인하고 게임을 다시 시작한다. 두 버전의 내부 ID는 모두 `CoarseEnemyAIAndEncounters`다.
2. **Requiem Legion: Coarse Edition**(3555944655), **2795578857**(`ARFMDarkEvents`), **Totally Reasonable Definitely Not Psychotic Tedjam Plugin**(3835619377), LWOTC, Ted Mod Jam, ARFM Advent Pack, WotC Community Highlander를 활성화한다. 구형 독립 AI·요새 패치의 중복 여부는 `Config/XComGame.ini`의 `IncompatibleMods` 목록에서 확인할 수 있다.
3. 캠페인 난이도를 **전설**, 세컨드 웨이브 옵션을 **위태로운 갈망**으로 설정한다. 이번 검증은 분리한 프로필과 저장 슬롯으로 진행했다. 기존 캠페인의 누락 카드는 전략 저장을 다시 불러올 때 복구된다. 이미 선택한 카드는 남아 있는 태그·선택 횟수를 유지한다. 예전 버전이 같은 이름으로 기록한 두 카드와 과거에 잘못 적용한 보너스는 당시 선택을 식별할 근거가 없어 소급 재배정하지 않는다.

선택받은 자의 ‘복제’는 추억: 성례(`TPYDuplicateUnit`), ‘지휘’는 감각: 권위(`TPYChosenCommand`)다. 이 문서에서 두 짧은 표현은 아군을 복제하는 행동과 아군에게 명령하는 행동을 가리킨다.

## 수정한 동작

| 대상 | 발동 조건과 결과 | 위치 |
|---|---|---|
| 카드 18·19·21 및 세 버튼 | 19번 원본 팩터리가 18번과 같은 이름을 등록했다. 18번과 19번을 각각 생성하고 세 버튼을 각 카드의 원래 결과에 연결했다. 21번 두 번째 새벽의 화로는 정화병 화염방사기 선택을 적용한다. 버튼을 누르면 선택 횟수와 선택 번호를 같은 상태에 기록하고 중복 입력을 차단한다. 후보가 없는 달에는 창을 열지 않는다. | `CoarseYearningCards.uc` · `CoarseYearningStrategy.Install` / `OpenChoice` / `ApplyChoice` · `UICoarseYearningChoice.Choose` |
| 선택받은 자의 행동 순서 | 복제와 지휘에서 유효한 아군에게 양수의 점수를 준다. 재사용 대기·표적 없음이면 다음 후보를 평가한다. 세 직책의 첫·마지막 행동에 특수 능력 경로를 연결했다. 기존 우선 수류탄, 헌터의 첫 추적 사격, 워록의 소환 순위를 보존한다. | `Config/XComAI.ini` · `SelectTargetForTPYDuplicateUnit` / `SelectTargetForTPYChosenCommand` / `TPYChosenSpecials` |
| 선택받은 자의 능력 | 변화 헌신이 실제 등록된 순간이동을 부여한다. 지휘에는 원본 게임의 자동 명중 판정을 지정했다. 복제 연출은 지휘자와 복제할 아군을 구분한다. ‘그림자처럼’은 변화 헌신이 있는 어쌔신이 시야 내 비은폐 적 저격수 옆 빈 칸으로 이동한다. 유효한 착지 칸이 없으면 표적 후보에서 제외한다. | `CoarseYearningPowers.Install` / `VisualizeDuplicate` / `PrepareShadowStalk` · `X2Condition_CoarseShadowStalkTile.uc` |
| 무기와 장비 | 선택받은 자 무기 강화와 바샤르 강화를 각각 켜고 끌 수 있다. 무기 교체 시 이전 무기·탄약이 주던 능력을 정리하고 새 장비의 능력을 등록한다. 원래 빈 슬롯은 다른 패시브의 지급원으로 처리하지 않는다. 선택된 스턴 랜서·트루퍼 수류탄도 지급한다. 여러 번 호출돼도 같은 유닛에 추첨을 반복하지 않는다. | `CoarseYearningEquipment.OnUnitBeginPlay` / `GetChosenWeapons` / `ApplyGear` |
| 바샤르 강화 | 생존한 선택받은 자가 0명이어도 선택지에 해당하는 뮤톤은 해당 강화군을 먼저 추첨한다. 그 밖의 뮤톤은 일반군 대상이 될 수 있다. All-Seeing 장비와 연결 능력을 복구했다. | `CoarseYearningEquipment.DrawBashar` · `CoarseYearningPowers.RegisterMissingAbilities` |
| 전략 승천·교리 | 세 직책의 3단계 강화와 공통 승천은 선택받은 자의 보유·공개 특성을 한 번씩 등록한다. 헌신과 측면 특성의 원래 추첨 가중치를 유지한다. 월말에 소모·섬멸·제압·압제 교리를 진행 중인 월말 상태에 반영한다. 압제가 뽑을 반복 암흑 이벤트가 없으면 추첨을 건너뛴다. 납치·심문 승리 횟수도 제출 가능한 새 상태에 기록한다. | `CoarseChosenAscent.ApplyAscent` · `CoarseYearningStrategy.ApplyDoctrines` / `RecordChosenVictory` |
| 독·사이오닉·누락 능력 | 바이퍼의 독 피해 보정(`ARFMPYP_MurderDrool`)은 선택된 바이퍼 계열의 적격 독 피해에만 보너스를 준다. 황금 갑옷은 활성 암흑 이벤트 목록을 읽어 XCOM 병사의 사이오닉 수치를 설정 배율(기본 0.5)로 한 번 줄이며, 원본 7개 능력 금지를 함께 적용한다. 의료용품 과잉, 전술 분석, Calendarium 저격 관련 누락 등록과 노쇠의 하위 참조, 완벽한 서리 (겨울)·기계의 마음 (영혼)의 사용 입력을 복구했다. | `CoarseYearningPowers.uc` · `X2Condition_CoarseArmoredInGold.uc` · `X2Effect_CoarseViperPoison.uc` |
| 원본 설정 읽기 | `NetworkRepairsAllowedPanicked`를 켜면 공황 중 네트워크 수복 반응 사격이 허용되고, 끄면 공황이 차단한다. 일반·광역 제압은 양쪽에서 사격을 막는다. 원본은 허용 설정에서 공황을 제외 조건에 더했다. Precision Link는 LWOTC에서 생존 그룹원 2명 이상이면 1명당 치명타 +5를 사용한다. 일반 분기 값은 10이다. `MeleeBreakthroughCap`=0은 추가 피해 상한을 해제한다. | `Config/XComGameData_BeyondLegendary.ini` · `Config/XComTPYConfig.ini` |

스크립트 파일은 배포 폴더의 `Src/CoarseEnemyAIAndEncounters/Classes/` 아래에 있다. 변경은 독립 모드에서 적용한다. Workshop 2795578857의 원본 패키지 SHA-256은 `68d19020323e73d0082e8190ad0df36ba888c01e05104b9954cd43b8cdb12da1`다.

## 선택받은 자 무기와 바샤르 확률

무기 교체는 선택받은 자가 2명 이하이거나 외계인 전력 수준(FL)이 16 이상일 때 열린다. 그 안에서 아바타 처치 목표를 완료했거나 생존 1명 이하·FL 20 이상이면 M3, 생존 1명 이하·FL 20 미만 또는 블랙사이트 조사 완료·FL 16 이상이면 M2다. 나머지는 기본 강화형을 쓴다. 난수 0~199에서 0~100과 101~199가 서로 다른 무기 조합이다. 어쌔신은 산탄총과 검, 헌터는 저격총과 권총, 워록은 소총 또는 기관단총을 교체한다.

| 뮤톤의 조건 | 성공 수 / 200 | 게임 내 확률 |
|---|---|---|
| 특화 선택 없음 · 생존 2명·FL 16 이상 | 16 | 8% |
| 특화 선택 없음 · 생존 1명·FL 12 이상 | 41 | 20.5% |
| 생존 0명 일반 승급, 또는 해당 특화군의 승급 조건 충족 | 91 | 45.5% |
| 특화군 선택 · 생존 3명·FL 19 이하 | 0 | 0% |

특화군은 원본의 정예·변종·일반 뮤톤 이름 판정을 사용한다. 생존 3명일 때 FL 20부터, 2명 이하이면 FL에 관계없이 해당 특화군이 열린다. 일반·정예·변종·일반형 특화 추첨표를 합쳐 서로 다른 장비가 21종이다. 같은 장비가 두 번 들어가는 원본의 가중치는 보존했다.

## 확인 범위와 환경

원본 UnrealScript 254개와 Config 하위 INI 24개를 기준으로 진입점·식별자·참조를 조사했다. `XComTPYConfig.ini`에는 83개 섹션이 있다. 시험 프로필의 Workshop 모드 390개 중 Config가 있는 386개 폴더와 그 하위 파일을 대조하고, 게임이 병합한 행동 트리를 읽었다. 시험 프로필에는 Coarse Edition을 사용했다. 원본 게임·Workshop·개인 캠페인 저장은 참조용이다.

엔진 빌드 8917에서 Core, Engine, `XComGame`, `X2WOTCCommunityHighlander`, `DLC_2` 다섯 구성 요소가 모두 1.32.0(1cba26)으로 로드됐다. `ARFMDarkEvents`와 배포 패키지의 `NonNativePackages` 등록, SDK 의존 패키지와 검사에 사용한 원본 바이너리의 해시를 비교했다. 패키지 사본은 시험 프로필에서 각 1개였다. DLC 경로와 실행된 클래스·행동을 확인했다. 실행 로그에 개별 .u 파일의 절대 로드 경로는 표시되지 않았다. [Field06](#field06)

## 재현과 결과

전술 빠른 시작에서는 전설·TPY를 설정하고 세 선택받은 자, 아군 병력과 XCOM 표적을 배치했다. 특정 행동을 고립시킨 시험은 다른 능력의 재사용 대기, 표적 조건, 행동력을 명시적으로 맞췄다. 전략 화면과 저장·재불러오기는 새 전설 캠페인에서 별도로 시험했다.

| 검증 방식 | 재현 조건과 절차 | 예상 결과 | 관찰 결과 | 상태 |
|---|---|---|---|---|
| 실게임 전략 화면 | 전설 새 캠페인, TPY 켬. 19번 카드가 제시된 창의 세 버튼을 확인하고 3번 선택 후 저장·재불러오기. | 56개 등록, 선택 1회, 버튼 3만 참, 같은 카드 재제시 차단. | 56개. 비글 붕괴 / 전장 태생 / 성스러운 전사 표시. 횟수 1·3번 선택·중복 차단·저장 복원 확인. | 통과 |
| 실게임 구버전 저장 모사 | 전략 상태에서 19번 카드만 제거해 55개로 저장하고 실제 재불러오기. | 원본의 누락 카드 복구 훅으로 56개. 복구된 카드는 미선택. | 56개, 19번 횟수 0, 3번 선택 거짓. | 통과 |
| 실게임 전략 데이터·월 제한 | 56개 카드 각각 최소 개방 월, 해당하면 직전 월·최대 월·바로 다음 월에서 `CanActivate` 호출. | 원본 카드별 개방·차단 경계와 일치. | 56/56 일치. | 통과 |
| 실게임 선택 결과 | 각 카드의 세 버튼을 독립 상태에서 평가하고 횟수·버튼·HQ 태그 또는 병사 해금을 확인. 21번 2번은 상태 제출 후 재조회. | 168개 각각 기대값. 21번은 새벽의 화로만 추가. | 168/168 일치. 165개 태그와 3개 병사 해금. 정화병 태그 존재, MEC 미사일 실명 태그 부재. | 통과 |
| 실게임 템플릿 조회 | 원본이 생성하는 전략·특수 상황 효과·리스너·캐릭터·배신 임무와 서술 항목을 각 게임 관리자에서 조회. | 추출한 337개 등록. | 전략 241, 리스너 47, 특수 상황 효과 40, 캐릭터 7, 임무 1, 서술 1. 누락 0개. | 통과 |
| 실게임 능력·장비 참조 | 원본 코드에서 추출한 무기·장비 능력과 하위 능력을 실제 게임 관리자에서 조회. | 추적한 장비와 능력이 존재하고 지급 대상으로 지정한 이름이 풀림. | 장비 64개, 능력 273개. 조회 실패 및 끊긴 하위 능력 0개. | 통과 |
| 실게임 장비 경계 | 직책 × 생존 수 × 전력 수준 × 블랙사이트·아바타 목표 × 두 무기 추첨 경계. 실제 세 직책·스턴 랜서도 생성. | 42개 기대 조합, 각 직책에 지정 무기, 스턴 랜서에게 가스 수류탄. | 42/42. 실제 캐릭터 인벤토리에서 세 무기 조합과 `GasGrenade` 확인. 양 강화 옵션을 끈 뒤 생성한 뮤톤·헌터는 원래 장비 유지. | 통과 |
| 실게임 바샤르 추첨 | 정예·변종·일반형 및 일반 승급, 생존 수·FL과 경계 난수를 조합. 조건 18개 각각 모든 0~199 입력을 한 번씩 사용. | 조건별 0, 16, 41 또는 91회 성공. 정해진 장비군 준수. | 입력 3,600개 모두 기대 횟수 일치. 별도 장비군 경계 24/24. 실제 뮤톤에게 바샤르 장비 지급 확인. | 통과 |
| 실게임 바샤르 개별 장비 | 21개 원본 장비를 각각 독립 상태의 전술 뮤톤 인벤토리에 넣고 무기별로 초기화되는 능력과 이미 보유한 능력을 원본 장비 정의에 대조. | 각 장비가 약속한 능력이 유닛에 있는지 확인. | 21종 중 21종에서 원본이 약속한 지급 능력을 모두 찾았다. | 통과 |
| 실게임 복제·지휘와 후속 행동 | 어쌔신에게 두 능력을 부여. 모두 대기 4턴, 둘 다 후보 0명, 둘 다 준비, 복제만 대기 네 상태에서 같은 행동 분기를 실행. | 두 실패 시 다음 일반 행동, 사용 가능할 때 아군 복제·지휘. | 대기 → `StandardShot`, 후보 0명 → `StandardShot`, 둘 다 준비 → `TPYDuplicateUnit`, 복제만 대기 → TPYChosenCommand. 원래 지휘받은 스턴 랜서가 실제 `StunLance`를 사용한 전투도 확인. | 통과 |
| 실게임 헌신·저격수 추적 | 어쌔신에게 변화 헌신을 주고 시야 안 병사의 주 무기를 일반 소총에서 저격총으로 교체. | 헌신 없는 어쌔신 및 일반 소총병 제외. 사용 시 어쌔신만 인접 칸으로 이동. | 어쌔신 능력 생성 조건 거짓→참, 헌터 캐릭터 직접 지급 없음. 어쌔신 13,18→3,22, 저격수 2,22→2,22, 재사용 대기 3턴. | 통과 |
| 실게임 착지 칸 없음 | 저격수 주변에서 실제로 접근 가능한 칸을 병력으로 채운 뒤 같은 표적 조건 재평가. | 빈 칸이 없으면 AA_TileIsBlocked. | 착지 가능에서 검사. 저격수 주위에 8기 배치, 이후 후보 없음, 표적 판정 AA_TileIsBlocked. | 통과 |
| 실게임 파동·순간이동·강타 | 전설 전투에서 캐릭터의 사용 가능 목록으로 능력을 발동하고 처리 후 위치·재사용 대기·추가 표적 수를 조회. | 유효한 발동과 원본 대기 턴, 순간이동은 시전자 이동. | 파동 2턴(추가 표적 0), 순간이동 3턴(17,13→15,11), 강타 5턴(추가 표적 10명). | 통과 |
| 실게임 반응 사격 조건 | 전설에서 네트워크 수복 Shot의 실제 발사자 조건에 공황·제압·광역 제압을 각각 전달하고 공황 허용을 두 번 껐다가 복원. | 허용 시 공황 통과, 비허용 시 공황 차단 1회, 제압과 광역 제압 모두 차단. | 기본 `AA_Success`, 공황 허용 `AA_Success`, 비허용 `AA_UnitIsPanicked`, 제압 `AA_UnitIsSuppressed`, 광역 제압 `AA_UnitIsSuppressed`, 비허용 중복 등록 후 차단 항목 1개, 복원 AA_Success. | 통과 |
| 실게임 황금 갑옷 | 사이오닉 40인 XCOM 병사로 비활성·활성·종료 및 적 유닛을 평가. 실제 패시브를 반복 호출하고 기본 금지 목록도 검사. | 활성 XCOM 병사에게 0.5배 한 번, 금지 능력 7개. | 40→20. 재호출 후 20, 동일 효과 1개, 금지 7/7. 종료 후 새 적용과 적 유닛은 거부. | 통과 |
| 실게임 독 피해 함수 | 실제 XCOM 생체 병사에 독·비독·분모 0 입력을 분리해서 피해 보정 반환값 검사. | 적격 독은 최대 체력에 따른 보너스, 나머지 0. | 기대값 및 실제값 2 / 2, 비독 0, 잘못된 분모 0. | 통과 |
| 실게임 전략 승천 반복 | 세 직책의 1·2·3단계 강화를 각 50회, 공통 승천을 직책별 180회씩 호출. 독립된 대기 상태의 특성과 이전 상태를 비교. | 특성 중복 없음, 공개 목록 일치, 원본 상태 보존. | 9개 직책·단계 전부 일치. 공통 승천은 세 직책 모두 헌신 5종·측면 9종이 각 1개, 끊긴 능력 0. | 통과 |
| 실게임 교리 상태 | 교리 4개의 월말 처리 함수에 제출 전 상태를 주고 제출 전후 지역 ID와 수치를 비교. | 기본 의지·능력 포인트 계수 0.5·0.8, UFO 1, 지역 3개 값 각각 +1, 반복 가능 이벤트 1. | 계수 0.5·0.8, UFO 1, 16개 지역의 전력·경계·경계심 모두 +1, 반복 이벤트 1. | 통과 |
| SDK 회귀 및 패키지 | 최종 SDK 빌드, 이전 통합 모드의 독립 회귀 검사와 패키지 바이트·클래스명 비교. | 컴파일 성공, 기존 71개 및 패키지 일치. | 컴파일 오류·경고 0개. 71건 중 실패 0건, 배포·시험 설치·SDK 산출물 해시 일치. | 통과 |
| 정적 납치·심문 | LWOTC 납치 이벤트와 심문 능력의 Highlander 발행 지점에서 선택받은 자 승리 기록까지 추적. | 한 번 발생한 이벤트당 선택받은 자 승리 횟수 +1. | 발행 주체·이벤트 구독·대기 상태 1회 제출을 코드에서 확인. 캠페인에서 두 행동을 끝까지 발생시키는 시험은 미실행. | 정적 확인 |
| 장기 캠페인·효과 연출 | 일반 진행 속도로 모든 선택과 나머지 세컨드 웨이브 조합을 각각 진행. | 각 적·지형·임무·강화 조합의 장기 결과와 연출. | 조합 전체를 플레이한 기록은 없다. 재현 시 아래 카드 목록에서 한 결과를 선택하고 그 효과를 받는 적과 해당 임무를 생성한다. | 미실행 |

### 직책별 원래 행동 순서에서 관찰한 결과

| 실제로 실행한 행동 순서 | 사용 가능한 특수 능력 | 아군 후보 | 다음에 실행한 동작 |
|---|---|---|---|
| `ChosenSniperLastActionSelector` | `TPYDuplicateUnit` | 있음 | `TPYDuplicateUnit` |
| `ChosenWarlockFirstActionSelector` | `TPYChosenCommand` | 있음 | `TPYChosenCommand` |
| `ChosenWarlockLastActionSelector` | `TPYChosenCommand` | 0명 | `StandardShot` |
| `ChosenSniperFirstActionSelector` | `TPYDuplicateUnit` | 0명 | `PistolStandardShot` |
| `ChosenAssassinLastActionSelector` | `TPYChosenCommand` | 0명 | `StandardShot` |

직책별 전체 순서 시험에서는 경쟁 능력의 재사용 대기를 지정했다. 선택받은 자 각각의 첫·마지막 행동 순서 6개에서 `TPYChosenSpecials`로 가는 연결도 실제 병합 결과에서 확인했다. 착지 검사는 주위의 빈 칸에 실제 병력을 배치했다. 복제와 지휘의 아군 후보가 모두 0명인 상황은 시험용 표적 제한으로 재현했다.

### AI 트리와 설정 병합

원본 `XComAI.ini`의 행동 정의 158개, LWOTC 교체 지시 47개, 동등 능력 연결 10개, 범위 공격 프로필 3개를 기준으로 검사했다. 실제 게임 관리자에서 이름 6,054개를 읽었다. 이 중 1개는 검사 전용 행동이다. 원본에 기재된 서로 다른 행동 이름 198개에서 수정으로 폐기한 이름 5개를 식별하고, 남은 시작점과 자식 1,437개를 추적했다. 이 범위에서 순환이나 해결되지 않는 자식 참조는 0개였다. `AddToTargetScore_숫자`와 `AddToAlertDataScore_숫자`는 원본 행동 클래스가 인자를 해석한다. `::`가 붙은 행동은 병종별로 실행된다. 위 수치는 이 구성에서 정적으로 연결을 따라간 범위다.

폐기한 이름 5개는 분대시야 대상 판정, 피의 조류 반응 이름, 잘못된 죽음의 꽃 목적지 찾기, Groundpound의 사전 선택 및 그 보조 노드다. 후자는 실제 TPY 범위 프로필을 사용한다. AI 교체는 LWOTC의 실제 적용 대상과 우선순위 100을 유지한다. Highlander의 `RunAfter`는 템플릿 생성 훅에 적용된다. 본문의 행동 순서는 게임 관리자가 읽은 결과로 확인했다. [Field09](#field09)

## rev002와 배포 확인

이전 배포의 17개 파일이 모두 포함됐다. 14개는 바이트가 같다. 기존 파일 중 바뀐 것은 `Config/XComAI.ini`, `Script/CoarseEnemyAIAndEncounters.u`, `X2DLCInfo_CoarseEncounters.uc`이며, 새 전략·전술 수정의 진입점과 게임에서 읽는 설정을 추가했다. 전체 배포물은 28개 파일(모드 등록 1, INI 12, 소스 14, 패키지 1)이다.

일반 전장에서는 서리·단서 추적자·습격자 특공대와 일반 병력의 단계별 교대가 적용된다. 블랙사이트·포지·사이오닉 게이트·방송탑에는 기존 Tedjam 편성과 ZERO SANITY 분기가 적용된다. 최종 요새의 여섯 포털은 기존 상위형 교체와 대상 편성에 한해 추가 병력을 고른다. 최종판에서도 기존 71개 회귀 항목을 재실행했다. 이번 버전에서 스토리 임무와 요새의 여섯 포털을 캠페인 끝까지 다시 플레이한 사례는 미실행이다. [rev002 세부 편성 및 재현 조건](ModReport_CoarseEnemyAIAndEncounters_rev002.md)

배포 바이너리는 222217바이트이며 SHA-256은 `038b88da19dc9d3dcc2640b401dd040ce1f638bbd29554b9839e5e060db4616e`다. SDK 산출물, 배포 파일, 격리된 전술 설치 파일의 해시와 패키지 헤더를 비교했다. 배포 소스 14개 클래스 이름이 컴파일 패키지에 들어 있다. 기존 모드가 호출하는 `ARFMDarkEvents` 패키지의 공개 인터페이스는 원본을 사용한다. [최종 게임 패키지](../rev003/CoarseEnemyAIAndEncounters/Script/CoarseEnemyAIAndEncounters.u)

## 남은 확인 사항

rev003은 카드의 월 제한·태그·해금, 실제 선택받은 자의 표적과 장비 지급까지 검사했다. 납치·심문 뒤 승리 횟수가 늘어나는 전체 캠페인 과정은 코드로 추적했고, 장기 캠페인과 모든 조합의 연출은 이 버전에서 미실행이다. 해당 진행도의 저장에서 납치·심문 직전과 직후의 승리 횟수를 비교할 수 있다. [후속 캠페인·화면 시험](ModReport_CoarseEnemyAIAndEncounters_rev004.md)

## 재현 기록

최종 배포본은 Release08Regression과 Field12에서 검사했다. 앞선 rev003 시험들과의 마지막 차이는 네트워크 수복 사격의 공황 설정과 어쌔신 착지 칸에 현재 유닛이 있는지 확인하는 판정이다. 복제·지휘·교리·저장·세 직책의 행동 기록은 각 검증 행에 대응하는 이전 rev003 시험과 함께 제시했다.

아래 표에는 한국어 선택지와 당시 검증에 쓴 영문 버튼명을 함께 기재했다. 각 실행에서 `Y3|`로 시작하는 기록을 찾아 입력과 결과를 대조할 수 있다.

| 자료 | 읽을 항목 |
|---|---|
| [BuildRelease08](#buildrelease08) · [Release08Regression](#release08regression) | 최종 SDK 컴파일 결과, COARSE-QA 71 checks 0 failures |
| [Campaign01](#campaign01) · [Campaign04](#campaign04) | CAMPAIGNDECK, CHOICEUI, AFTERCLICK, PERSISTED, LEGACY, ASCENSION, ASCENT, REGION, DOCTRINE |
| [Field03](#field03) · [Field04](#field04) | 아군이 있어도 공격만 하던 수정 전 기록과 복제·지휘·스턴 랜서 후속 공격을 한 수정 후 기록 |
| [Field06](#field06) | CAST, VERSION, POISON. 최초 커서 기술 시험은 이동 경로를 생성하는 진입점을 건너뛰어 중단됐다. Field06에서 게임의 실제 사용 가능 행동 경로로 재검사해 세 기술이 모두 발동했다. |
| [Field08](#field08) | SHADOWSET, SHADOW, ROLE, ACT. 헌터·워록 전체 순서와 어쌔신 이동 좌표. 알림으로 대기한 시간이 있어 이 실행은 다섯 역할 시험 후 종료됐다. |
| [Field09](#field09) | SETTINGS, MONTH, NATIVE, REG, CARDREG, CHOICE, COMMIT, GEAR, POOL, ODDS, BT, BEFORE, ACT, GOLD, FINISHED |
| [Field10](#field10) · [Field12](#field12) | 최종 배포본의 MONTH, NATIVE, REG, CHOICE, GEAR, ODDS, BASHARITEM, PANIC, SHADOW, BLOCKSOURCE, PLACED, BLOCKTILE. 실제 뮤톤 인벤토리 및 공황·제압·착지 봉쇄 조건을 확인. |

최종 전투 로그에 헌터 M3의 회전 애니메이션 `NO_TurnLeft180` 재생 경고가 있다. 같은 시험의 상태·행동 검사는 끝까지 완료됐다. 해당 연출을 제공하는 콘텐츠와 평상시 캠페인에서의 외형은 미확인이다. [Field12](#field12)

## 56개 카드와 세 버튼

원본 등록 순서다. 각 버튼은 한국어 표시명, 시험 당시 영문, 선택 후 추가되는 본부 태그 또는 병사 해금 순으로 읽는다. `ARFMDarkEvents.kor`와 `ARFMDarkEvents.int`에서 같은 `ARFMYearningTemplate`의 `+ChoiceOne`, `+ChoiceTwo`, `+ChoiceThree`를 대조했다. 전설 시험은 168개 버튼 처리 함수를 독립 상태에서 실행했다. 전술 피해와 연출의 확인 범위는 앞의 검증 표에 적었다.

| 카드 식별자 | 월 조건 | 첫 번째 버튼 | 두 번째 버튼 | 세 번째 버튼 |
|---|---|---|---|---|
| `YMTriParteThirtySeven` | 6개월부터 | 민주주의의 수호 (Democracy Protects) · `ARFMPYP_DemocracyProtects` | 민주주의의 해방자들 (Democractic Liberators) · `ARFMPYP_DemocracyLiberates` | 민주주의는 모두를 통합하리라 (Democracy Unifies All) · `ARFMPYP_DemocracyUnifies` |
| `YMTriParteThirtySix` | 3개월부터 | 정밀한 조준 (Pinpoint Accuracy) · `ARFMPYP_Pinpoint` | 무식한 맷집 (Stubborn As A Mule) · `ARFMPYP_StubbornMule` | 기름칠한 듯한 움직임 (Slicker Than Oil) · `ARFMPYP_SlickerThanOil` |
| `YMTriParteThirtyFive` | 3개월부터 | 화장실 벽돌보다 단단함 (Tougher Than A Brick Outhouse) · `ARFMPYP_ShieldbearerArmor` | 섹토이드에게는 바지가 필요하지 않다 (The Sectoid Needs No Pants) · `ARFMPYP_SectoidFortress` | 부동의 폭군 (Stationary Tyrants) · `ARFMPYP_StationaryTyrants` |
| `YMTriParteThirtyFour` | 4개월부터 | 지휘관의 정신력 (Prima Mentalis) · `ARFMPYP_PsiCaptains` | 움직이는 폭정 (Tyranny In Motion) · `ARFMPYP_PsiLancers` | 정오의 교단 (The Cult Of Noon) · `ARFMPYP_PsiBearers` |
| `YMTriParteThirtyThree` | 3개월부터 | 90년대의 블루스 (Nineties Blues) · `ARFMPYP_NinetiesBlues` | 포도탄의 향기와 함께 (With A Whiff Of Grapeshot) · `ARFMPYP_CaptainGrapeshot` | 어쨌든, 나는 쏘기 시작했다 (Anyway, I Started Blasting) · `ARFMPYP_StartedBlasting` |
| `YMTriParteThirtyTwo` | 3개월부터 | 의욕을 고취시키는 처형 (Motivational Executions) · `ARFMPYP_MotivationalExecutions` | 푸딩 제국의 복수 (Revenge Of The Pudding Empire) · `ARFMPYP_PuddingEmpire` | 실업자들의 전성시대 (Massive Day For The Unemployed) · `ARFMPYP_MassiveDay` |
| `YMTriParteThirtyOne` | 3개월부터 | 섹토이드의 다과회 (Sectoid Tea Party) · `ARFMPYP_SectoidTeaParty` | 기름을 두른 뱀 (Snake Oilers) · `ARFMPYP_SnakeOilers` | 복싱을 배운 벌레 (Boxing Bugs) · `ARFMPYP_LiddyBoxing` |
| `YMTriParteThirty` | 3개월부터 | 잔혹한 경찰 (Police Brutality) · `ARFMPYP_PoliceBrutality` | 소금과 후추 (Salt And Pepper) · `ARFMPYP_SaltAndPepper` | 작고 어리석은 놈 (Silly Little Bleeder) · `ARFMPYP_SillyLittleBleeder` |
| `YMTriParteTwentyNine` | 4개월부터 | 시간의 오류 (Date Time Error) · `ARFMPYP_TimeWar` | 이질적인 움직임 (Moving Different) · `ARFMPYP_AvoidSnipes` | 평범한 놈이 아니다 (That's No Ordinary Rabbit) · `ARFMPYP_NoOrdinaryRabbit` |
| `YMTriParteTwentyEight` | 4개월부터 | 고난의 코덱스 (Codex Vexari) · `ARFMPYP_CodexSadness` | 원치 않는 희생 (Unwilling Sacrifices) · `ARFMPYP_ViperShields` | 무적의 힘 (Indomitable Force) · `ARFMPYP_IndomitableForce` |
| `YMTriParteTwentySeven` | 3개월부터 | 치명적 밈 (Deadly Memes) · `ARFMPYP_Soulfuse` | 총검의 대가 (Paynonets) · `ARFMPYP_Paynonets` | 유령 신호 (Ghost Signal) · `ARFMPYP_GhostSignal` |
| `YMTriParteTwentySix` | 12개월부터 | 정예 전도자 (Elite Bashars) · `ARFMPYP_EliteBashars` | 고유 전도자 (Unique Bashars) · `ARFMPYP_UniqueBashars` | 평범한 전도자 (Mundane Bashars) · `ARFMPYP_MundaneBashars` |
| `YMTriParteTwentyFive` | 2개월부터 | 우리에게는 로켓이 있다 (We Got The Rockets) · `ARFMPYP_WeGotTheRockets` | 대혼란 폭발 (Bedlam Blasting) · `ARFMPYP_BedlamBlasting` | 악몽의 연료 (Nightmare Fuel) · `ARFMPYP_NightmareFuel` |
| `YMTriParteTwentyFour` | 5개월부터 | 외상 증폭기 (Trauma Amplifiers) · `ARFMPYP_PainTrain` | 대구경 (High Caliber) · `ARFMPYP_HighCaliber` | 생존 의지 (Will To Survive) · `ARFMPYP_WillToSurvive` |
| `YMTriParteTwentyThree` | 2개월부터 | 이단자를 심판하라 (Suffer Not The Heretic) · `ARFMPYP_HereticBane` | 배신자를 척결하라 (Purge The Betrayers) · `ARFMPYP_BetrayerBane` | 불결한 자를 정화하라 (Cleanse The Unclean) · `ARFMPYP_UnbelieverBane` |
| `YMTriParteTwentyTwo` | 6개월부터 | 저거너트 (Juggernauts) · `ARFMPYP_Dreadnaughts` | 척추 파괴자 (Spinebreakers) · `ARFMPYP_Spinebreakers` | 절대적인 치명타 (Absolutely Critical) · `ARFMPYP_AdventCrits` |
| `YMTriParteTwentyOne` | 4개월부터 | 날카로운 정신 (Edge of Mind) · `ARFMPYP_EdgeOfMind` | 새벽의 화로 (Pyres of Dawn) · `ARFMPYP_PyresOfDawn` | 성배의 저주 (Grail Curse) · `ARFMPYP_GrailCurse` |
| `YMTriParteTwenty` | 6개월부터 | 번개 폭풍 (Lightning Storms) · `ARFMPYP_StunningField` | 섬광 폭발 (Blinding Detonations) · `ARFMPYP_BlindingRockets` | 전투 예지 (Battle Premonitions) · `ARFMPYP_ArchonSteroid` |
| `YMTriParteNineteen` | 3개월부터 | 비글 붕괴 (Beagle Busting) · `ARFMPYP_Beaglebusting` | 전장 태생 (Battle Born) · `ARFMPYP_Battleborn` | 성스러운 전사 (Holy Warriors) · `ARFMPYP_Battlehaunt` |
| `YMTriParteEighteen` | 3개월부터 | 드론 오버로드 (Drone Overlords) · `PYPDroneOverlordsUnlock` | 화학적 날개 (Chemical Pinions) · `ARFMPYP_ChemicalPinions` | 영혼의 화로 (Soul Pyres) · `ARFMPYP_SoulPyres` |
| `YMTriParteSeventeen` | 4개월부터 | 깊은 관통 (Deep Penetration) · `ARFMPYP_DeepPenetration` | 등뼈 부수기 (Back Breakers) · `ARFMPYP_BackBreakers` | 혼란의 충격 (Bewildering Shocks) · `ARFMPYP_BewilderingShocks` |
| `YMTriParteSixteen` | 5개월부터 | 죽음의 저주 (Death Curse) · `ARFMPYP_DeathCurse` | 즉결 처형 (Summary Execution) · `PYPExecutionUnlock` | 죽음의 표식 (Marked For Death) · `PYPMarkedForDeathUnlock` |
| `YMSectopodEmpowerment` | 6개월부터 | 진보된 알고리즘 (Advanced Algorithms) · `ARFMPYP_SectopodGymrats` | 예측 타격 (Predictive Targeting) · `ARFMPYP_SectopodMania` | 생명 추적 (Vital Tracking) · `ARFMPYP_SectopodShoes` |
| `YMSpectreEmpowerment` | 5개월부터 | 다섯 번째 눈의 저주 (The Fifth Eye Curse) · `ARFMPYP_SpectreFifthEye` | 수수께끼 공학 (Enigmatic Engineering) · `ARFMPYP_SpectreRegen` | 어둠의 포옹 (Dark Embrace) · `ARFMPYP_DarkEmbrace` |
| `YMAndromedonEmpowerment` | 5개월부터 | 생물학적 위험 돌진 (Biohazard Blitz) · `ARFMPYP_BlindingAcid` | 강력한 기세 (Crushing Momentum) · `ARFMPYP_StunningStrikes` | 왜곡 신호기 (Warp Beacons) · `ARFMPYP_AndromedonWarpBeacon` |
| `YMPurifierEmpowerment` | 5개월부터 | 공포의 화학물질 (Chemicals Of Terror) · `ARFMPYP_SpookyFlame` | 항구의 유산 (Haber's Legacy) · `ARFMPYP_CripplingFlame` | 치명적인 연기 (Deadly Haze) · `ARFMPYP_RuinousFlame` |
| `YMTriParteFifteen` | 5개월부터 | 불길한 존재 (Haunting Presence) · `ARFMPYP_SpectreTeleport` | 슈퍼 섹토이드 (Super Sectoids) · `ARFMPYP_SuperSectoids` | 억압 (Oppression) · `ARFMPYP_MutonSuppressionShot` |
| `YMTriParteFourteen` | 7개월부터 | 견고한 섹토포드 (Solid Sectopods) · `ARFMPYP_SolidSectopod` | 초강화 외부 장갑 (Super Shells) · `ARFMPYP_GatekeeperSupershell` | 강화 장갑 (Reinforced Plating) · `ARFMPYP_AndromedonPlating` |
| `YMTriParteThirteen` | 4개월부터 | 정화 계획 (Purification Planning) · `ARFMPYP_PurifierUnicorn` | 제 7의 감각 (Seventh Sense) · `ARFMPYP_MutonTapdancer` | 근접 전투 (Close Quarters Combat) · `ARFMPYP_Stunmancy` |
| `YMTriParteTwelve` | 7개월부터 | 원자 광선 (Atomizer Beams) · `ARFMDESW_CHAGatekeeperGirlboss` | 과독 (Hypertoxicitiy) · `ARFMPYP_MurderDrool` | 파괴자 (Juggernautical) · `ARFMPYP_Zerkernaut` |
| `YMTriParteEleven` | 3개월부터 | 방어 전술 (Defensive Tactics) · `ARFMDESW_CHAMutonReposition` | 치명적인 똬리틀기 (Lethal Coils) · `ARFMDESW_CHASnekSnuggles` | 강령 의식 (Necromantic Rituals) · `ARFMPYP_ZombieRoids` |
| `YMTriParteTen` | 5개월부터 | 스펙터 문제 해결 시스템 (Spectre Troubles) · `ARFMDESW_CHASpectreTrouble` | 정예 전투원 (Elite Combatants) · `ARFMDESW_CHAAndromedonGigachad` | 강화 전쟁 프레임 (Enhanced Warframes) · `ARFMDESW_CHAEnhancedWarframes` |
| `YMTriParteNine` | 7개월부터 | 쌍둥이 체임버 (Twin Chambers) · `ARFMPYP_AndromedonDoubleTap` | 깨어나십시오, 주인이시여 (Awaken My Masters) · `ARFMDESW_CHAAwakenMyPoddies` | 새로운 품종 (The New Breed) · `ARFMDESW_CHALiddyRoids` |
| `YMTriParteEight` | 5개월부터 | 복구 프로토콜 (Restoration Protocols) · `ARFMDESW_CHARestorationProtocols` | 통제 불능의 잔혹함 (Unchecked Brutality) · `ARFMDESW_CHAMutonBrutal` | 포격 프로토콜 (Barrage Protocols) · `ARFMDESW_CHASuperArchons` |
| `YMTriParteSeven` | 5개월부터 | 안전 프로토콜 (Safety Protocols) · `ARFMDESW_CHASafetyProtocols` | 우선 표적 지정 (Priority Targeting) · `ARFMDESW_CHAPriorityTargeting` | 고급 훈련 (Advanced Training) · `ARFMDESW_CHAAdvancedTraining` |
| `YMTriParteSix` | 5개월부터 | 전쟁 강철 합금 (Warsteel Alloys) · `ARFMDESW_CHARoboArmor` | 밀폐된 장갑복 (Armor Sealing) · `ARFMDESW_CHAAlienSealedArmor` | 사이오닉 보호 (Psychic Shielding) · `ARFMDESW_CHAPsychicScreens` |
| `YMTriParteFive` | 5개월부터 | 고급 전술 프로세서 (Advanced Tactical Processors) · `ARFMDESW_CHARoboMadness` | 스마트 탄약 (Smart Munitions) · `ARFMDESW_CHAWoodpecker` | 네트워크 수리 (Network Repairs) · `ARFMDESW_CHANetworkRepairs` |
| `YMTriParteFour` | 4개월부터 | 핏빛 광란 (Blood Frenzy) · `ARFMDESW_CHAArchonTurbo` | 전술 분석 (Tactical Analysis) · `ARFMDESW_CHATacticalAnal` | 고급 근접 전투 훈련 (Advanced Melee Combat Training) · `ARFMDESW_CHAStunlancerCounter` |
| `YMTriParteThree` | 4개월부터 | 포격 프로토콜 (Slippery Stalkers) · `ARFMDESW_CHASlipperyStalkers` | 생물학적 증강 (Biological Augmentation) · `ARFMDESW_CHAFacelessJelly` | 폭발 저항 피부 (Blast Resistant Skin) · `ARFMDESW_CHAMutonSkin` |
| `YMTriParteTwo` | 4개월부터 | 믿음의 힘 (Power Through Faith) · `ARFMDESW_CHAPriestProtein` | ICE 프로토콜 (ICE Protocols) · `ARFMDESW_CHAICEProtocols` | 근접 전투 (Close Quarters Combat) · `ARFMDESW_CHAMutonCQC` |
| `YMTriParteOne` | 4개월부터 | 완전 엄폐 프로토콜 (Deep Cover Protocols) · `ARFMDESW_CHATroopyFace` | 소각 포드 (Incineration Pods) · `ARFMDESW_CHAIncinerationPods` | 적응형 근육 조직 (Adaptive Musculature) · `ARFMDESW_CHASpeedyGonzales` |
| `YMTrooperGrenades` | 2개월부터 | 플라즈마 수류탄 (Plasma Grenades) · `ARFMPYP_TrooperPlasmaGrenade` | 가스 수류탄 (Gas Grenades) · `ARFMPYP_TrooperGasGrenade` | 산성 수류탄 (Acid Grenades) · `ARFMPYP_TrooperAcidGrenade` |
| `YMStunlancerGrenades` | 2개월부터 | 플라즈마 수류탄 (Plasma Grenades) · `ARFMPYP_StunlancerPlasmaGrenade` | 가스 수류탄 (Gas Grenades) · `ARFMPYP_StunlancerGasGrenade` | 산성 수류탄 (Acid Grenades) · `ARFMPYP_StunlancerAcidGrenade` |
| `YMShieldbearerMindLink` | 0~3개월 | 정신 연계 - 지각 (Mind Link - Perception) · `ARFMPYP_ShieldbearerPerceptionLink` | 정신 연계 - 정밀 (Mind Link - Precision) · `ARFMPYP_ShieldbearerPrecisionLink` | 정신 연계 - 전술 (Mind Link - Tactics) · `ARFMPYP_ShieldbearerTacticLink` |
| `YMLancerMindLink` | 0~3개월 | 정신 연계 - 지각 (Mind Link - Perception) · `ARFMPYP_LancerPerceptionLink` | 정신 연계 - 정밀 (Mind Link - Precision) · `ARFMPYP_LancerPrecisionLink` | 정신 연계 - 전술 (Mind Link - Tactics) · `ARFMPYP_LancerTacticLink` |
| `YMPriestMindLink` | 0~3개월 | 정신 연계 - 지각 (Mind Link - Perception) · `ARFMPYP_PriestPerceptionLink` | 정신 연계 - 정밀 (Mind Link - Precision) · `ARFMPYP_PriestPrecisionLink` | 정신 연계 - 전술 (Mind Link - Tactics) · `ARFMPYP_PriestTacticLink` |
| `YMOfficerMindLink` | 0~3개월 | 정신 연계 - 지각 (Mind Link - Perception) · `ARFMPYP_OfficerPerceptionLink` | 정신 연계 - 정밀 (Mind Link - Precision) · `ARFMPYP_OfficerPrecisionLink` | 정신 연계 - 전술 (Mind Link - Tactics) · `ARFMPYP_OfficerTacticLink` |
| `YMTrooperMindLink` | 0~3개월 | 정신 연계 - 지각 (Mind Link - Perception) · `ARFMPYP_TrooperPerceptionLink` | 정신 연계 - 정밀 (Mind Link - Precision) · `ARFMPYP_TrooperPrecisionLink` | 정신 연계 - 전술 (Mind Link - Tactics) · `ARFMPYP_TrooperTacticLink` |
| `YMMECEnhancement` | 0~3개월 | 성형작약 폭발 (Shaped Detonations) · `ARFMPYP_MacroMissiles` | 지형 매핑 (Terrain Mapping) · `ARFMPYP_TerrainMapping` | 합금 장갑판 (Alloyed Armor) · `ARFMPYP_MECArmor` |
| `YMMutonEnhancement` | 0~3개월 | 강력한 타격자 (Heavy Hitters) · `ARFMPYP_HitterMuton` | 잔혹한 근력 (Brutalist Strength) · `ARFMPYP_BrutalistMuton` | 초반응 (Hyper Reactive) · `ARFMPYP_ReactiveMuton` |
| `YMPriestEnhancement` | 0~3개월 | 공허의 사제 (Void Priests) · `ARFMPYP_VoidPriest` | 전투 사제 (Battle Priests) · `ARFMPYP_BattlePriest` | 그림자 사제 (Umbra Priests) · `ARFMPYP_UmbraPriest` |
| `YMOfficerEnhancement` | 0~3개월 | 방어 전술 (Defensive Tactics) · `ARFMPYP_OfficerDefense` | 가속 체임버 (Acceleration Chambers) · `ARFMPYP_OfficerDamage` | 스마트 조준경 (Smart Scopes) · `ARFMPYP_OfficerAim` |
| `YMTrooperEnhancement` | 0~3개월 | 방어 전술 (Defensive Tactics) · `ARFMPYP_TrooperDefense` | 가속 체임버 (Acceleration Chambers) · `ARFMPYP_TrooperDamage` | 스마트 조준경 (Smart Scopes) · `ARFMPYP_TrooperAim` |
| `YMSectoidEnhancement` | 0~3개월 | 기억술 (Mnemonics) · `ARFMPYP_SectoidPsi` | 증폭기 (Amplifiers) · `ARFMPYP_SectoidDamage` | 조정 (Calibration) · `ARFMPYP_SectoidAim` |
| `YMStunlancerEnhancement` | 0~3개월 | 방어 전술 (Defensive Tactics) · `ARFMPYP_StunlancerDefense` | 선봉대 (Vanguards) · `ARFMPYP_StunlancerMove` | 매의 눈 (Eagle Eyes) · `ARFMPYP_StunlancerAim` |
| `YMPurifierEnhancement` | 0~3개월 | 두개골 강화 (Cranial Reinforcement) · `ARFMPYP_PurifierCranialReinforcement` | 재생력 (Regeneratives) · `ARFMPYP_PurifierRegeneration` | 방어구 (Armor) · `ARFMPYP_PurifierArmor` |

## 검증 로그 발췌

각 항목은 해당 시험에서 기록한 로그 행이다. 타임스탬프와 게임 이력 번호는 각각의 실행을 기준으로 한다.

### Field06

```text
[0083.20] ScriptLog: Y3|VERSION|Core|1.32.0|1cba26
[0083.20] ScriptLog: Y3|VERSION|Engine|1.32.0|1cba26
[0083.20] ScriptLog: Y3|VERSION|XComGame|1.32.0|1cba26
[0083.20] ScriptLog: Y3|VERSION|X2WOTCCommunityHighlander|1.32.0|1cba26
[0083.20] ScriptLog: Y3|VERSION|DLC_2|1.32.0|1cba26
[0165.55] ScriptLog: Y3|POISON|2|2|0|0
[0168.56] ScriptLog: Y3|CAST|TPYChosenWave|True|0|2|5,17|5,17
[0180.57] ScriptLog: Y3|CAST|TPYChosenTeleport|True|0|3|17,13|15,11
[0192.59] ScriptLog: Y3|CAST|TPYChosenGroundpound|True|10|5|10,12|10,12
```

### Field09

```text
[0143.93] ScriptLog: Y3|SETTINGS|3|True|3|20
[0144.02] ScriptLog: Y3|COMMIT|True|1|False|2|-1
[0162.29] ScriptLog: Y3|GOLD|True|False|AA_AbilityUnavailable|AA_Success|AA_AbilityUnavailable|AA_AbilityUnavailable|True|40|20|7|20|1
[0168.36] ScriptLog: Y3|BEFORE|8|Suite|3810|TPYDuplicateUnit|4|3|AA_Success|AA_CoolingDown
[0168.36] ScriptLog: Y3|BEFORE|8|Suite|3810|TPYChosenCommand|4|10|AA_Success|AA_CoolingDown
[0317.24] ScriptLog: Y3|BEFORE|15|Suite|3810|TPYDuplicateUnit|0|0|AA_NoTargets|AA_Success
[0317.24] ScriptLog: Y3|BEFORE|15|Suite|3810|TPYChosenCommand|0|0|AA_NoTargets|AA_Success
[0338.24] ScriptLog: Y3|BEFORE|22|Suite|3810|TPYDuplicateUnit|0|3|AA_Success|AA_Success
[0338.24] ScriptLog: Y3|BEFORE|22|Suite|3810|TPYChosenCommand|0|10|AA_Success|AA_Success
[0359.24] ScriptLog: Y3|BEFORE|29|Suite|3810|TPYDuplicateUnit|4|4|AA_Success|AA_CoolingDown
[0359.24] ScriptLog: Y3|BEFORE|29|Suite|3810|TPYChosenCommand|0|11|AA_Success|AA_Success
```

### BuildRelease08

```text
[0005.27] Log: Success - 0 error(s), 0 warning(s) (0 Unique Errors, 0 Unique Warnings)
```

### Release08Regression

```text
[0007.71] ScriptLog: COARSE-QA 71 checks 0 failures
```

### Campaign01

```text
[0127.49] ScriptLog: Y3|STRATSTART|3|True
[0150.64] ScriptLog: Y3|CAMPAIGNDECK|56|3|True
[0150.65] ScriptLog: Y3|CHOICEUI|YMTriParteNineteen|Beagle Busting|Battle Born|Holy Warriors|3
[0158.66] ScriptLog: Y3|AFTERCLICK|1|True|False
[0158.83] ScriptLog: Y3|SAVECOMPLETE|True|0
[0162.07] ScriptLog: Y3|LOADCOMPLETE|True
[0191.69] ScriptLog: Y3|CAMPAIGNDECK|56|3|True
[0191.69] ScriptLog: Y3|PERSISTED|True|1|True|2
```

### Campaign04

```text
[0145.88] ScriptLog: Y3|ASCENSION|Chosen_Assassin|5|9|True
[0145.88] ScriptLog: Y3|ASCENSION|Chosen_Hunter|5|9|True
[0145.88] ScriptLog: Y3|ASCENSION|Chosen_Warlock|5|9|True
[0145.89] ScriptLog: Y3|DOCTRINE|0.5000|0.8000|1|16|0|1|True
[0177.28] ScriptLog: Y3|LEGACY|56|0|False
```

### Field03

```text
[0174.86] ScriptLog: Y3|BEFORE|Normal|3821|TPYDuplicateUnit|0|2|AA_Success|AA_Success
[0174.86] ScriptLog: Y3|BEFORE|Normal|3821|TPYChosenCommand|0|9|AA_Success|AA_Success
[0177.87] ScriptLog: Y3|ACT|1676|ChosenAssassinM3|3821|StandardShot|2205
[0203.45] ScriptLog: Y3|BEFORE|Normal|3821|TPYDuplicateUnit|4|2|AA_Success|AA_CoolingDown
[0203.45] ScriptLog: Y3|BEFORE|Normal|3821|TPYChosenCommand|0|9|AA_Success|AA_Success
[0206.46] ScriptLog: Y3|ACT|1686|ChosenAssassinM3|3821|StandardShot|2170
```

### Field04

```text
[0244.48] ScriptLog: Y3|ACT|1718|ChosenAssassinM3|3803|TPYDuplicateUnit|4224
[0265.49] ScriptLog: Y3|ACT|1788|ChosenAssassinM3|3803|TPYChosenCommand|4224
[0265.49] ScriptLog: Y3|ACT|1790|AdvStunLancerM1|4224|StunLance|2142
```

### Field08

```text
[0171.27] ScriptLog: Y3|SHADOWSET|62|-1|False|True|4665
[0177.29] ScriptLog: Y3|SHADOW|False|True|True|3|7,7|10,3|10,2|10,2|0,1
[0186.25] ScriptLog: Y3|ROLE|ChosenSniperLastActionSelector|4123|TPYDuplicateUnit|False|True|2148
[0189.25] ScriptLog: Y3|ACT|2149|ChosenSniperM3|4123|TPYDuplicateUnit|4543
[0384.77] ScriptLog: Y3|ROLE|ChosenWarlockFirstActionSelector|3968|TPYChosenCommand|False|True|2185
[0387.77] ScriptLog: Y3|ACT|2186|ChosenWarlockM3|3968|TPYChosenCommand|4668
[0396.78] ScriptLog: Y3|ROLE|ChosenWarlockLastActionSelector|3968|TPYChosenCommand|True|True|2189
[0399.78] ScriptLog: Y3|ACT|2190|ChosenWarlockM3|3968|StandardShot|2156
[0408.77] ScriptLog: Y3|ROLE|ChosenSniperFirstActionSelector|4123|TPYDuplicateUnit|True|True|2225
[0411.77] ScriptLog: Y3|ACT|2226|ChosenSniperM3|4123|PistolStandardShot|2184
[0420.77] ScriptLog: Y3|ROLE|ChosenAssassinLastActionSelector|3831|TPYChosenCommand|True|True|2238
```

### Field10

```text
[0164.19] ScriptLog: Y3|BASHARITEM|YearningAllSeeingBashar|True|2|2|
[0164.23] ScriptLog: Y3|BASHARITEM|YearningMassFireBashar|True|4|3|
[0164.24] ScriptLog: Y3|BASHARITEM|YearningSpeedBashar|True|3|3|
```

### Field12

```text
[0145.73] ScriptLog: Y3|SETTINGS|3|True|3|20
[0145.82] ScriptLog: Y3|CONFIG|True|10|0
[0164.08] ScriptLog: Y3|PANIC|True|AA_Success|AA_Success|AA_UnitIsPanicked|AA_UnitIsSuppressed|AA_UnitIsSuppressed|1|AA_Success
[0170.08] ScriptLog: Y3|SHADOW|False|True|True|3|13,18|3,22|2,22|2,22|1,0
[0176.05] ScriptLog: Y3|BLOCKSOURCE|Soldier|True|2142|1|True
[0176.15] ScriptLog: Y3|PLACED|1,21|1,21
[0176.25] ScriptLog: Y3|PLACED|1,22|1,22
[0176.36] ScriptLog: Y3|PLACED|1,23|1,23
[0176.48] ScriptLog: Y3|PLACED|2,21|2,21
[0176.60] ScriptLog: Y3|PLACED|2,23|2,23
[0176.75] ScriptLog: Y3|PLACED|3,21|3,21
[0176.89] ScriptLog: Y3|PLACED|3,22|3,22
[0177.05] ScriptLog: Y3|PLACED|3,23|3,23
[0185.87] ScriptLog: Y3|BLOCKTILE|True|8|False|AA_TileIsBlocked
```
