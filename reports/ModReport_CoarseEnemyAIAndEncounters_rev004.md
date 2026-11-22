# Enemy AI Fixes rev004 검증 보고서

전설 난이도에서 **위태로운 갈망(That Perilous Yearning)**을 켜면 스턴 랜서의 정신 연결, 어드밴트 병사·장교의 공격력, MEC의 치명타와 정화병의 화염방사기 강화가 선택한 카드에 연결된다. 임무 관리자의 빈 조우 27칸을 복구했고 보급품 임무 세 종류는 경계도 22에서 두 번째 편성을 선택할 수 있다. 카드 버튼 168개를 실제로 눌렀고, 세 카드 조합 748,440건은 원본 코드와 월 조건으로 계산했다.

대상은 Windows Steam판 WotC, LWOTC, Requiem Legion: Coarse Edition(`3555944655`), TPY 제공 모드(`2795578857`), Totally Reasonable Definitely Not Psychotic Tedjam Plugin(`3835619377`)이다. 사용 중인 구성에서 읽어 온 모드 390개와 이번 수정본·시험 도구를 격리한 사본에서 실행했다. 게임에 넣을 폴더는 [rev004/CoarseEnemyAIAndEncounters](../rev004/CoarseEnemyAIAndEncounters) 하나다. 모드 식별자가 같은 rev001~003과 교체해 사용한다.

검증 때 촬영한 선택 화면 56장과 모음 4장은 아래 카드에서 열 수 있다. 병력표와 일정을 모두 출력한 실행 세 건은 따로 보관했다. [캠페인 A의 표](evidence/rev004/tables/CampaignA/) · [캠페인 B의 표](evidence/rev004/tables/CampaignB/) · [두 선택 조합 시험의 표](evidence/rev004/tables/Pairs01/)

## 수정한 동작과 원본 근거

아래 코드 파일은 별도 표시가 없는 경우 모드 폴더의 `Src/CoarseEnemyAIAndEncounters/Classes`에 있다. 카드명·툴팁은 원본 `Localization/ARFMDarkEvents.int`의 `ARFMYearningTemplate` 56개, 버튼 순서와 결과는 `ARFM_SE_YearningMutators.uc`, 능력·장비·효과는 원본 배포 소스와 대조했다. 판정 기준은 모더가 공개한 설명, 해당 설명에 연결된 선택 함수, 전술에서 값을 소비하는 코드다. 세 근거가 일치하지 않으면 어떤 쪽을 따랐는지 아래에 적었다. Coarse의 `Localization/XComGame.int`에는 요새 추가 후보인 Legate·메카피드·Berserker Magna·Incubator Magna·Heavy Mechtoid·사이버디스크 6개 템플릿의 영문 항목이 모두 있다. Tedjam의 `TotallyNotPsychoGoldenPath.int`에 있는 ZERO SANITY 설명도 원본 `PostEncounterCreation / AddZeroSanitySecondWaveOptions` 적용 분기와 대조했다.

| 선택 또는 임무 | 확인한 차이와 rev004 동작 | 확인할 파일 |
|---|---|---|
| 스턴 랜서 정신 연결 3종 | 선택 태그와 능력은 `Lancer…Link`인데 유닛이 등록되지 않은 `Stunlancer…Link`를 받고 있었다. 세 능력을 실제 이름으로 지급한다. 유효한 다른 모드 능력은 보존한다. | `CoarseYearningCardEffects.GrantCardPassives / GrantLancerLink` |
| 병사·장교 가속 체임버, MEC 대구경 | 효과 템플릿만 존재해 지급이 빠졌던 유닛에 능력을 연결한다. MEC의 일반·측면 치명타 보정은 원본 설정 `HighCaliberCrit / HighCaliberFlankingCrit`에 따라 일반 공격은 치명타 확률 +40%p, 측면 공격은 +80%p다(원본 기본값). | `CoarseYearningCardEffects`, `X2Effect_CoarseHighCaliber` |
| 우리에게는 로켓이 있다 / 대혼란 폭발 / 악몽의 연료 | 로켓과 마이크로 미사일, 외계인 수류탄, 정화병 화염방사기는 각각 해당 선택에서 강화된다. 화염방사기가 두 번째 선택에 잘못 딸려오던 분기를 고쳤고, 일반 MEC도 캐릭터 그룹으로 판별한다. 원본 화염방사기 능력 2개의 원뿔 확대 호출도 확인했다. | `CoarseYearningEquipment.GetTaggedGear`, 원본 `ARFM_Items_Yearning`, `X2DownloadableContentInfo_ARFMDarkEvents` |
| 복싱을 배운 벌레 / 정밀한 조준 | 원본은 방어자 효과를 조회하는 시점에 공격자의 이점을 적용했다. 크리살리드의 근접 빗나감→스침→명중→치명타 한 단계 상승과 해당 장교·정예의 측면 치명타를 공격자 효과에서 판정한다. 반대편이 같은 효과를 소유했다는 이유로 발동하지 않는다. | `X2Effect_CoarseBoxingBugs`, `X2Effect_CoarsePinpoint` |
| 전장 태생 / 저거너트 | 무기에 직접 적힌 관통만 보던 판정을 실제 타격·미리보기의 최종 관통과 남은 방어구로 바꿨다. 남은 방어구가 있고 관통이 그보다 낮을 때만 원본 비율을 적용한다. 방어구 파쇄 상한은 게임의 수치를 따른다. | `CoarseYearningCardEffects.AdjustYearningArmor`, Highlander `TriggerAdjustArmorMitigation` |
| 비글 붕괴 / 성스러운 전사 | 보호막 체력이 있을 때 원본 설정 `BeaglebustingReduction`을 읽는다(기본 −50%). 성전사는 실제 연결이 있는 시전자·수혜자에 한해 감소 효과를 받는다. 연결 해제·재적용, 다른 사제, 예전 저장에 남은 같은 사제의 중복 효과를 구분한다. | `X2Effect_CoarseEnergyShield`, `X2Effect_CoarseHolyWarrior` |
| Democracy 3종 | 영문 설명은 살아 있는 아군과 시야 안의 XCOM 수를 비교한다. 원본은 아군까지 시야 내로 제한했다. 자신·사망·전장 이탈·전술 통제자가 없는 유닛을 아군 수에서 제외하고, 수적 우세일 때 해당 생존·행동력·정신 지배 효과를 적용한다. 정신 지배 보정 대상도 영문 설명에 따라 XCOM으로 제한했다. | `CoarseYearningCardEffects.HasNumericalAdvantage`, `X2Effect_CoarseDemocracy*` |
| 임무 배치와 출현 전력 | 일정 14개에서 번호 93곳, 병력표 선언 7개에서 번호 23곳을 연속 번호로 복원했다. 등장 순서·횟수·좌표·조건 태그를 보존했다. `ARFMAdvOutriderM1`의 두 역전 구간과 ETP 사본을 원본 전력 진행과 이어지는 FL3, FL4 단일 구간으로 복원했다. | `Config/XComSchedules.ini`, `Config/XComEncounterLists.ini` |
| 임무가 참조하는 일정 | `SupplyExtraction_LW`, `BigSupplyExtraction_LW`, `SmashNGrab_LW`가 D22 첫 편성 다음에 등록되지 않은 D23 두 번째 편성을 가리켰다. 해당 위치에 실제 D22 두 번째 편성을 연결했다. 활성 Playable Advent 구성의 `GatherSurvivors`는 전용 PA 일정이 배포되지 않아 유일한 일정이 끊겼다. D1 기본 구출 일정으로 연결하고 맵·목표·강제 상황 보고는 유지한다. 다른 모드가 원래 이름의 편성을 제공하면 해당 참조가 우선한다. | `X2DLCInfo_CoarseEncounters.RepairMissionScheduleReferences` |

