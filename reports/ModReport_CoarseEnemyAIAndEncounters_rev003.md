# LWOTC Coarse 적 AI·Tedjam 통합 모드 rev003

전설 난이도에서 **That Perilous Yearning(TPY)**을 켰을 때 선택 결과가 저장되고, 선택받은 자가 획득한 능력을 실제 표적에게 사용하며, 뮤톤 Bashar가 선택한 강화군에 맞는 장비를 받게 했다. 암살자의 복제·지휘·저격수 추적과 황금 갑옷 암흑 이벤트의 사이오닉 감소를 게임에서 검사했다. rev002의 일반 적 AI, 병력 교대, 스토리 임무와 최종 요새 포털 수정도 이 모드에 들어 있다.

검사일은 2026년 11월 21일이다. Windows Steam판 선택된 자의 전쟁과 LWOTC를 사용했다.

## 사용 방법

1. 런처의 로컬 모드 검색 경로에 [rev003 폴더](../rev003/)를 Workshop 경로 다음으로 추가한다. 기존 rev002 경로를 빼고 새로 고친 뒤 **LWOTC Coarse - Enemy AI and Encounters**의 위치가 [이번 배포 폴더](../rev003/CoarseEnemyAIAndEncounters/)인지 확인하고 게임을 다시 시작한다. 두 버전의 내부 ID는 모두 `CoarseEnemyAIAndEncounters`다.
2. **Requiem Legion: Coarse Edition**(3555944655), **2795578857**(`ARFMDarkEvents`), **Totally Reasonable Definitely Not Psychotic Tedjam Plugin**(3835619377), LWOTC, Ted Mod Jam, ARFM Advent Pack, WotC Community Highlander를 활성화한다. 구형 독립 AI·요새 패치의 중복 여부는 `Config/XComGame.ini`의 `IncompatibleMods` 목록에서 확인할 수 있다.
3. 캠페인 난이도를 **전설**, 세컨드 웨이브 옵션을 **That Perilous Yearning**으로 설정한다. 이번 검증은 분리한 프로필과 저장 슬롯으로 진행했다. 기존 캠페인의 누락 카드는 전략 저장을 다시 불러올 때 복구된다. 이미 선택한 카드는 남아 있는 태그·선택 횟수를 유지한다. 예전 버전이 같은 이름으로 기록한 두 카드와 과거에 잘못 적용한 보너스는 당시 선택을 식별할 근거가 없어 소급 재배정하지 않는다.

## 수정한 동작

| 대상 | 발동 조건과 결과 | 위치 |
|---|---|---|
| 카드 18·19·21 및 세 버튼 | 19번 원본 팩터리가 18번과 같은 이름을 등록했다. 18번과 19번을 각각 생성하고 세 버튼을 각 카드의 원래 결과에 연결했다. 21번 두 번째 Pyres of Dawn은 정화병 화염방사기 선택을 적용한다. 버튼을 누르면 선택 횟수와 선택 번호를 같은 상태에 기록하고 중복 입력을 차단한다. 후보가 없는 달에는 창을 열지 않는다. | CoarseYearningCards.uc · CoarseYearningStrategy.Install / OpenChoice / ApplyChoice · UICoarseYearningChoice.Choose |
| 선택받은 자의 행동 순서 | 복제와 지휘에서 유효한 아군에게 양수의 점수를 준다. 재사용 대기·표적 없음이면 다음 후보를 평가한다. 세 직책의 첫·마지막 행동에 특수 능력 경로를 연결했다. 기존 우선 수류탄, 사냥꾼의 첫 추적 사격, 워록의 소환 순위를 보존한다. | Config/XComAI.ini · SelectTargetForTPYDuplicateUnit / SelectTargetForTPYChosenCommand / TPYChosenSpecials |
| 선택받은 자의 능력 | 변화 헌신이 실제 등록된 순간이동을 부여한다. 지휘에는 원본 게임의 자동 명중 판정을 지정했다. 복제 연출은 지휘자와 복제할 아군을 구분한다. Like a Shadow는 변화 헌신이 있는 암살자가 시야 내 비은폐 적 저격수 옆 빈 칸으로 이동한다. 유효한 착지 칸이 없으면 표적 후보에서 제외한다. | CoarseYearningPowers.Install / VisualizeDuplicate / PrepareShadowStalk · X2Condition_CoarseShadowStalkTile.uc |
| 무기와 장비 | 선택받은 자 무기 강화와 Bashar 강화를 각각 켜고 끌 수 있다. 무기 교체 시 이전 무기·탄약이 주던 능력을 정리하고 새 장비의 능력을 등록한다. 원래 빈 슬롯은 다른 패시브의 지급원으로 처리하지 않는다. 선택된 스턴 랜서·트루퍼 수류탄도 지급한다. 여러 번 호출돼도 같은 유닛에 추첨을 반복하지 않는다. | CoarseYearningEquipment.OnUnitBeginPlay / GetChosenWeapons / ApplyGear |
| Bashar 강화 | 생존한 선택받은 자가 0명이어도 선택지에 해당하는 뮤톤은 해당 강화군을 먼저 추첨한다. 그 밖의 뮤톤은 일반군 대상이 될 수 있다. All-Seeing 장비와 연결 능력을 복구했다. | CoarseYearningEquipment.DrawBashar · CoarseYearningPowers.RegisterMissingAbilities |
| 전략 승천·교리 | 세 직책의 3단계 강화와 공통 승천은 선택받은 자의 보유·공개 특성을 한 번씩 등록한다. 헌신과 측면 특성의 원래 추첨 가중치를 유지한다. 월말에 소모·섬멸·제압·압제 교리를 진행 중인 월말 상태에 반영한다. 압제가 뽑을 반복 암흑 이벤트가 없으면 추첨을 건너뛴다. 납치·심문 승리 횟수도 제출 가능한 새 상태에 기록한다. | CoarseChosenAscent.ApplyAscent · CoarseYearningStrategy.ApplyDoctrines / RecordChosenVictory |
| 독·사이오닉·누락 능력 | Murder Drool은 선택된 바이퍼 계열의 적격 독 피해에만 보너스를 준다. 황금 갑옷(Armored in Gold)은 활성 암흑 이벤트 목록을 읽어 XCOM 병사의 사이오닉 수치를 설정 배율(기본 0.5)로 한 번 줄이며, 원본 7개 능력 금지를 함께 적용한다. Medical Surplus, Tactical Analysis, Calendarium 저격 관련 누락 등록과 Scar of Decrepitude의 하위 참조, Scar of Winter·Soul Hack의 사용 입력을 복구했다. | CoarseYearningPowers.uc · X2Condition_CoarseArmoredInGold.uc · X2Effect_CoarseViperPoison.uc |
| 원본 설정 읽기 | NetworkRepairsAllowedPanicked를 켜면 공황 중 Network Repair 반응 사격이 허용되고, 끄면 공황이 차단한다. 일반·광역 제압은 양쪽에서 사격을 막는다. 원본은 허용 설정에서 공황을 제외 조건에 더했다. Precision Link는 LWOTC에서 생존 그룹원 2명 이상이면 1명당 치명타 +5를 사용한다. 일반 분기 값은 10이다. MeleeBreakthroughCap=0은 추가 피해 상한을 해제한다. | Config/XComGameData_BeyondLegendary.ini · Config/XComTPYConfig.ini |

