# InnoSample Architecture Review

기준일: 2026-05-13

이 문서는 현재 `InnoSample` 코드베이스를 기준으로 한 구조 평가와 개선 우선순위를 정리한 문서입니다.
목적은 “다시 설계할지”를 판단하는 것이 아니라, 현재 구조를 운영 가능한 수준에서 어떻게 더 단단하게 만들지 기준점을 남기는 것입니다.

## Scorecard

| Area | Score | Notes |
| --- | --- | --- |
| Architecture | 9.4 / 10 | `App -> Layers -> Features + ThirdParty` 구조와 feature 다중 타깃 경계가 명확함 |
| Code Detail | 9.1 / 10 | Swift concurrency, launch/watch wiring, root composition 테스트가 안정적임 |
| InnoDI Usage | 9.1 / 10 | composition root, layer container, feature container 경계가 명확함 |
| InnoFlow Usage | 9.0 / 10 | `Logic` 타깃 격리와 reducer 중심 구조가 잘 잡혀 있음 |
| InnoRouter Usage | 8.8 / 10 | 상위 중재형 navigation 예제가 좋고, 컴파일 의존 순환 없이 sibling 이동을 처리함 |
| InnoNetwork Usage | 9.0 / 10 | `Remote`가 `APIDefinition`, `NetworkClient`, retry/interceptor 정책을 직접 소유함 |

## Overall Assessment

현재 구조는 “샘플” 수준을 넘어 운영 서비스 아키텍처의 방향성을 설명할 수 있는 수준입니다.

강점:

- `App`, `Layers`, `Features`, `ThirdParties`, `Utils`의 역할이 비교적 선명합니다.
- leaf feature를 `Interface / Logic / UI / Router / Testing / Tests`로 분리해서 컴파일 단계에서 구조를 강제합니다.
- `People -> Settings -> People` 예제처럼 런타임 이동 순환이 가능해도, 컴파일 의존 순환은 만들지 않는 패턴이 잘 반영돼 있습니다.
- `Layers`는 `Remote -> Data -> Domain -> LayerContainer` 순서가 잘 드러나고, feature-facing use case surface도 얇게 유지됩니다.
- `Remote`가 외부 API 호출 정책, DTO decode, InnoNetwork client 조립, remote failure 변환을 직접 소유하므로 layer 책임이 더 선명해졌습니다.
- `ThirdParty`와 `Util`을 분리하고, `Analytics`를 interface 기반 SDK wrapper 예제로 둔 선택도 좋습니다.
- 앱은 실제 iOS launch screen과 companion watch app/watch extension까지 포함해서 멀티플랫폼 샘플로서 설명력이 높아졌습니다.

## Priority Improvements

### P1

1. `InnoRouter` duplicate class 경고 대응
   - 현재 known issue로 남아 있는 링크 경고는 장기 운영 서비스 기준에선 우선순위가 높습니다.
   - 방향은 공통 dependency를 truly shared dynamic artifact로 만들지, leaf 구현 타깃을 더 정교하게 static으로 정리할지 결정하는 쪽입니다.

### P2

1. `Remote` 네트워크 정책 테스트 확대
   - 현재 기본 header, request execution, status failure mapping을 검증합니다.
   - 다음 단계는 retry policy, interceptor ordering, decoding failure path를 늘리는 것입니다.

2. watch companion 실제 기능 보강
   - watch app/watch extension은 현재 companion 구조와 placeholder entry까지 포함돼 있습니다.
   - 다음 우선순위는 실제 기능을 어느 레이어까지 watch에 열지 결정하는 일입니다.

3. platform destination 정책 미세 조정
   - 역할별 destination 상수와 helper 기본값은 정리됐습니다.
   - 다음 단계는 `Domain`, `AnalyticsInterface`처럼 멀티플랫폼 유지 가치가 있는 모듈과, 추가로 줄여도 되는 모듈을 한 번 더 점검하는 일입니다.

4. UI test actor 경고 정리
   - 현재 `InnoSampleAppUITests`는 동작과 검증 자체는 통과하지만, `XCUIApplication`와 `XCUIElement` 호출에 대해 `@MainActor` 경고가 남아 있습니다.
   - 테스트 안정성에는 큰 영향이 없지만, 최신 Swift 동시성 기준에 맞춰 정리해 두는 편이 좋습니다.

### P3

1. 내부 API 노출 최소화 유지
   - app DI surface, remote networking infrastructure, router 내부 동기화 API는 계속 `internal/private` 기본값을 유지합니다.

2. generated artifact hygiene 유지
   - `Derived`, generated `InfoPlist`, generated `xcodeproj`, `xcuserdata`는 ignore 정책으로 관리합니다.
   - README와 `.gitignore`, review 문서가 계속 어긋나지 않게 유지합니다.

3. linkage 정책 문서와 실제 배치 동기화 유지
   - [LinkagePolicy.md](/Users/changwoo.son/Developer/InnoSquad/InnoSample/Docs/LinkagePolicy.md) 는 현재 구조와 일치해야 합니다.
   - target product나 dependency shape가 바뀌면 문서도 같이 갱신합니다.

## Inno Library Review

### InnoDI

- composition root, layer container, feature container, third-party wrapper 생성 책임이 비교적 일관됩니다.
- “shared는 repository, computed는 use case” 정책은 좋은 기본값입니다.
- 현재 수준에선 과도한 service locator 냄새 없이 잘 쓰고 있습니다.

### InnoFlow

- `Logic` 타깃으로 물리 분리한 뒤 reducer 중심으로 상태 변화를 관리하는 구조가 적절합니다.
- use case 호출과 UI/navigation import 금지 규칙이 명확해서, flow library를 설계 의도대로 잘 쓰고 있습니다.

### InnoRouter

- child coordinator를 상위 `EntireTabCoordinator`가 조립하고, cross-feature intent도 상위에서 중재하는 사용법은 좋습니다.
- `People -> Settings -> People` 예제로 “런타임 이동 순환은 허용하되 컴파일 의존 순환은 막는 패턴”이 분명하게 드러납니다.
- 다만 deferred deep-link sync를 polling으로 맞추는 부분은 이후 더 이벤트 중심으로 다듬을 수 있습니다.

### InnoNetwork

- `Remote`가 `APIDefinition`과 `NetworkClient.request(_:)`를 직접 사용해 최신 public surface를 보여줍니다.
- base URL, retry, timeout, metadata interceptor, logger, remote failure mapping은 외부 API 호출 layer인 `Remote` 내부에 모읍니다.
- `InnoNetworkCodegen`이 public dependency surface로 소비 가능해지면 request 선언을 `@APIDefinition` 기반으로 줄이는 것이 다음 단계입니다.

## Recommended Next Sequence

1. `InnoRouter` duplicate class 경고 대응 전략 결정
2. `Remote` retry/interceptor/decoding failure 테스트 확대
3. watch companion 실제 기능 방향 정리
4. platform destination 정책 미세 조정
5. UI test `@MainActor` 경고 정리

## Conclusion

현재 `InnoSample`은 구조적으로 충분히 좋은 편입니다.
지금 필요한 것은 “다시 뜯어고치기”보다, 운영 서비스 품질 기준에서 링크 전략, 테스트 밀도, 플랫폼 세부 정책을 더 단단하게 만드는 정리 작업입니다.