어드밴트 기동 지휘관의 FL3·FL4는 앞뒤 전력 구간을 근거로 복원한 값이다. `GatherSurvivors`에서 기본 D1을 쓰는 것은 전용 편성이 배포되지 않은 현재 구성을 위한 호환 처리다. 두 결정에는 모더가 특정 수치를 명시한 영문 설명이 없어 추정과 호환 처리로 구분한다.

## 캠페인과 선택 화면

전설 새 캠페인 세 개에서 원래의 전략 행동으로 화면을 열고 세 캠페인이 서로 다른 버튼을 누르게 했다. 버튼 3개, 제목, 툴팁 3개, 선택 결과의 본부 태그 또는 해금, 선택 횟수 1회, 재선택 차단을 검사했다. 단기간에 모든 카드를 보려고 이 세 캠페인에서는 같은 달에 여러 번 창을 열었다. 3개월 이내 카드 13장을 통상 캠페인 한 회에서 모두 고를 수 있다는 뜻은 아니다.

| 검증 방식 | 재현 조건과 절차 | 기대 | 관찰 | 판정 |
|---|---|---|---|---|
| 실게임 전략 화면 | 전설·TPY로 새 캠페인 3개 → 가능한 카드가 없으면 저항군 월을 증가 → 12개월 이후 바샤르 카드까지 선택 | 56×3개의 버튼이 각각 고유 결과 1개를 남긴다 | 168개 전부 클릭. 본부 태그 165개·해금 3개. 세 캠페인 모두 선택 상태 검사 56/56 | 통과 |
| 실게임 저장·불러오기 | 각 캠페인 28장·56장에서 게임 저장 후 실제 파일을 다시 불러온다 | 난이도·TPY·모든 이전 선택·재등장 차단이 유지된다 | 저장 6회, 불러오기 6회, 복원 후 28·56개 상태 전부 일치 | 통과 |
| 카드 표시와 삽화 | 추가 캠페인에서 56개 창을 열고 각 텍스처를 런타임에 로드한다. 선택 전에 게임 창을 각각 촬영해 세 버튼을 영문 원본과 대조 | 56개 창에서 세 개의 버튼이 영어 원본과 같은 순서로 표시되고 카드 삽화가 조회된다 | 영문 800×500 실측 화면 56/56장, 버튼 168개 표시와 순서 확인. 모든 카드에서 원래 공용 이미지 객체가 로드됐다. 이 최종 패키지 실행에서도 28장·56장 저장·복원 성공 | 통과 |
| 실게임 조합 분기 | 서로 다른 카드만 대상으로 첫 선택을 전략 기록에 제출하고 허용된 다음 달에 두 번째 선택을 독립된 대기 상태에서 적용한 후 폐기한다 | 두 효과 공존, 원래 상태 불변, 해당 선택 외 버튼 꺼짐 | 월 조건을 만족하는 순서 있는 두 선택 23,157/23,157. 순서를 합치면 13,860쌍 전체. 첫 효과 168종 각각 검사 | 통과 |

세 카드 조합은 원본 소스에서도 따로 검사했다. 로그 문구와 결과 식별자를 제외하면 168개 콜백 본문은 두 종류다. 165개는 자기 본부 태그만 한 번 추가하고, 3개는 자기 병사 해금만 한 번 추가한다. 세 해금 템플릿은 구매 시 다른 선택을 지우는 함수를 정의하지 않는다. 이 규칙과 월 상·하한으로 서로 다른 세 카드의 748,440개 버튼 조합(가능한 월 순서 2,936,412개)을 계산해 세 결과의 중복·누락 0건을 확인했다. 이는 본부 기록에 대한 정적 검증이다.

화면 전체와 버튼 확대본은 [1–14](evidence/rev004/screens/Cards_1.png) · [15–28](evidence/rev004/screens/Cards_2.png) · [29–42](evidence/rev004/screens/Cards_3.png) · [43–56](evidence/rev004/screens/Cards_4.png)에서 볼 수 있다. 원본과 같은 Wwise 시작·확정·종료 이벤트 호출을 확인했다. 실제 스피커 청취 및 168개 툴팁의 마우스 오버 장면은 미실행이다.

세 캠페인에서 길이 56의 실제 누적 경로를 따라갔다. 두 선택 조합 시험에서 두 번째 결과는 대기 상태까지 비교했다. 세 선택 이상이 동시에 만나는 모든 경우, 전투 승패·사상자·전리품·월말 자금까지 다른 모든 캠페인의 결과에는 이 숫자를 적용하지 않는다.

## 월간 지급 조건을 거친 18개월 경로

전설 지구본에서 저항군 월 수와 게임의 날짜를 함께 진행했다. 원본의 월말 진화 리스너로 이전 선택의 잠금을 풀고 실제 전력 상승일 검사로 다음 창에 진입했다. 전력 상승일은 연·월·일을 비교하므로 같은 날 한 시간 차이도 허용한다. 전투·기지 건설·연구·월간 경제 전체의 진행 시간은 재현하지 않았다.

| 재현 조건과 절차 | 기대 | 실제 결과 | 판정 |
|---|---|---|---|
| 지구본의 다음 날, 같은 날 한 시간 뒤, 같은 날짜를 차례로 설정. 선택한 달에 한 번 더 제시할 수 있는지 확인 | 날짜가 다르면 차단, 같은 날 허용, 이미 고른 달은 월말 처리 전까지 차단 | 18개월 각각 다른 날짜에서 전부 일치. 첫 선택 이후 연속 17회 이전 달의 잠금 확인 | 통과 |
| 월마다 하나씩 실제 카드를 선택하고 9장·18장에서 저장 후 불러온다. | 앞선 모든 선택·원본 월 상한·전설·TPY 유지 | 2035년 3월 1일~2036년 8월 1일, 총 18장. 9장·18장 상태를 실제 저장과 불러오기 2회씩으로 확인 | 통과 |