스크립트 파일은 배포 폴더의 `Src/CoarseEnemyAIAndEncounters/Classes/` 아래에 있다. 변경은 독립 모드에서 적용한다. Workshop 2795578857의 원본 패키지 SHA-256은 `68d19020323e73d0082e8190ad0df36ba888c01e05104b9954cd43b8cdb12da1`다.

## 선택받은 자 무기와 Bashar 확률

무기 교체는 선택받은 자가 2명 이하이거나 외계인 전력 수준(FL)이 16 이상일 때 열린다. 그 안에서 아바타 처치 목표를 완료했거나 생존 1명 이하·FL 20 이상이면 M3, 생존 1명 이하·FL 20 미만 또는 블랙사이트 조사 완료·FL 16 이상이면 M2다. 나머지는 기본 강화형을 쓴다. 난수 0~199에서 0~100과 101~199가 서로 다른 무기 조합이다. 암살자는 산탄총과 검, 사냥꾼은 저격총과 권총, 워록은 소총 또는 기관단총을 교체한다.

| 뮤톤의 조건 | 성공 수 / 200 | 게임 내 확률 |
|---|---|---|
| 특화 선택 없음 · 생존 2명·FL 16 이상 | 16 | 8% |
| 특화 선택 없음 · 생존 1명·FL 12 이상 | 41 | 20.5% |
| 생존 0명 일반 승급, 또는 해당 특화군의 승급 조건 충족 | 91 | 45.5% |
| 특화군 선택 · 생존 3명·FL 19 이하 | 0 | 0% |

특화군은 원본의 정예·변종·일반 뮤톤 이름 판정을 사용한다. 생존 3명일 때 FL 20부터, 2명 이하이면 FL에 관계없이 해당 특화군이 열린다. 일반·정예·변종·일반형 특화 추첨표를 합쳐 서로 다른 장비가 21종이다. 같은 장비가 두 번 들어가는 원본의 가중치는 보존했다.

## 확인 범위와 환경

원본 UnrealScript 254개와 Config 하위 INI 24개를 기준으로 진입점·식별자·참조를 조사했다. XComTPYConfig.ini에는 83개 섹션이 있다. 시험 프로필의 Workshop 모드 390개 중 Config가 있는 386개 폴더와 그 하위 파일을 대조하고, 게임이 병합한 행동 트리를 읽었다. 시험 프로필에는 Coarse Edition을 사용했다. 원본 게임·Workshop·개인 캠페인 저장은 참조용이다.

