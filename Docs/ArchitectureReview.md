# InnoSample Architecture Review

기준일: 2026-03-24

이 문서는 현재 `InnoSample` 코드베이스를 기준으로 한 구조 평가와 개선 우선순위를 정리한 문서입니다.
목적은 “다시 설계할지”를 판단하는 것이 아니라, 현재 구조를 운영 가능한 수준에서 어떻게 더 단단하게 만들지 기준점을 남기는 것입니다.

## Scorecard

| Area | Score | Notes |
| --- | --- | --- |
| Architecture | 9.5 / 10 | `App -> Layers -> Features + ThirdParty` 구조와 feature 다중 타깃 경계, root mediation 테스트까지 잘 정리되어 있음 |
| Code Detail | 9.2 / 10 | concurrency, launch/watch wiring, platform policy, root composition 테스트 디테일이 이전보다 더 안정적임 |
| InnoDI Usage | 9.1 / 10 | composition root, layer container, feature router/container 경계가 명확함 |
| InnoFlow Usage | 9.0 / 10 | `Logic` 타깃 격리와 reducer 중심 구조가 잘 잡혀 있음 |
| InnoRouter Usage | 8.8 / 10 | 상위 중재형 navigation 예제가 좋고, 컴파일 의존 순환 없이 sibling 이동을 처리함 |
| CoreNetwork / InnoNetwork Usage | 9.1 / 10 | transport boundary, 플랫폼 메타데이터, 파일 분리, 정책 테스트가 이전보다 더 안정적임 |

## Overall Assessment

현재 구조는 “샘플” 수준을 넘어 운영 서비스 아키텍처의 방향성을 설명할 수 있는 수준입니다.

강점:

- `App`, `Layers`, `Features`, `ThirdParties`, `Utils`의 역할이 비교적 선명합니다.
- leaf feature를 `Interface / Logic / UI / Router / Testing / Tests`로 분리해서 컴파일 단계에서 구조를 강제합니다.
- `People -> Settings -> People` 예제처럼 런타임 이동 순환이 가능해도, 컴파일 의존 순환은 만들지 않는 패턴이 잘 반영돼 있습니다.
- `Layers`는 `Remote -> Data -> Domain -> LayerContainer` 순서가 잘 드러나고, feature-facing use case surface도 얇게 유지됩니다.
- `ThirdParty`와 `Util`을 분리하고, `Analytics`를 interface 기반 SDK wrapper 예제로 둔 선택도 좋습니다.
- `CoreNetwork`는 이제 transport, environment, metadata interceptor, logger, factory가 역할별 파일로 분리돼 응집도가 좋아졌습니다.
- 앱은 실제 iOS launch screen과 companion watch app/watch extension까지 포함해서 멀티플랫폼 샘플로서 설명력이 높아졌습니다.
- Tuist helper도 역할별 destination 정책, launch screen configuration, watch companion configuration이 분리돼 템플릿 의도가 더 명확해졌습니다.

현재 단계에서 필요한 것은 큰 구조 재설계가 아니라, 세부 정확도와 운영 안정성을 더 높이는 개선입니다.

## Priority Improvements

### P1

1. `InnoRouter` duplicate class 경고 대응
   - 현재 known issue로 남아 있는 링크 경고는 장기 운영 서비스 기준에선 우선순위가 높습니다.
   - 방향은 “공통 dependency를 truly shared dynamic artifact로 만들지” 또는 “leaf 구현 타깃을 더 정교하게 static으로 정리할지”를 결정하는 쪽입니다.

### P2

1. `CoreNetwork` transport policy 테스트를 더 넓히기
   - 현재 factory, metadata, request adapter, status interceptor, logger까지 기본 단위 테스트는 추가됐습니다.
   - 다음 단계는 retry policy, event observer, real decoding failure path, interceptor ordering 같은 더 실제 서비스형 시나리오를 늘리는 것입니다.

2. watch companion 실제 기능 보강
   - watch app/watch extension은 현재 companion 구조와 placeholder entry까지 포함돼 있습니다.
   - 다음 우선순위는 실제 기능을 어느 레이어까지 watch에 열지 결정하는 일입니다.

3. platform destination 정책 미세 조정
   - 역할별 destination 상수와 helper 기본값은 정리됐습니다.
   - 다음 단계는 `Domain`, `CoreNetwork`, `AnalyticsInterface`처럼 멀티플랫폼 유지 가치가 있는 모듈과, 추가로 줄여도 되는 모듈을 한 번 더 점검하는 일입니다.