첫 실행에서는 첫 진입 안내창이 지구본을 덮었다. 최종 시험은 안내창의 확인 절차를 거쳤으며, 같은 달에 강제로 카드를 여러 번 뽑지 않았다. 월말 이벤트 전체를 방송하는 대신 이 모드가 구독하는 원본 월말 진화 함수를 호출해 다른 전략 이벤트와 분리했다. [18개월 달력·저장 로그](evidence/rev004/Intervals05.txt)

## 병력 출현표와 임무 일정

| 검증 방식 | 재현 조건·기대 | 실제 결과 | 판정 |
|---|---|---|---|
| 선언과 실제 병합 비교 | 각 `+` 선언을 게임 임무 관리자의 배열과 대조. 병력 이름·순서·전력·한도·가중치와 조우 순서·조건 태그·전력·경계 범위를 비교 | 병력표 이름 92개, 선언 2,308개와 병력 항목 13,679개. 일정 이름 835개, 선언 850개와 배치 8,208개. 원래 조우 순서 850/850 유지. 병력 선언 2,308/2,308 일치 | 통과 |
| 다른 모드가 런타임에 추가하는 병력 | LWOTC가 등록되지 않은 유닛을 제거하고 병력표 상한 FL20을 99로 확장한다. TPY는 일정 끝에 조건부 병력을 더한다. 보호표 3개는 `BerserkerOmega` 후보를 보충한다 | 병력 선언 2,305개는 LWOTC 처리 후 일치. 나머지 3개는 원래 행 뒤의 오메가 후보까지 대조. 원본 서리 Technician 증원 가중치 0인 13개 행은 그대로 유지 | 통과 |
| 런타임 참조 | 대상 일정의 리더·부하 목록, 조우·추첨표, 모든 병력 템플릿과 활성 임무의 일정 참조 비교 | rev003의 빈 조우 27칸 → 0, 역전 전력 구간 4개 → 0. 현재 활성 임무 144개의 끊어진 일정 참조 4곳 → 0 | 통과 |
| 실게임 무작위 조우 | 전술 임무, FL20·경계도 8. 최종 요새의 중간 보스·지원·군집 추첨표 7개를 게임의 `GetConfigurableEncounter`로 각 128회 추첨 | 896회 모두 등록된 조우 반환. 각 표에서 서로 다른 결과 2~5종 관찰 | 통과 |

등록된 일정 835개 중 이 구성의 임무 정의가 직접 참조한 이름은 711개다. 나머지 124개에는 다른 임무 구성용 변형이 포함된다. 예를 들어 현재 `RecruitRaid_LW`는 LWOTC의 Extract 계열을 사용한다. 원본에 있는 같은 이름의 복수 선언 15쌍은 공급자·경계도·편성 차이를 기록하고 출현률을 임의로 재설정하지 않았다. 835개 일정을 각각 독립된 전장에서 끝까지 플레이한 수치는 아니다.

Tedjam의 블랙사이트·포지·사이오닉 게이트·방송탑과 요새 증원은 누적본에 포함된다. 이전 검증에서 ZERO SANITY 켬·끔과 일반·Extreme을 비교한 44개 스토리 사례는 [rev002 보고서](ModReport_CoarseEnemyAIAndEncounters_rev002.md)에 있다. 이번 빌드에서 바뀐 임무 참조는 위의 네 곳이다. ZERO SANITY와 TPY는 별개의 세컨드 웨이브다.

## 헌터 M3의 왼쪽 180도 회전 경고

rev003 실행에서 출력된 경고 원문은 `UXComAnimTreeController::PlayFullBodyDynamicAnim - Can't play animation NO_TurnLeft180 on pawn type ARC_GameUnit_ChosenHunter_M3`다. 게임 실행 파일과 WotC SDK를 대조하면, 전신 애니메이션이 허용되고 별도 자세(포즈) 덮어쓰기를 사용하지 않는 상태에서 요청 이름으로 고른 시퀀스가 당시 메시에서 조회되지 않을 때 이 경고가 나온다. 그 시점의 재생 가능 여부를 검사하는 함수는 `XComAnimTreeController.CanPlayAnimation`이다. 전투 AI가 회전할 방향을 결정하는 단계는 이미 지난 뒤다.

| 재현 조건 | 실행한 검사 | 실측 |
|---|---|---|
| `ChosenSniperM3`, 기본 `ChosenSniperRifle_BM` | 실제 메시에서 왼쪽·오른쪽 180도 및 왼쪽 90도 조회. 왼쪽 180도 전신 재생 요청 | 세 시퀀스를 찾았고 전신 재생 노드를 반환 |
| 같은 유닛, `YearningHunterBoltThrowerM3` | 외형·장비를 실제 교환한 후 같은 요청 | 재생 가능 참, 재생 노드 반환 |
| 같은 유닛, `YearningHunterBeamSniperM3` | 다른 TPY 주 무기 및 보조 무기로 교환한 후 같은 요청 | 재생 가능 참, 재생 노드 반환 |
| 실제 외계인 팀(`16`)에 생성한 M3, TPY가 자동 지급한 `YearningHunterBeamSniper` 기본형 | 공용 세트를 조작하기 전에 생성 직후의 메시·세트·재생 가능 여부와 실제 재생 요청을 기록 | 메시 외형은 M3였지만 붙은 세트는 `Advent_ANIM.Anims.AS_Advent` 하나뿐. 왼쪽 180도뿐 아니라 오른쪽 180도·왼쪽 90도도 조회되지 않았다. `CanPlayAnimation=False`이고 rev003과 같은 경고가 발생. 이후 M3 무기를 다시 갖춘 시점에는 공용 세트가 붙어 회복 |

정상 재생된 세 무기에서 왼쪽 회전을 공급한 객체 경로는 모두 `Chosen_ANIM.Anims.AS_Chosen:AnimSequence_46`였다. 헌터 전용 `Hunter_ANIM.Anims.AS_Hunter`에는 이 이름이 없지만, 정상적인 M3 메시에는 공용 세트와 전용 세트가 함께 붙는다. WotC 실행 파일 SHA-256은 `d830aad0bdc5aea35e3a62f51cbd7f0c22b4d297ac3c02cdea37a746fde110ae`이다. 경고 참조 위치 RVA `0xB5F16A`, 재생 가능 검사 RVA `0xB31D10`에서 이름 검색과 허용 상태를 확인했다. rev003 경고 순간의 메시·애니메이션 세트 목록은 남아 있지 않아 당시의 세트 교체 주체까지 특정할 수는 없다. 요청에 따라 헌터의 에셋·애니메이션·회전 코드는 수정 항목에서 제외했다.

