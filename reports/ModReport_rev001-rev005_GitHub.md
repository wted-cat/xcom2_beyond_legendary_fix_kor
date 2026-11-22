# Enemy AI Fixes rev001–rev005 GitHub 배포 검증

플레이용 최신 버전은 rev005다. 다섯 버전의 컴파일 패키지, 설정과 소스를 각 버전 폴더에서 확인할 수 있다. 게임에서 사용할 때는 같은 모드 식별자를 가진 버전 중 하나만 활성화한다. 이번 배포에서 게임 동작과 컴파일 패키지는 각 버전의 최종 결과를 그대로 사용했다. [설치 안내](../README.md) · [버전별 변경 이력과 SHA-256](../CHANGELOG.md)

| 버전 | 모드 파일 | 직전 버전 대비 추가 | 수정 | 삭제 | 게임 동작과 검증 기록 |
|---|---:|---:|---:|---:|---|
| [rev001](../rev001/CoarseEnemyAIAndEncounters/) | 16 | 16 | 0 | 0 | [모드 보고서](ModReport_CoarseEnemyAIAndEncounters_rev001.md) |
| [rev002](../rev002/CoarseEnemyAIAndEncounters/) | 17 | 1 | 5 | 0 | [모드 보고서](ModReport_CoarseEnemyAIAndEncounters_rev002.md) |
| [rev003](../rev003/CoarseEnemyAIAndEncounters/) | 28 | 11 | 3 | 0 | [모드 보고서](ModReport_CoarseEnemyAIAndEncounters_rev003.md) |
| [rev004](../rev004/CoarseEnemyAIAndEncounters/) | 37 | 9 | 6 | 0 | [모드 보고서](ModReport_CoarseEnemyAIAndEncounters_rev004.md) |
| [rev005](../rev005/CoarseEnemyAIAndEncounters/) | 51 | 14 | 5 | 0 | [모드 보고서](ModReport_CoarseEnemyAIAndEncounters_rev005.md) |

## 공개 자료

기존 GitHub용 폴더에 rev004와 rev005의 완전한 설치본 및 검증 보고서를 추가했다. 저장소 첫 화면의 README에서 최신 버전과 설치 경로를 찾을 수 있다. CHANGELOG에는 각 버전에서 실제로 바뀐 파일과 패키지 해시를 기록했다.

rev004 보고서의 카드 화면 56장과 모음 4장은 검증 당시 PNG 원본과 바이트 단위로 대조했다. rev004 실행 12개와 rev005 작업의 실행 16개에서 시험 표식, 빌드 결과 및 해당 헌터 회전 경고를 발췌했다. rev005 작업의 16개 기록에는 수정 전 대조, 탐색 실행과 SDK 빌드도 들어 있다. 전술 시험의 완료 횟수는 14회다. 같은 실행에서 기록한 행은 시각과 값을 보존했고, 큰 임무 표는 나누어 보관했다.

## 배포 검증과 재현

| 검증 방식 | 기대 결과 | 확인한 내용 |
|---|---|---|
| 버전별 파일 비교 | 로컬 배포본과 공개본의 경로·파일 내용 일치 | 5개 버전 149개 모드 파일의 상대 경로와 SHA-256 일치. 각 버전에 모드 설명자와 컴파일 패키지 포함 |
| 이전 버전 보존 | 기존 배포본과 공개 보고서 보존 | rev001~003 모드 파일 61개와 기존 공개 보고서 3개의 내용 일치 |
| 문서 탐색 | 저장소 안에서 설치본·소스·표·화면·로그 열기 | 다섯 버전의 경로, 보고서의 내부 링크와 문서 내 위치 확인 |
| Windows Git에 추가 | 자동 줄바꿈 변환을 켜도 파일 내용 보존 | 독립 작업 폴더에서 258개 파일을 Git에 추가한 뒤 각 객체가 가리키는 내용과 배포 파일을 대조 |
| 압축 확인 | 폴더에서 보이는 모든 배포 파일이 ZIP 루트에서 같은 경로로 열림 | ZIP을 다시 열어 전체 파일 목록, CRC와 파일별 SHA-256 일치 확인 |

같은 확인을 반복하려면 ZIP을 빈 폴더에 풀고 루트의 README를 연다. CHANGELOG 끝 표에서 버전별 파일 개수와 컴파일 패키지의 SHA-256을 대조한 뒤, rev004·005 보고서에서 화면과 전투 기록을 연다. 실게임 결과는 각 버전을 만들 때 수행한 시험이며 이번 패키징에서는 파일과 문서를 검증했다.