4. UI test actor 경고 정리
   - 현재 `InnoSampleAppUITests`는 동작과 검증 자체는 통과하지만, `XCUIApplication`와 `XCUIElement` 호출에 대해 `@MainActor` 경고가 남아 있습니다.
   - 테스트 안정성에는 큰 영향이 없지만, 최신 Swift 동시성 기준에 맞춰 정리해 두는 편이 좋습니다.

### P3

1. 내부 API 노출 최소화 유지
   - app DI surface, core network policy 타입, router 내부 동기화 API는 이전보다 많이 줄었습니다.
   - 그래도 feature/router/container 내부 구현에서 추가로 `internal/private`로 내릴 수 있는 surface는 계속 점검하는 편이 좋습니다.

2. generated artifact hygiene 유지
   - `Derived`, generated `InfoPlist`, generated `xcodeproj`, `xcuserdata`는 현재 ignore 정책으로 관리되고 있습니다.
   - README와 `.gitignore`, review 문서가 계속 어긋나지 않게 유지하는 정도의 작업입니다.

3. linkage 정책 문서와 실제 배치 동기화 유지
   - [LinkagePolicy.md](/Users/changwoo.son/Developer/InnoSquad/InnoSample/Docs/LinkagePolicy.md) 는 현재 구조와 일치합니다.
   - 앞으로 target product나 dependency shape가 바뀌면 문서도 같이 갱신해야 합니다.

## Inno Library Review

### InnoDI

- composition root, layer container, feature container, third-party wrapper 생성 책임이 비교적 일관됩니다.
- 특히 “shared는 repository, computed는 use case” 정책은 좋은 기본값입니다.
- 현재 수준에선 과도한 service locator 냄새 없이 잘 쓰고 있습니다.

### InnoFlow

- `Logic` 타깃으로 물리 분리한 뒤 reducer 중심으로 상태 변화를 관리하는 구조가 적절합니다.
- use case 호출과 UI/navigation import 금지 규칙이 명확해서, flow library를 설계 의도대로 잘 쓰고 있습니다.

### InnoRouter

- child coordinator를 상위 `EntireTabCoordinator`가 조립하고, cross-feature intent도 상위에서 중재하는 사용법은 좋습니다.
- `People -> Settings -> People` 예제로 “런타임 이동 순환은 허용하되 컴파일 의존 순환은 막는 패턴”이 분명하게 드러납니다.
- 다만 deferred deep-link sync를 polling으로 맞추는 부분은 이후 더 이벤트 중심으로 다듬을 수 있습니다.

### InnoNetwork

- `CoreNetwork`를 통해 transport boundary를 감싸고, `Remote`가 low-level network details를 직접 모르게 한 구조는 좋습니다.
- platform metadata, 파일 응집도, 기본 policy 테스트는 현재 기준으로 정리됐습니다.
- 다음 단계는 retry/interceptor/logger 정책을 더 실제 서비스형으로 확장하는 것입니다.

## Completed Since Initial Review

- 역할별 destination/deployment 정책 도입
- launch screen configuration과 watch companion configuration 분리
- iOS launch screen 리소스를 iOS 전용으로 정리
- companion watch app/watch extension 포함 구조 유지
- `CoreNetwork` public policy 타입 축소
- `CoreNetwork` factory/transport/status/logger 테스트 보강
- app DI surface와 feature router 내부 API 일부 축소
- root `FeatureContainer` wiring 및 cross-feature mediation 테스트 보강
- app root scene composition smoke test 보강
- `LinkagePolicy.md` 추가 및 README 연결
- hygiene 정책을 README/review/linkage 문서와 정합되게 정리

## Recommended Next Sequence

1. `InnoRouter` duplicate class 경고 대응 전략 결정
2. `CoreNetwork` 고급 시나리오 테스트 확대
3. watch companion 실제 기능 방향 정리
4. platform destination 정책 미세 조정
5. UI test `@MainActor` 경고 정리

## Conclusion

현재 `InnoSample`은 구조적으로 충분히 좋은 편입니다.
지금 필요한 것은 “다시 뜯어고치기”보다, 운영 서비스 품질 기준에서 링크 전략, 테스트 밀도, 플랫폼 세부 정책을 더 단단하게 만드는 정리 작업입니다.