격리 전투에서 `AS_Chosen`만 잠시 제외하고 같은 요청을 보냈다. 시퀀스 조회는 `None`, 재생 가능은 `False`가 되었고 rev003과 동일한 경고가 한 번 발생했다. 세트를 복원하자 즉시 `AS_Chosen:AnimSequence_46`과 `True`가 돌아왔다. 실패 조건에서도 엔진이 재생 노드 객체를 반환했으므로 노드 반환값만으로는 정상 회전을 판정할 수 없다. 이 실험은 턴 처리 중 실행한 시험 조작이며 배포본에 들어가지 않는다. [기본·TPY 무기](evidence/rev004/Field02.txt) · [공용 세트 제외·복원](evidence/rev004/Field03.txt) · [외계인 팀 자동 지급 직후](evidence/rev004/Field05.txt)

별도 외계인 헌터는 자동 지급된 `YearningHunterBoltThrower`를 전투 내내 그대로 들고 있었다. 실행 로그 157.92~163.93초에는 공용 어드밴트 세트 1개만 붙었고, 167.48초에는 장비 교환 없이 선택받은 자 세트를 포함한 7개로 바뀌며 회전 시퀀스가 조회됐다. 자동 지급된 빔 저격총 기본형과 수동 장착한 M3 빔 저격총은 원본의 같은 `WP_ChosenMagnaBeamSniperRifle` 외형을 쓴다. 따라서 이 구성에서 재현한 원인은 **헌터 생성 직후 임시 어드밴트 세트가 아직 선택받은 자 세트로 교체되지 않은 시점의 회전 요청**이다. rev003에서 바로 그 교체를 촉발한 개별 이벤트는 기록에 남지 않았다. [장비를 유지한 대조군](evidence/rev004/Field06.txt)

## 전술·연출 재현

| 검증 방식 | 재현 조건·기대 | 실제 결과 | 판정 |
|---|---|---|---|
| 게임의 실제 선택 가능 판정 | 모든 일정에서 FL·경계도 양 끝, 각 범위 바로 밖, 임무 허용 목록에서 제외한 경우를 `ValidateMissionSchedule`로 비교 | 활성 구성 고유 일정 1,207개 × 7 = 8,449회 일치. 이 모드가 다룬 835개 × 7 = 5,845회 포함 | 통과 |
| 전설 전술 유닛 | 정신 연결을 선택한 스턴 랜서, 공격력 강화 장교·병사, 대구경 MEC를 생성 | 랜서에 실제 능력과 `ARFMPrecisionLink` 효과 확인. 장교·병사·MEC에도 능력 상태가 생성됨 | 통과 |
| 근접 판정 | 생성한 크리살리드의 `ChryssalidSlash` 빗나감을 실제 공격자·방어자 효과 함수에 전달 | 공격자는 스침으로 1단계 상승. 방어자 쪽은 빗나감 그대로 | 통과 |
| 방어구와 관통 | 전장 태생 뮤톤에게 기본 피해 10, 방어구 2, 관통 0/1/2/3을 차례로 넣어 등록된 Highlander 피해 콜백 호출 | 반감으로 줄인 5에 유효 방어구 2 또는 1을 더해 최소 감소치 7/6. 관통 2/3에서는 추가 최소 감소치 0/0 | 통과 |
| 장비 선택 | 정화병·뮤톤·MEC·병사에게 세 선택을 따로 전달해 지급 장비 조회 | 정화병+악몽의 연료만 화염 확장기, 뮤톤+대혼란 폭발은 수류탄 확장기. 로켓 선택 시 MEC는 로켓 확장기, 일반 병사는 빈 결과 | 통과 |
| 치명타와 보호막 경계 | 전설에서 실제 대구경 효과의 일반·측면 치명타 보정과 실제 `EnergyShield` 효과의 보호막 체력 0·2를 비교. 피해 10 | 치명타 +40/+80. 보호막이 없으면 피해 보정 0, 보호막 체력 2에서는 −5 | 통과 |
| 성전사 수혜자 재연결 | 외계인 사제·병사를 같은 팀으로 생성하고 M1 원본 능력의 두 효과를 적용한 뒤 실제 연결을 제거한다. 같은 사제로 한 차례 반복 | 피해 10에 연결 시 −5, 해제 시 0을 두 번 확인. 재시전 때 같은 수혜자 표식은 `AA_DuplicateEffectIgnored`, 표식 객체 하나 유지 | 통과 |
| 성전사 정상 시전과 해제 | 전설 외계인 사제에게 행동력을 주고 유효한 아군을 사거리 안에 둔 뒤 원본 `HolyWarriorM1`을 능력 사용 경로로 시전. 실제 링크 제거·재연결 후 양측 피해를 비교 | 행동력 부족 및 사거리 밖에서는 각각 차단. 유효한 상황은 `AA_Success`와 실제 시전 성공, 원본 재사용 대기 진입. 피해 10에서 사제·수혜자 모두 연결 중 −5, 해제 후 0을 두 차례 확인. [정상 시전 로그](evidence/rev004/Field07.txt) | 통과 |
| 미실행 전술 조합 | 카드별로 영향받는 적·지형·무장·표적·거리·은폐·상태이상·사망 시점을 바꿔 실제 전투 완료 | 직접 실행한 상황은 이 표와 헌터 항목에 기재했다. 나머지 개별 피격·사망·전리품·음향과 세 선택 이상 조합의 전체 전투 연출은 미실행 | 미실행 |

선택받은 자 능력·무기 강화와 바샤르 3개 선택도 위 168개 캠페인 버튼 및 조합 검사에 들어 있다. rev003에서 재현한 복제·지휘·추적, 표적 없음·재사용 대기 분기, 바샤르 강화군 추첨과 장비 지급의 자세한 전술 결과는 [rev003 보고서](ModReport_CoarseEnemyAIAndEncounters_rev003.md)에 있다. rev004의 새로운 전술 실측은 위 표와 헌터 항목에 기재했다.

## 재현 환경과 배포 확인