엔진 빌드 8917에서 Core, Engine, XComGame, X2WOTCCommunityHighlander, DLC_2 다섯 구성 요소가 모두 1.32.0(1cba26)으로 로드됐다. ARFMDarkEvents와 배포 패키지의 NonNativePackages 등록, SDK 의존 패키지와 검사에 사용한 원본 바이너리의 해시를 비교했다. 패키지 사본은 시험 프로필에서 각 1개였다. DLC 경로와 실행된 클래스·행동을 확인했다. 실행 로그에 개별 .u 파일의 절대 로드 경로는 표시되지 않았다. [Field06](#field06)

## 재현과 결과

전술 빠른 시작에서는 전설·TPY를 설정하고 세 선택받은 자, 아군 병력과 XCOM 표적을 배치했다. 특정 행동을 고립시킨 시험은 다른 능력의 재사용 대기, 표적 조건, 행동력을 명시적으로 맞췄다. 전략 화면과 저장·재불러오기는 새 전설 캠페인에서 별도로 시험했다.

| 검증 방식 | 재현 조건과 절차 | 예상 결과 | 관찰 결과 | 상태 |
|---|---|---|---|---|
| 실게임 전략 화면 | 전설 새 캠페인, TPY 켬. 19번 카드가 제시된 창의 세 버튼을 확인하고 3번 선택 후 저장·재불러오기. | 56개 등록, 선택 1회, 버튼 3만 참, 같은 카드 재제시 차단. | 56개. Beagle Busting / Battle Born / Holy Warriors 표시. 횟수 1·3번 선택·중복 차단·저장 복원 확인. | 통과 |
| 실게임 구버전 저장 모사 | 전략 상태에서 19번 카드만 제거해 55개로 저장하고 실제 재불러오기. | 원본의 누락 카드 복구 훅으로 56개. 복구된 카드는 미선택. | 56개, 19번 횟수 0, 3번 선택 거짓. | 통과 |
| 실게임 전략 데이터·월 제한 | 56개 카드 각각 최소 개방 월, 해당하면 직전 월·최대 월·바로 다음 월에서 CanActivate 호출. | 원본 카드별 개방·차단 경계와 일치. | 56/56 일치. | 통과 |
| 실게임 선택 결과 | 각 카드의 세 버튼을 독립 상태에서 평가하고 횟수·버튼·HQ 태그 또는 병사 해금을 확인. 21번 2번은 상태 제출 후 재조회. | 168개 각각 기대값. 21번은 Pyres of Dawn만 추가. | 168/168 일치. 165개 태그와 3개 병사 해금. 정화병 태그 존재, MEC 미사일 실명 태그 부재. | 통과 |
| 실게임 템플릿 조회 | 원본이 생성하는 전략·특수 상황 효과·리스너·캐릭터·배신 임무와 서술 항목을 각 게임 관리자에서 조회. | 추출한 337개 등록. | 전략 241, 리스너 47, 특수 상황 효과 40, 캐릭터 7, 임무 1, 서술 1. 누락 0개. | 통과 |
| 실게임 능력·장비 참조 | 원본 코드에서 추출한 무기·장비 능력과 하위 능력을 실제 게임 관리자에서 조회. | 추적한 장비와 능력이 존재하고 지급 대상으로 지정한 이름이 풀림. | 장비 64개, 능력 273개. 조회 실패 및 끊긴 하위 능력 0개. | 통과 |
| 실게임 장비 경계 | 직책 × 생존 수 × 전력 수준 × 블랙사이트·아바타 목표 × 두 무기 추첨 경계. 실제 세 직책·스턴 랜서도 생성. | 42개 기대 조합, 각 직책에 지정 무기, 스턴 랜서에게 가스 수류탄. | 42/42. 실제 캐릭터 인벤토리에서 세 무기 조합과 GasGrenade 확인. 양 강화 옵션을 끈 뒤 생성한 뮤톤·사냥꾼은 원래 장비 유지. | 통과 |
| 실게임 Bashar 추첨 | 정예·변종·일반형 및 일반 승급, 생존 수·FL과 경계 난수를 조합. 조건 18개 각각 모든 0~199 입력을 한 번씩 사용. | 조건별 0, 16, 41 또는 91회 성공. 정해진 장비군 준수. | 입력 3,600개 모두 기대 횟수 일치. 별도 장비군 경계 24/24. 실제 뮤톤에게 Bashar 장비 지급 확인. | 통과 |
| 실게임 Bashar 개별 장비 | 21개 원본 장비를 각각 독립 상태의 전술 뮤톤 인벤토리에 넣고 무기별로 초기화되는 능력과 이미 보유한 능력을 원본 장비 정의에 대조. | 각 장비가 약속한 능력이 유닛에 있는지 확인. | 21종 중 21종에서 원본이 약속한 지급 능력을 모두 찾았다. | 통과 |
| 실게임 복제·지휘와 후속 행동 | 암살자에게 두 능력을 부여. 모두 대기 4턴, 둘 다 후보 0명, 둘 다 준비, 복제만 대기 네 상태에서 같은 행동 분기를 실행. | 두 실패 시 다음 일반 행동, 사용 가능할 때 아군 복제·지휘. | 대기 → StandardShot, 후보 0명 → StandardShot, 둘 다 준비 → TPYDuplicateUnit, 복제만 대기 → TPYChosenCommand. 원래 지휘받은 스턴 랜서가 실제 StunLance를 사용한 전투도 확인. | 통과 |
| 실게임 헌신·저격수 추적 | 암살자에게 변화 헌신을 주고 시야 안 병사의 주 무기를 일반 소총에서 저격총으로 교체. | 헌신 없는 암살자 및 일반 소총병 제외. 사용 시 암살자만 인접 칸으로 이동. | 암살자 능력 생성 조건 거짓→참, 사냥꾼 캐릭터 직접 지급 없음. 암살자 13,18→3,22, 저격수 2,22→2,22, 재사용 대기 3턴. | 통과 |
| 실게임 착지 칸 없음 | 저격수 주변에서 실제로 접근 가능한 칸을 병력으로 채운 뒤 같은 표적 조건 재평가. | 빈 칸이 없으면 AA_TileIsBlocked. | 착지 가능에서 검사. 저격수 주위에 8기 배치, 이후 후보 없음, 표적 판정 AA_TileIsBlocked. | 통과 |
| 실게임 파동·순간이동·강타 | 전설 전투에서 캐릭터의 사용 가능 목록으로 능력을 발동하고 처리 후 위치·재사용 대기·추가 표적 수를 조회. | 유효한 발동과 원본 대기 턴, 순간이동은 시전자 이동. | 파동 2턴(추가 표적 0), 순간이동 3턴(17,13→15,11), 강타 5턴(추가 표적 10명). | 통과 |
| 실게임 반응 사격 조건 | 전설에서 Network Repair Shot의 실제 발사자 조건에 공황·제압·광역 제압을 각각 전달하고 공황 허용을 두 번 껐다가 복원. | 허용 시 공황 통과, 비허용 시 공황 차단 1회, 제압과 광역 제압 모두 차단. | 기본 AA_Success, 공황 허용 AA_Success, 비허용 AA_UnitIsPanicked, 제압 AA_UnitIsSuppressed, 광역 제압 AA_UnitIsSuppressed, 비허용 중복 등록 후 차단 항목 1개, 복원 AA_Success. | 통과 |
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
| ChosenSniperLastActionSelector | TPYDuplicateUnit | 있음 | TPYDuplicateUnit |
| ChosenWarlockFirstActionSelector | TPYChosenCommand | 있음 | TPYChosenCommand |
| ChosenWarlockLastActionSelector | TPYChosenCommand | 0명 | StandardShot |
| ChosenSniperFirstActionSelector | TPYDuplicateUnit | 0명 | PistolStandardShot |
| ChosenAssassinLastActionSelector | TPYChosenCommand | 0명 | StandardShot |

직책별 전체 순서 시험에서는 경쟁 능력의 재사용 대기를 지정했다. 선택받은 자 각각의 첫·마지막 행동 순서 6개에서 TPYChosenSpecials로 가는 연결도 실제 병합 결과에서 확인했다. 착지 검사는 주위의 빈 칸에 실제 병력을 배치했다. 복제와 지휘의 아군 후보가 모두 0명인 상황은 시험용 표적 제한으로 재현했다.

### AI 트리와 설정 병합

원본 XComAI.ini의 행동 정의 158개, LWOTC 교체 지시 47개, 동등 능력 연결 10개, 범위 공격 프로필 3개를 기준으로 검사했다. 실제 게임 관리자에서 이름 6,054개를 읽었다. 이 중 1개는 검사 전용 행동이다. 원본에 기재된 서로 다른 행동 이름 198개에서 수정으로 폐기한 이름 5개를 식별하고, 남은 시작점과 자식 1,437개를 추적했다. 이 범위에서 순환이나 해결되지 않는 자식 참조는 0개였다. `AddToTargetScore_숫자`와 `AddToAlertDataScore_숫자`는 원본 행동 클래스가 인자를 해석한다. `::`가 붙은 행동은 병종별로 실행된다. 위 수치는 이 구성에서 정적으로 연결을 따라간 범위다.

폐기한 이름 5개는 분대시야 대상 판정, Blood Tide 반응 이름, 잘못된 Death Blossom 목적지 찾기, Groundpound의 사전 선택 및 그 보조 노드다. 후자는 실제 TPY 범위 프로필을 사용한다. AI 교체는 LWOTC의 실제 적용 대상과 우선순위 100을 유지한다. Highlander의 RunAfter는 템플릿 생성 훅에 적용된다. 본문의 행동 순서는 게임 관리자가 읽은 결과로 확인했다. [Field09](#field09)

## rev002와 배포 확인

이전 배포의 17개 파일이 모두 포함됐다. 14개는 바이트가 같다. 기존 파일 중 바뀐 것은 `Config/XComAI.ini`, `Script/CoarseEnemyAIAndEncounters.u`, `X2DLCInfo_CoarseEncounters.uc`이며, 새 전략·전술 수정의 진입점과 게임에서 읽는 설정을 추가했다. 전체 배포물은 28개 파일(모드 등록 1, INI 12, 소스 14, 패키지 1)이다.

일반 전장에서는 Frost·아웃사이더·랩터와 일반 병력의 단계별 교대가 적용된다. 블랙사이트·포지·사이오닉 게이트·방송탑에는 기존 Tedjam 편성과 ZERO SANITY 분기가 적용된다. 최종 요새의 여섯 포털은 기존 상위형 교체와 대상 편성에 한해 추가 병력을 고른다. 최종판에서도 기존 71개 회귀 항목을 재실행했다. 이번 버전에서 스토리 임무와 요새의 여섯 포털을 캠페인 끝까지 다시 플레이한 사례는 미실행이다. [rev002 세부 편성 및 재현 조건](ModReport_CoarseEnemyAIAndEncounters_rev002.md)

배포 바이너리는 222217바이트이며 SHA-256은 `038b88da19dc9d3dcc2640b401dd040ce1f638bbd29554b9839e5e060db4616e`다. SDK 산출물, 배포 파일, 격리된 전술 설치 파일의 해시와 패키지 헤더를 비교했다. 배포 소스 14개 클래스 이름이 컴파일 패키지에 들어 있다. 기존 모드가 호출하는 ARFMDarkEvents 패키지의 공개 인터페이스는 원본을 사용한다. [최종 게임 패키지](../rev003/CoarseEnemyAIAndEncounters/Script/CoarseEnemyAIAndEncounters.u)

## 재현 기록

최종 배포본은 Release08Regression과 Field12에서 검사했다. 앞선 rev003 시험들과의 마지막 차이는 Network Repair 사격의 공황 설정과 암살자 착지 칸에 현재 유닛이 있는지 확인하는 판정이다. 복제·지휘·교리·저장·세 직책의 행동 기록은 각 검증 행에 대응하는 이전 rev003 시험과 함께 제시했다.

검증에 사용한 영문 옵션 이름은 바로 아래 카드 목록에 수록했다. 실험마다 새로 기록한 파일에서 `Y3|` 뒤의 구분자를 검색하면 원자료를 볼 수 있다.

| 자료 | 읽을 항목 |
|---|---|
| [BuildRelease08](#buildrelease08) · [Release08Regression](#release08regression) | 최종 SDK 컴파일 결과, COARSE-QA 71 checks 0 failures |
| [Campaign01](#campaign01) · [Campaign04](#campaign04) | CAMPAIGNDECK, CHOICEUI, AFTERCLICK, PERSISTED, LEGACY, ASCENSION, ASCENT, REGION, DOCTRINE |
| [Field03](#field03) · [Field04](#field04) | 아군이 있어도 공격만 하던 수정 전 기록과 복제·지휘·스턴 랜서 후속 공격을 한 수정 후 기록 |
| [Field06](#field06) | CAST, VERSION, POISON. 최초 커서 기술 시험은 이동 경로를 생성하는 진입점을 건너뛰어 중단됐다. Field06에서 게임의 실제 사용 가능 행동 경로로 재검사해 세 기술이 모두 발동했다. |
| [Field08](#field08) | SHADOWSET, SHADOW, ROLE, ACT. 사냥꾼·워록 전체 순서와 암살자 이동 좌표. 알림으로 대기한 시간이 있어 이 실행은 다섯 역할 시험 후 종료됐다. |
| [Field09](#field09) | SETTINGS, MONTH, NATIVE, REG, CARDREG, CHOICE, COMMIT, GEAR, POOL, ODDS, BT, BEFORE, ACT, GOLD, FINISHED |
| [Field10](#field10) · [Field12](#field12) | 최종 배포본의 MONTH, NATIVE, REG, CHOICE, GEAR, ODDS, BASHARITEM, PANIC, SHADOW, BLOCKSOURCE, PLACED, BLOCKTILE. 실제 뮤톤 인벤토리 및 공황·제압·착지 봉쇄 조건을 확인. |

최종 전투 로그에 사냥꾼 M3의 회전 애니메이션 `NO_TurnLeft180` 재생 경고가 있다. 같은 시험의 상태·행동 검사는 끝까지 완료됐다. 해당 연출을 제공하는 콘텐츠와 평상시 캠페인에서의 외형은 미확인이다. [Field12](#field12)

## 56개 카드와 세 버튼

원본 등록 순서다. 각 칸은 게임의 영문 버튼 이름과 실제로 추가하는 본부 태그 또는 병사 해금을 표시한다. 모든 항목에 대해 원본 소비처를 찾고, 전설 시험에서 독립적으로 버튼 콜백을 실행했다. 각 능력의 피해 수치·연출까지 관찰한 사례는 앞의 검증 표에 따로 기재했다.

| 카드 식별자 | 월 조건 | 첫 번째 버튼 | 두 번째 버튼 | 세 번째 버튼 |
|---|---|---|---|---|
| `YMTriParteThirtySeven` | 6개월부터 | Democracy Protects · `ARFMPYP_DemocracyProtects` | Democractic Liberators · `ARFMPYP_DemocracyLiberates` | Democracy Unifies All · `ARFMPYP_DemocracyUnifies` |
| `YMTriParteThirtySix` | 3개월부터 | Pinpoint Accuracy · `ARFMPYP_Pinpoint` | Stubborn As A Mule · `ARFMPYP_StubbornMule` | Slicker Than Oil · `ARFMPYP_SlickerThanOil` |
| `YMTriParteThirtyFive` | 3개월부터 | Tougher Than A Brick Outhouse · `ARFMPYP_ShieldbearerArmor` | The Sectoid Needs No Pants · `ARFMPYP_SectoidFortress` | Stationary Tyrants · `ARFMPYP_StationaryTyrants` |
| `YMTriParteThirtyFour` | 4개월부터 | Prima Mentalis · `ARFMPYP_PsiCaptains` | Tyranny In Motion · `ARFMPYP_PsiLancers` | The Cult Of Noon · `ARFMPYP_PsiBearers` |
| `YMTriParteThirtyThree` | 3개월부터 | Nineties Blues · `ARFMPYP_NinetiesBlues` | With A Whiff Of Grapeshot · `ARFMPYP_CaptainGrapeshot` | Anyway, I Started Blasting · `ARFMPYP_StartedBlasting` |
| `YMTriParteThirtyTwo` | 3개월부터 | Motivational Executions · `ARFMPYP_MotivationalExecutions` | Revenge Of The Pudding Empire · `ARFMPYP_PuddingEmpire` | Massive Day For The Unemployed · `ARFMPYP_MassiveDay` |
| `YMTriParteThirtyOne` | 3개월부터 | Sectoid Tea Party · `ARFMPYP_SectoidTeaParty` | Snake Oilers · `ARFMPYP_SnakeOilers` | Boxing Bugs · `ARFMPYP_LiddyBoxing` |
| `YMTriParteThirty` | 3개월부터 | Police Brutality · `ARFMPYP_PoliceBrutality` | Salt And Pepper · `ARFMPYP_SaltAndPepper` | Silly Little Bleeder · `ARFMPYP_SillyLittleBleeder` |
| `YMTriParteTwentyNine` | 4개월부터 | Date Time Error · `ARFMPYP_TimeWar` | Moving Different · `ARFMPYP_AvoidSnipes` | That's No Ordinary Rabbit · `ARFMPYP_NoOrdinaryRabbit` |
| `YMTriParteTwentyEight` | 4개월부터 | Codex Vexari · `ARFMPYP_CodexSadness` | Unwilling Sacrifices · `ARFMPYP_ViperShields` | Indomitable Force · `ARFMPYP_IndomitableForce` |
| `YMTriParteTwentySeven` | 3개월부터 | Deadly Memes · `ARFMPYP_Soulfuse` | Paynonets · `ARFMPYP_Paynonets` | Ghost Signal · `ARFMPYP_GhostSignal` |
| `YMTriParteTwentySix` | 12개월부터 | Elite Bashars · `ARFMPYP_EliteBashars` | Unique Bashars · `ARFMPYP_UniqueBashars` | Mundane Bashars · `ARFMPYP_MundaneBashars` |
| `YMTriParteTwentyFive` | 2개월부터 | We Got The Rockets · `ARFMPYP_WeGotTheRockets` | Bedlam Blasting · `ARFMPYP_BedlamBlasting` | Nightmare Fuel · `ARFMPYP_NightmareFuel` |
| `YMTriParteTwentyFour` | 5개월부터 | Trauma Amplifiers · `ARFMPYP_PainTrain` | High Caliber · `ARFMPYP_HighCaliber` | Will To Survive · `ARFMPYP_WillToSurvive` |
| `YMTriParteTwentyThree` | 2개월부터 | Suffer Not The Heretic · `ARFMPYP_HereticBane` | Purge The Betrayers · `ARFMPYP_BetrayerBane` | Cleanse The Unclean · `ARFMPYP_UnbelieverBane` |
| `YMTriParteTwentyTwo` | 6개월부터 | Juggernauts · `ARFMPYP_Dreadnaughts` | Spinebreakers · `ARFMPYP_Spinebreakers` | Absolutely Critical · `ARFMPYP_AdventCrits` |
| `YMTriParteTwentyOne` | 4개월부터 | Edge of Mind · `ARFMPYP_EdgeOfMind` | Pyres of Dawn · `ARFMPYP_PyresOfDawn` | Grail Curse · `ARFMPYP_GrailCurse` |
| `YMTriParteTwenty` | 6개월부터 | Lightning Storms · `ARFMPYP_StunningField` | Blinding Detonations · `ARFMPYP_BlindingRockets` | Battle Premonitions · `ARFMPYP_ArchonSteroid` |
| `YMTriParteNineteen` | 3개월부터 | Beagle Busting · `ARFMPYP_Beaglebusting` | Battle Born · `ARFMPYP_Battleborn` | Holy Warriors · `ARFMPYP_Battlehaunt` |
| `YMTriParteEighteen` | 3개월부터 | Drone Overlords · `PYPDroneOverlordsUnlock` | Chemical Pinions · `ARFMPYP_ChemicalPinions` | Soul Pyres · `ARFMPYP_SoulPyres` |
| `YMTriParteSeventeen` | 4개월부터 | Deep Penetration · `ARFMPYP_DeepPenetration` | Back Breakers · `ARFMPYP_BackBreakers` | Bewildering Shocks · `ARFMPYP_BewilderingShocks` |
| `YMTriParteSixteen` | 5개월부터 | Death Curse · `ARFMPYP_DeathCurse` | Summary Execution · `PYPExecutionUnlock` | Marked For Death · `PYPMarkedForDeathUnlock` |
| `YMSectopodEmpowerment` | 6개월부터 | Advanced Algorithms · `ARFMPYP_SectopodGymrats` | Predictive Targeting · `ARFMPYP_SectopodMania` | Vital Tracking · `ARFMPYP_SectopodShoes` |
| `YMSpectreEmpowerment` | 5개월부터 | The Fifth Eye Curse · `ARFMPYP_SpectreFifthEye` | Enigmatic Engineering · `ARFMPYP_SpectreRegen` | Dark Embrace · `ARFMPYP_DarkEmbrace` |
| `YMAndromedonEmpowerment` | 5개월부터 | Biohazard Blitz · `ARFMPYP_BlindingAcid` | Crushing Momentum · `ARFMPYP_StunningStrikes` | Warp Beacons · `ARFMPYP_AndromedonWarpBeacon` |
| `YMPurifierEmpowerment` | 5개월부터 | Chemicals Of Terror · `ARFMPYP_SpookyFlame` | Haber's Legacy · `ARFMPYP_CripplingFlame` | Deadly Haze · `ARFMPYP_RuinousFlame` |
| `YMTriParteFifteen` | 5개월부터 | Haunting Presence · `ARFMPYP_SpectreTeleport` | Super Sectoids · `ARFMPYP_SuperSectoids` | Oppression · `ARFMPYP_MutonSuppressionShot` |
| `YMTriParteFourteen` | 7개월부터 | Solid Sectopods · `ARFMPYP_SolidSectopod` | Super Shells · `ARFMPYP_GatekeeperSupershell` | Reinforced Plating · `ARFMPYP_AndromedonPlating` |
| `YMTriParteThirteen` | 4개월부터 | Purification Planning · `ARFMPYP_PurifierUnicorn` | Seventh Sense · `ARFMPYP_MutonTapdancer` | Close Quarters Combat · `ARFMPYP_Stunmancy` |
| `YMTriParteTwelve` | 7개월부터 | Atomizer Beams · `ARFMDESW_CHAGatekeeperGirlboss` | Hypertoxicitiy · `ARFMPYP_MurderDrool` | Juggernautical · `ARFMPYP_Zerkernaut` |
| `YMTriParteEleven` | 3개월부터 | Defensive Tactics · `ARFMDESW_CHAMutonReposition` | Lethal Coils · `ARFMDESW_CHASnekSnuggles` | Necromantic Rituals · `ARFMPYP_ZombieRoids` |
| `YMTriParteTen` | 5개월부터 | Spectre Troubles · `ARFMDESW_CHASpectreTrouble` | Elite Combatants · `ARFMDESW_CHAAndromedonGigachad` | Enhanced Warframes · `ARFMDESW_CHAEnhancedWarframes` |
| `YMTriParteNine` | 7개월부터 | Twin Chambers · `ARFMPYP_AndromedonDoubleTap` | Awaken My Masters · `ARFMDESW_CHAAwakenMyPoddies` | The New Breed · `ARFMDESW_CHALiddyRoids` |
| `YMTriParteEight` | 5개월부터 | Restoration Protocols · `ARFMDESW_CHARestorationProtocols` | Unchecked Brutality · `ARFMDESW_CHAMutonBrutal` | Barrage Protocols · `ARFMDESW_CHASuperArchons` |
| `YMTriParteSeven` | 5개월부터 | Safety Protocols · `ARFMDESW_CHASafetyProtocols` | Priority Targeting · `ARFMDESW_CHAPriorityTargeting` | Advanced Training · `ARFMDESW_CHAAdvancedTraining` |
| `YMTriParteSix` | 5개월부터 | Warsteel Alloys · `ARFMDESW_CHARoboArmor` | Armor Sealing · `ARFMDESW_CHAAlienSealedArmor` | Psychic Shielding · `ARFMDESW_CHAPsychicScreens` |
| `YMTriParteFive` | 5개월부터 | Advanced Tactical Processors · `ARFMDESW_CHARoboMadness` | Smart Munitions · `ARFMDESW_CHAWoodpecker` | Network Repairs · `ARFMDESW_CHANetworkRepairs` |
| `YMTriParteFour` | 4개월부터 | Blood Frenzy · `ARFMDESW_CHAArchonTurbo` | Tactical Analysis · `ARFMDESW_CHATacticalAnal` | Advanced Melee Combat Training · `ARFMDESW_CHAStunlancerCounter` |
| `YMTriParteThree` | 4개월부터 | Slippery Stalkers · `ARFMDESW_CHASlipperyStalkers` | Biological Augmentation · `ARFMDESW_CHAFacelessJelly` | Blast Resistant Skin · `ARFMDESW_CHAMutonSkin` |
| `YMTriParteTwo` | 4개월부터 | Power Through Faith · `ARFMDESW_CHAPriestProtein` | ICE Protocols · `ARFMDESW_CHAICEProtocols` | Close Quarters Combat · `ARFMDESW_CHAMutonCQC` |
| `YMTriParteOne` | 4개월부터 | Deep Cover Protocols · `ARFMDESW_CHATroopyFace` | Incineration Pods · `ARFMDESW_CHAIncinerationPods` | Adaptive Musculature · `ARFMDESW_CHASpeedyGonzales` |
| `YMTrooperGrenades` | 2개월부터 | Plasma Grenades · `ARFMPYP_TrooperPlasmaGrenade` | Gas Grenades · `ARFMPYP_TrooperGasGrenade` | Acid Grenades · `ARFMPYP_TrooperAcidGrenade` |
| `YMStunlancerGrenades` | 2개월부터 | Plasma Grenades · `ARFMPYP_StunlancerPlasmaGrenade` | Gas Grenades · `ARFMPYP_StunlancerGasGrenade` | Acid Grenades · `ARFMPYP_StunlancerAcidGrenade` |
| `YMShieldbearerMindLink` | 0~3개월 | Mind Link - Perception · `ARFMPYP_ShieldbearerPerceptionLink` | Mind Link - Precision · `ARFMPYP_ShieldbearerPrecisionLink` | Mind Link - Tactics · `ARFMPYP_ShieldbearerTacticLink` |
| `YMLancerMindLink` | 0~3개월 | Mind Link - Perception · `ARFMPYP_LancerPerceptionLink` | Mind Link - Precision · `ARFMPYP_LancerPrecisionLink` | Mind Link - Tactics · `ARFMPYP_LancerTacticLink` |
| `YMPriestMindLink` | 0~3개월 | Mind Link - Perception · `ARFMPYP_PriestPerceptionLink` | Mind Link - Precision · `ARFMPYP_PriestPrecisionLink` | Mind Link - Tactics · `ARFMPYP_PriestTacticLink` |
| `YMOfficerMindLink` | 0~3개월 | Mind Link - Perception · `ARFMPYP_OfficerPerceptionLink` | Mind Link - Precision · `ARFMPYP_OfficerPrecisionLink` | Mind Link - Tactics · `ARFMPYP_OfficerTacticLink` |
| `YMTrooperMindLink` | 0~3개월 | Mind Link - Perception · `ARFMPYP_TrooperPerceptionLink` | Mind Link - Precision · `ARFMPYP_TrooperPrecisionLink` | Mind Link - Tactics · `ARFMPYP_TrooperTacticLink` |
| `YMMECEnhancement` | 0~3개월 | Shaped Detonations · `ARFMPYP_MacroMissiles` | Terrain Mapping · `ARFMPYP_TerrainMapping` | Alloyed Armor · `ARFMPYP_MECArmor` |
| `YMMutonEnhancement` | 0~3개월 | Heavy Hitters · `ARFMPYP_HitterMuton` | Brutalist Strength · `ARFMPYP_BrutalistMuton` | Hyper Reactive · `ARFMPYP_ReactiveMuton` |
| `YMPriestEnhancement` | 0~3개월 | Void Priests · `ARFMPYP_VoidPriest` | Battle Priests · `ARFMPYP_BattlePriest` | Umbra Priests · `ARFMPYP_UmbraPriest` |
| `YMOfficerEnhancement` | 0~3개월 | Defensive Tactics · `ARFMPYP_OfficerDefense` | Acceleration Chambers · `ARFMPYP_OfficerDamage` | Smart Scopes · `ARFMPYP_OfficerAim` |
| `YMTrooperEnhancement` | 0~3개월 | Defensive Tactics · `ARFMPYP_TrooperDefense` | Acceleration Chambers · `ARFMPYP_TrooperDamage` | Smart Scopes · `ARFMPYP_TrooperAim` |
| `YMSectoidEnhancement` | 0~3개월 | Mnemonics · `ARFMPYP_SectoidPsi` | Amplifiers · `ARFMPYP_SectoidDamage` | Calibration · `ARFMPYP_SectoidAim` |
| `YMStunlancerEnhancement` | 0~3개월 | Defensive Tactics · `ARFMPYP_StunlancerDefense` | Vanguards · `ARFMPYP_StunlancerMove` | Eagle Eyes · `ARFMPYP_StunlancerAim` |
| `YMPurifierEnhancement` | 0~3개월 | Cranial Reinforcement · `ARFMPYP_PurifierCranialReinforcement` | Regeneratives · `ARFMPYP_PurifierRegeneration` | Armor · `ARFMPYP_PurifierArmor` |

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