1. rev004 폴더 하나를 활성화하고 Coarse Edition·LWOTC·2795578857·Tedjam 및 의존 모드를 함께 사용한다. 시험에서는 일반 Requiem Legion 판을 추가하지 않았다. WotC 실행 빌드 8917, Highlander 본체·Core·Engine·`XComGame`·`DLC_2` 모두 실제 실행 로그에서 v1.32.0 (`1cba26`)을 확인했다.
2. 새 전설 캠페인에서 위태로운 갈망을 켠다. 선택 창에서 아래 표의 버튼을 누르고 본부 태그·해금과 이전 선택을 확인한다. 기간 제한은 저항군 월 수 기준이며 3개월 상한을 포함한다. 12개월 이후에는 바샤르 카드를 시험할 수 있다.
3. 일정은 임무 관리자의 최종 배열에서 이름과 배치를 읽고 대상 임무의 허용 목록에 포함한 뒤 전력·경계도 경계를 조절한다. 전술에서는 선택을 받은 병력의 인벤토리·능력·효과를 읽고, 헌터는 같은 전장에서 장비만 바꿔 왼쪽 180도 회전을 호출한다.
4. 배포본 37개 파일을 열어 검증 후보와 SHA-256을 대조했다. rev003의 28개 파일을 포함하며 9개 소스 파일을 추가했다. 총 변경 파일은 15개다. SDK 최종 빌드 스크립트 오류 0·경고 0. 같은 시각 시험 게임이 실행되어 있었으므로 SDK 실행 로그에는 디버그 소켓과 셰이더 캐시 저장에 관한 별도 경고가 있다. 게임이 읽는 `XComEngine.ini`에 패키지가 등록돼 있고, 실제 로드된 동작은 새 효과·일정 복구 및 런타임 함수 반환값으로 확인했다. 활성 모드 인벤토리 기준으로 수정 패키지와 `ARFMDarkEvents.u`의 공급자는 각각 한 곳이었다. 최종 배포 `Script/CoarseEnemyAIAndEncounters.u` SHA-256은 `3ca0d1cac14d99d19226f716a8e1f2f7f99b34f3bbaaff09147856d708d9ae89`이다. 검증 도구는 배포본에 포함하지 않는다.

세 누적 캠페인·조합을 실행한 후보와 최종 빌드 사이에는 성전사 재연결 시 중복 감소를 막는 보완이 있었다. 선택 화면·저장 형식·조합 처리·편성 설정 파일은 동일하다. 최종 패키지로도 별도의 전략·전술 시험을 실행했다.

[SDK 빌드](evidence/rev004/Release05.txt) · [캠페인 A](evidence/rev004/CampaignA.txt) · [캠페인 B](evidence/rev004/CampaignB.txt) · [캠페인 C](evidence/rev004/CampaignC.txt) · [두 선택 조합](evidence/rev004/Pairs01.txt) · [전투·일정 경계](evidence/rev004/Field02.txt) · [외계인 사제 연결](evidence/rev004/Field05.txt) · [행동력 복원·대조군](evidence/rev004/Field06.txt) · [선택 화면](evidence/rev004/Visual01.txt)

## 남은 확인 사항

선택 창의 음향 청취와 168개 툴팁의 마우스 오버 장면은 미실행이다. 같은 카드의 영문 화면에서 각 버튼 위에 커서를 놓고 소리와 설명을 대조하면 된다. 헌터의 회전 경고는 생성 직후 임시 애니메이션 세트에서 재현했다. 당시 rev003에서 세트를 교체한 개별 이벤트의 기록은 없어 원인은 rev004에서 재현한 조건까지로 한정한다.

## 56개 카드와 168개 결과

카드 식별자를 누르면 해당 시험의 영문 화면이 열린다. 아래 세 칸은 `ARFMDarkEvents.kor`의 한국어 버튼 이름, 촬영 당시의 영문 이름, 저장된 태그 또는 해금 순이다. 같은 카드 섹션의 `+ChoiceOne`·`+ChoiceTwo`·`+ChoiceThree`를 대조했으며, 전설 캠페인 세 개에 걸쳐 168개 버튼을 각각 한 번씩 직접 눌렀다.

| 카드 화면 | 저항군 월 | 첫째 | 둘째 | 셋째 |
|---|---|---|---|---|
| [YMTriParteThirtySeven](evidence/rev004/screens/TPY_YMTriParteThirtySeven.png) | 6개월부터 | 민주주의의 수호 (Democracy Protects) · `ARFMPYP_DemocracyProtects` | 민주주의의 해방자들 (Democractic Liberators) · `ARFMPYP_DemocracyLiberates` | 민주주의는 모두를 통합하리라 (Democracy Unifies All) · `ARFMPYP_DemocracyUnifies` |
| [YMTriParteThirtySix](evidence/rev004/screens/TPY_YMTriParteThirtySix.png) | 3개월부터 | 정밀한 조준 (Pinpoint Accuracy) · `ARFMPYP_Pinpoint` | 무식한 맷집 (Stubborn As A Mule) · `ARFMPYP_StubbornMule` | 기름칠한 듯한 움직임 (Slicker Than Oil) · `ARFMPYP_SlickerThanOil` |
| [YMTriParteThirtyFive](evidence/rev004/screens/TPY_YMTriParteThirtyFive.png) | 3개월부터 | 화장실 벽돌보다 단단함 (Tougher Than A Brick Outhouse) · `ARFMPYP_ShieldbearerArmor` | 섹토이드에게는 바지가 필요하지 않다 (The Sectoid Needs No Pants) · `ARFMPYP_SectoidFortress` | 부동의 폭군 (Stationary Tyrants) · `ARFMPYP_StationaryTyrants` |
| [YMTriParteThirtyFour](evidence/rev004/screens/TPY_YMTriParteThirtyFour.png) | 4개월부터 | 지휘관의 정신력 (Prima Mentalis) · `ARFMPYP_PsiCaptains` | 움직이는 폭정 (Tyranny In Motion) · `ARFMPYP_PsiLancers` | 정오의 교단 (The Cult Of Noon) · `ARFMPYP_PsiBearers` |
| [YMTriParteThirtyThree](evidence/rev004/screens/TPY_YMTriParteThirtyThree.png) | 3개월부터 | 90년대의 블루스 (Nineties Blues) · `ARFMPYP_NinetiesBlues` | 포도탄의 향기와 함께 (With A Whiff Of Grapeshot) · `ARFMPYP_CaptainGrapeshot` | 어쨌든, 나는 쏘기 시작했다 (Anyway, I Started Blasting) · `ARFMPYP_StartedBlasting` |
| [YMTriParteThirtyTwo](evidence/rev004/screens/TPY_YMTriParteThirtyTwo.png) | 3개월부터 | 의욕을 고취시키는 처형 (Motivational Executions) · `ARFMPYP_MotivationalExecutions` | 푸딩 제국의 복수 (Revenge Of The Pudding Empire) · `ARFMPYP_PuddingEmpire` | 실업자들의 전성시대 (Massive Day For The Unemployed) · `ARFMPYP_MassiveDay` |
| [YMTriParteThirtyOne](evidence/rev004/screens/TPY_YMTriParteThirtyOne.png) | 3개월부터 | 섹토이드의 다과회 (Sectoid Tea Party) · `ARFMPYP_SectoidTeaParty` | 기름을 두른 뱀 (Snake Oilers) · `ARFMPYP_SnakeOilers` | 복싱을 배운 벌레 (Boxing Bugs) · `ARFMPYP_LiddyBoxing` |
| [YMTriParteThirty](evidence/rev004/screens/TPY_YMTriParteThirty.png) | 3개월부터 | 잔혹한 경찰 (Police Brutality) · `ARFMPYP_PoliceBrutality` | 소금과 후추 (Salt And Pepper) · `ARFMPYP_SaltAndPepper` | 작고 어리석은 놈 (Silly Little Bleeder) · `ARFMPYP_SillyLittleBleeder` |
| [YMTriParteTwentyNine](evidence/rev004/screens/TPY_YMTriParteTwentyNine.png) | 4개월부터 | 시간의 오류 (Date Time Error) · `ARFMPYP_TimeWar` | 이질적인 움직임 (Moving Different) · `ARFMPYP_AvoidSnipes` | 평범한 놈이 아니다 (That's No Ordinary Rabbit) · `ARFMPYP_NoOrdinaryRabbit` |
| [YMTriParteTwentyEight](evidence/rev004/screens/TPY_YMTriParteTwentyEight.png) | 4개월부터 | 고난의 코덱스 (Codex Vexari) · `ARFMPYP_CodexSadness` | 원치 않는 희생 (Unwilling Sacrifices) · `ARFMPYP_ViperShields` | 무적의 힘 (Indomitable Force) · `ARFMPYP_IndomitableForce` |
| [YMTriParteTwentySeven](evidence/rev004/screens/TPY_YMTriParteTwentySeven.png) | 3개월부터 | 치명적 밈 (Deadly Memes) · `ARFMPYP_Soulfuse` | 총검의 대가 (Paynonets) · `ARFMPYP_Paynonets` | 유령 신호 (Ghost Signal) · `ARFMPYP_GhostSignal` |
| [YMTriParteTwentySix](evidence/rev004/screens/TPY_YMTriParteTwentySix.png) | 12개월부터 | 정예 전도자 (Elite Bashars) · `ARFMPYP_EliteBashars` | 고유 전도자 (Unique Bashars) · `ARFMPYP_UniqueBashars` | 평범한 전도자 (Mundane Bashars) · `ARFMPYP_MundaneBashars` |
| [YMTriParteTwentyFive](evidence/rev004/screens/TPY_YMTriParteTwentyFive.png) | 2개월부터 | 우리에게는 로켓이 있다 (We Got The Rockets) · `ARFMPYP_WeGotTheRockets` | 대혼란 폭발 (Bedlam Blasting) · `ARFMPYP_BedlamBlasting` | 악몽의 연료 (Nightmare Fuel) · `ARFMPYP_NightmareFuel` |
| [YMTriParteTwentyFour](evidence/rev004/screens/TPY_YMTriParteTwentyFour.png) | 5개월부터 | 외상 증폭기 (Trauma Amplifiers) · `ARFMPYP_PainTrain` | 대구경 (High Caliber) · `ARFMPYP_HighCaliber` | 생존 의지 (Will To Survive) · `ARFMPYP_WillToSurvive` |
| [YMTriParteTwentyThree](evidence/rev004/screens/TPY_YMTriParteTwentyThree.png) | 2개월부터 | 이단자를 심판하라 (Suffer Not The Heretic) · `ARFMPYP_HereticBane` | 배신자를 척결하라 (Purge The Betrayers) · `ARFMPYP_BetrayerBane` | 불결한 자를 정화하라 (Cleanse The Unclean) · `ARFMPYP_UnbelieverBane` |
| [YMTriParteTwentyTwo](evidence/rev004/screens/TPY_YMTriParteTwentyTwo.png) | 6개월부터 | 저거너트 (Juggernauts) · `ARFMPYP_Dreadnaughts` | 척추 파괴자 (Spinebreakers) · `ARFMPYP_Spinebreakers` | 절대적인 치명타 (Absolutely Critical) · `ARFMPYP_AdventCrits` |
| [YMTriParteTwentyOne](evidence/rev004/screens/TPY_YMTriParteTwentyOne.png) | 4개월부터 | 날카로운 정신 (Edge of Mind) · `ARFMPYP_EdgeOfMind` | 새벽의 화로 (Pyres of Dawn) · `ARFMPYP_PyresOfDawn` | 성배의 저주 (Grail Curse) · `ARFMPYP_GrailCurse` |
| [YMTriParteTwenty](evidence/rev004/screens/TPY_YMTriParteTwenty.png) | 6개월부터 | 번개 폭풍 (Lightning Storms) · `ARFMPYP_StunningField` | 섬광 폭발 (Blinding Detonations) · `ARFMPYP_BlindingRockets` | 전투 예지 (Battle Premonitions) · `ARFMPYP_ArchonSteroid` |
| [YMTriParteNineteen](evidence/rev004/screens/TPY_YMTriParteNineteen.png) | 3개월부터 | 비글 붕괴 (Beagle Busting) · `ARFMPYP_Beaglebusting` | 전장 태생 (Battle Born) · `ARFMPYP_Battleborn` | 성스러운 전사 (Holy Warriors) · `ARFMPYP_Battlehaunt` |
| [YMTriParteEighteen](evidence/rev004/screens/TPY_YMTriParteEighteen.png) | 3개월부터 | 드론 오버로드 (Drone Overlords) · `PYPDroneOverlordsUnlock` | 화학적 날개 (Chemical Pinions) · `ARFMPYP_ChemicalPinions` | 영혼의 화로 (Soul Pyres) · `ARFMPYP_SoulPyres` |
| [YMTriParteSeventeen](evidence/rev004/screens/TPY_YMTriParteSeventeen.png) | 4개월부터 | 깊은 관통 (Deep Penetration) · `ARFMPYP_DeepPenetration` | 등뼈 부수기 (Back Breakers) · `ARFMPYP_BackBreakers` | 혼란의 충격 (Bewildering Shocks) · `ARFMPYP_BewilderingShocks` |
| [YMTriParteSixteen](evidence/rev004/screens/TPY_YMTriParteSixteen.png) | 5개월부터 | 죽음의 저주 (Death Curse) · `ARFMPYP_DeathCurse` | 즉결 처형 (Summary Execution) · `PYPExecutionUnlock` | 죽음의 표식 (Marked For Death) · `PYPMarkedForDeathUnlock` |
| [YMSectopodEmpowerment](evidence/rev004/screens/TPY_YMSectopodEmpowerment.png) | 6개월부터 | 진보된 알고리즘 (Advanced Algorithms) · `ARFMPYP_SectopodGymrats` | 예측 타격 (Predictive Targeting) · `ARFMPYP_SectopodMania` | 생명 추적 (Vital Tracking) · `ARFMPYP_SectopodShoes` |
| [YMSpectreEmpowerment](evidence/rev004/screens/TPY_YMSpectreEmpowerment.png) | 5개월부터 | 다섯 번째 눈의 저주 (The Fifth Eye Curse) · `ARFMPYP_SpectreFifthEye` | 수수께끼 공학 (Enigmatic Engineering) · `ARFMPYP_SpectreRegen` | 어둠의 포옹 (Dark Embrace) · `ARFMPYP_DarkEmbrace` |
| [YMAndromedonEmpowerment](evidence/rev004/screens/TPY_YMAndromedonEmpowerment.png) | 5개월부터 | 생물학적 위험 돌진 (Biohazard Blitz) · `ARFMPYP_BlindingAcid` | 강력한 기세 (Crushing Momentum) · `ARFMPYP_StunningStrikes` | 왜곡 신호기 (Warp Beacons) · `ARFMPYP_AndromedonWarpBeacon` |
| [YMPurifierEmpowerment](evidence/rev004/screens/TPY_YMPurifierEmpowerment.png) | 5개월부터 | 공포의 화학물질 (Chemicals Of Terror) · `ARFMPYP_SpookyFlame` | 항구의 유산 (Haber's Legacy) · `ARFMPYP_CripplingFlame` | 치명적인 연기 (Deadly Haze) · `ARFMPYP_RuinousFlame` |
| [YMTriParteFifteen](evidence/rev004/screens/TPY_YMTriParteFifteen.png) | 5개월부터 | 불길한 존재 (Haunting Presence) · `ARFMPYP_SpectreTeleport` | 슈퍼 섹토이드 (Super Sectoids) · `ARFMPYP_SuperSectoids` | 억압 (Oppression) · `ARFMPYP_MutonSuppressionShot` |
| [YMTriParteFourteen](evidence/rev004/screens/TPY_YMTriParteFourteen.png) | 7개월부터 | 견고한 섹토포드 (Solid Sectopods) · `ARFMPYP_SolidSectopod` | 초강화 외부 장갑 (Super Shells) · `ARFMPYP_GatekeeperSupershell` | 강화 장갑 (Reinforced Plating) · `ARFMPYP_AndromedonPlating` |
| [YMTriParteThirteen](evidence/rev004/screens/TPY_YMTriParteThirteen.png) | 4개월부터 | 정화 계획 (Purification Planning) · `ARFMPYP_PurifierUnicorn` | 제 7의 감각 (Seventh Sense) · `ARFMPYP_MutonTapdancer` | 근접 전투 (Close Quarters Combat) · `ARFMPYP_Stunmancy` |
| [YMTriParteTwelve](evidence/rev004/screens/TPY_YMTriParteTwelve.png) | 7개월부터 | 원자 광선 (Atomizer Beams) · `ARFMDESW_CHAGatekeeperGirlboss` | 과독 (Hypertoxicitiy) · `ARFMPYP_MurderDrool` | 파괴자 (Juggernautical) · `ARFMPYP_Zerkernaut` |
| [YMTriParteEleven](evidence/rev004/screens/TPY_YMTriParteEleven.png) | 3개월부터 | 방어 전술 (Defensive Tactics) · `ARFMDESW_CHAMutonReposition` | 치명적인 똬리틀기 (Lethal Coils) · `ARFMDESW_CHASnekSnuggles` | 강령 의식 (Necromantic Rituals) · `ARFMPYP_ZombieRoids` |
| [YMTriParteTen](evidence/rev004/screens/TPY_YMTriParteTen.png) | 5개월부터 | 스펙터 문제 해결 시스템 (Spectre Troubles) · `ARFMDESW_CHASpectreTrouble` | 정예 전투원 (Elite Combatants) · `ARFMDESW_CHAAndromedonGigachad` | 강화 전쟁 프레임 (Enhanced Warframes) · `ARFMDESW_CHAEnhancedWarframes` |
| [YMTriParteNine](evidence/rev004/screens/TPY_YMTriParteNine.png) | 7개월부터 | 쌍둥이 체임버 (Twin Chambers) · `ARFMPYP_AndromedonDoubleTap` | 깨어나십시오, 주인이시여 (Awaken My Masters) · `ARFMDESW_CHAAwakenMyPoddies` | 새로운 품종 (The New Breed) · `ARFMDESW_CHALiddyRoids` |
| [YMTriParteEight](evidence/rev004/screens/TPY_YMTriParteEight.png) | 5개월부터 | 복구 프로토콜 (Restoration Protocols) · `ARFMDESW_CHARestorationProtocols` | 통제 불능의 잔혹함 (Unchecked Brutality) · `ARFMDESW_CHAMutonBrutal` | 포격 프로토콜 (Barrage Protocols) · `ARFMDESW_CHASuperArchons` |
| [YMTriParteSeven](evidence/rev004/screens/TPY_YMTriParteSeven.png) | 5개월부터 | 안전 프로토콜 (Safety Protocols) · `ARFMDESW_CHASafetyProtocols` | 우선 표적 지정 (Priority Targeting) · `ARFMDESW_CHAPriorityTargeting` | 고급 훈련 (Advanced Training) · `ARFMDESW_CHAAdvancedTraining` |
| [YMTriParteSix](evidence/rev004/screens/TPY_YMTriParteSix.png) | 5개월부터 | 전쟁 강철 합금 (Warsteel Alloys) · `ARFMDESW_CHARoboArmor` | 밀폐된 장갑복 (Armor Sealing) · `ARFMDESW_CHAAlienSealedArmor` | 사이오닉 보호 (Psychic Shielding) · `ARFMDESW_CHAPsychicScreens` |
| [YMTriParteFive](evidence/rev004/screens/TPY_YMTriParteFive.png) | 5개월부터 | 고급 전술 프로세서 (Advanced Tactical Processors) · `ARFMDESW_CHARoboMadness` | 스마트 탄약 (Smart Munitions) · `ARFMDESW_CHAWoodpecker` | 네트워크 수리 (Network Repairs) · `ARFMDESW_CHANetworkRepairs` |
| [YMTriParteFour](evidence/rev004/screens/TPY_YMTriParteFour.png) | 4개월부터 | 핏빛 광란 (Blood Frenzy) · `ARFMDESW_CHAArchonTurbo` | 전술 분석 (Tactical Analysis) · `ARFMDESW_CHATacticalAnal` | 고급 근접 전투 훈련 (Advanced Melee Combat Training) · `ARFMDESW_CHAStunlancerCounter` |
| [YMTriParteThree](evidence/rev004/screens/TPY_YMTriParteThree.png) | 4개월부터 | 포격 프로토콜 (Slippery Stalkers) · `ARFMDESW_CHASlipperyStalkers` | 생물학적 증강 (Biological Augmentation) · `ARFMDESW_CHAFacelessJelly` | 폭발 저항 피부 (Blast Resistant Skin) · `ARFMDESW_CHAMutonSkin` |
| [YMTriParteTwo](evidence/rev004/screens/TPY_YMTriParteTwo.png) | 4개월부터 | 믿음의 힘 (Power Through Faith) · `ARFMDESW_CHAPriestProtein` | ICE 프로토콜 (ICE Protocols) · `ARFMDESW_CHAICEProtocols` | 근접 전투 (Close Quarters Combat) · `ARFMDESW_CHAMutonCQC` |
| [YMTriParteOne](evidence/rev004/screens/TPY_YMTriParteOne.png) | 4개월부터 | 완전 엄폐 프로토콜 (Deep Cover Protocols) · `ARFMDESW_CHATroopyFace` | 소각 포드 (Incineration Pods) · `ARFMDESW_CHAIncinerationPods` | 적응형 근육 조직 (Adaptive Musculature) · `ARFMDESW_CHASpeedyGonzales` |
| [YMTrooperGrenades](evidence/rev004/screens/TPY_YMTrooperGrenades.png) | 2개월부터 | 플라즈마 수류탄 (Plasma Grenades) · `ARFMPYP_TrooperPlasmaGrenade` | 가스 수류탄 (Gas Grenades) · `ARFMPYP_TrooperGasGrenade` | 산성 수류탄 (Acid Grenades) · `ARFMPYP_TrooperAcidGrenade` |
| [YMStunlancerGrenades](evidence/rev004/screens/TPY_YMStunlancerGrenades.png) | 2개월부터 | 플라즈마 수류탄 (Plasma Grenades) · `ARFMPYP_StunlancerPlasmaGrenade` | 가스 수류탄 (Gas Grenades) · `ARFMPYP_StunlancerGasGrenade` | 산성 수류탄 (Acid Grenades) · `ARFMPYP_StunlancerAcidGrenade` |
| [YMShieldbearerMindLink](evidence/rev004/screens/TPY_YMShieldbearerMindLink.png) | 3개월까지 | 정신 연계 - 지각 (Mind Link - Perception) · `ARFMPYP_ShieldbearerPerceptionLink` | 정신 연계 - 정밀 (Mind Link - Precision) · `ARFMPYP_ShieldbearerPrecisionLink` | 정신 연계 - 전술 (Mind Link - Tactics) · `ARFMPYP_ShieldbearerTacticLink` |
| [YMLancerMindLink](evidence/rev004/screens/TPY_YMLancerMindLink.png) | 3개월까지 | 정신 연계 - 지각 (Mind Link - Perception) · `ARFMPYP_LancerPerceptionLink` | 정신 연계 - 정밀 (Mind Link - Precision) · `ARFMPYP_LancerPrecisionLink` | 정신 연계 - 전술 (Mind Link - Tactics) · `ARFMPYP_LancerTacticLink` |
| [YMPriestMindLink](evidence/rev004/screens/TPY_YMPriestMindLink.png) | 3개월까지 | 정신 연계 - 지각 (Mind Link - Perception) · `ARFMPYP_PriestPerceptionLink` | 정신 연계 - 정밀 (Mind Link - Precision) · `ARFMPYP_PriestPrecisionLink` | 정신 연계 - 전술 (Mind Link - Tactics) · `ARFMPYP_PriestTacticLink` |
| [YMOfficerMindLink](evidence/rev004/screens/TPY_YMOfficerMindLink.png) | 3개월까지 | 정신 연계 - 지각 (Mind Link - Perception) · `ARFMPYP_OfficerPerceptionLink` | 정신 연계 - 정밀 (Mind Link - Precision) · `ARFMPYP_OfficerPrecisionLink` | 정신 연계 - 전술 (Mind Link - Tactics) · `ARFMPYP_OfficerTacticLink` |
| [YMTrooperMindLink](evidence/rev004/screens/TPY_YMTrooperMindLink.png) | 3개월까지 | 정신 연계 - 지각 (Mind Link - Perception) · `ARFMPYP_TrooperPerceptionLink` | 정신 연계 - 정밀 (Mind Link - Precision) · `ARFMPYP_TrooperPrecisionLink` | 정신 연계 - 전술 (Mind Link - Tactics) · `ARFMPYP_TrooperTacticLink` |
| [YMMECEnhancement](evidence/rev004/screens/TPY_YMMECEnhancement.png) | 3개월까지 | 성형작약 폭발 (Shaped Detonations) · `ARFMPYP_MacroMissiles` | 지형 매핑 (Terrain Mapping) · `ARFMPYP_TerrainMapping` | 합금 장갑판 (Alloyed Armor) · `ARFMPYP_MECArmor` |
| [YMMutonEnhancement](evidence/rev004/screens/TPY_YMMutonEnhancement.png) | 3개월까지 | 강력한 타격자 (Heavy Hitters) · `ARFMPYP_HitterMuton` | 잔혹한 근력 (Brutalist Strength) · `ARFMPYP_BrutalistMuton` | 초반응 (Hyper Reactive) · `ARFMPYP_ReactiveMuton` |
| [YMPriestEnhancement](evidence/rev004/screens/TPY_YMPriestEnhancement.png) | 3개월까지 | 공허의 사제 (Void Priests) · `ARFMPYP_VoidPriest` | 전투 사제 (Battle Priests) · `ARFMPYP_BattlePriest` | 그림자 사제 (Umbra Priests) · `ARFMPYP_UmbraPriest` |
| [YMOfficerEnhancement](evidence/rev004/screens/TPY_YMOfficerEnhancement.png) | 3개월까지 | 방어 전술 (Defensive Tactics) · `ARFMPYP_OfficerDefense` | 가속 체임버 (Acceleration Chambers) · `ARFMPYP_OfficerDamage` | 스마트 조준경 (Smart Scopes) · `ARFMPYP_OfficerAim` |
| [YMTrooperEnhancement](evidence/rev004/screens/TPY_YMTrooperEnhancement.png) | 3개월까지 | 방어 전술 (Defensive Tactics) · `ARFMPYP_TrooperDefense` | 가속 체임버 (Acceleration Chambers) · `ARFMPYP_TrooperDamage` | 스마트 조준경 (Smart Scopes) · `ARFMPYP_TrooperAim` |
| [YMSectoidEnhancement](evidence/rev004/screens/TPY_YMSectoidEnhancement.png) | 3개월까지 | 기억술 (Mnemonics) · `ARFMPYP_SectoidPsi` | 증폭기 (Amplifiers) · `ARFMPYP_SectoidDamage` | 조정 (Calibration) · `ARFMPYP_SectoidAim` |
| [YMStunlancerEnhancement](evidence/rev004/screens/TPY_YMStunlancerEnhancement.png) | 3개월까지 | 방어 전술 (Defensive Tactics) · `ARFMPYP_StunlancerDefense` | 선봉대 (Vanguards) · `ARFMPYP_StunlancerMove` | 매의 눈 (Eagle Eyes) · `ARFMPYP_StunlancerAim` |
| [YMPurifierEnhancement](evidence/rev004/screens/TPY_YMPurifierEnhancement.png) | 3개월까지 | 두개골 강화 (Cranial Reinforcement) · `ARFMPYP_PurifierCranialReinforcement` | 재생력 (Regeneratives) · `ARFMPYP_PurifierRegeneration` | 방어구 (Armor) · `ARFMPYP_PurifierArmor` |
