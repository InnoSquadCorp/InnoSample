# InnoSample Architecture Review

기준일: 2026-05-13 (P1 해결 반영)

이 문서는 현재 `InnoSample` 코드베이스를 기준으로 한 구조 평가와 개선 우선순위를 정리한 문서입니다.
목적은 “다시 설계할지”를 판단하는 것이 아니라, 현재 구조를 운영 가능한 수준에서 어떻게 더 단단하게 만들지 기준점을 남기는 것입니다.

## Scorecard

| Area | Score | Notes |
| --- | --- | --- |
| Architecture | 9.4 / 10 | `App -> Layers -> Features + ThirdParty` 구조와 feature 다중 타깃 경계가 명확함 |
| Code Detail | 9.1 / 10 | Swift concurrency, launch/watch wiring, root composition 테스트가 안정적임 |
| InnoDI Usage | 9.1 / 10 | composition root, layer container, feature container 경계가 명확함 |
| InnoFlow Usage | 9.3 / 10 | PhaseMap, IdentifiedArray, @BindableField, StoreInstrumentation까지 4.x 권장 surface를 반영 |
| InnoRouter Usage | 9.3 / 10 | 상위 중재 + DeepLinkMatcher + Observation deferred dispatch + FlowHost / NavigationSplitHost / NavigationHost 세 host 패턴 공존 |
| InnoNetwork Usage | 9.4 / 10 | retry/decoding/4xx 검증 + `AuthRequiredScope` 타입 마커 + single-flight `RefreshTokenPolicy` + `HTTPHeaderName<SingleValueHeader>` 적용 |

## Overall Assessment

현재 구조는 “샘플” 수준을 넘어 운영 서비스 아키텍처의 방향성을 설명할 수 있는 수준입니다.

강점:

- `App`, `Layers`, `Features`, `ThirdParties`, `Utils`의 역할이 비교적 선명합니다.
- leaf feature를 `Interface / Logic / UI / Router / Testing / Tests`로 분리해서 컴파일 단계에서 구조를 강제합니다.
- `People -> Settings -> People` 예제처럼 런타임 이동 순환이 가능해도, 컴파일 의존 순환은 만들지 않는 패턴이 잘 반영돼 있습니다.
- `Layers`는 `Remote -> Data -> Domain -> LayerContainer` 순서가 잘 드러나고, feature-facing use case surface도 얇게 유지됩니다.
- `Remote`가 외부 API 호출 정책, DTO decode, InnoNetwork client 조립, remote failure 변환을 직접 소유하므로 layer 책임이 더 선명해졌습니다.
- `ThirdParty`와 `Util`을 분리하고, `Analytics`를 interface 기반 SDK wrapper 예제로 둔 선택도 좋습니다.
- 앱은 실제 iOS launch screen과 modern single-target SwiftUI watchOS companion(`WKApplication`)까지 포함해서 멀티플랫폼 샘플로서 설명력이 높아졌습니다.

## Priority Improvements

### P1

해결됨. `InnoRouterCore / InnoRouterSwiftUI / InnoRouterDeepLink`를 `Tuist/Package.swift`의 `productTypes`에 `.framework`로 추가해, umbrella가 dynamic이고 sub-target은 static으로 빌드되며 발생하던 “Class is implemented in both …” warning을 제거했습니다. clean build에서 InnoRouter 관련 link warning은 사라졌고, 남은 18건은 모두 무해한 `appintentsmetadataprocessor` notice 입니다. 자세한 근거는 [LinkagePolicy.md](LinkagePolicy.md#external-package-product-types) 참고.

### P2

1. `Remote` 네트워크 정책 테스트 확대 — 진행됨
   - `RemotePolicyTests` 9개 (5+4): retry/decoding/4xx-비retry + Retry-After honor + POST 비-idempotent retry budget 보존 + AuthRequiredScope refresh single-flight + 동시 401 결합 + typed `HTTPHeaderName` 호환성. `SequencedStubURLSession`으로 호출 순서별 응답 큐잉.
   - 다음 단계는 persistent cache wrapping (`rfc9111Compliant`).

2. watch companion 형상 현대화 — 진행됨
   - 기존 legacy 2-target (`watch2App` + `watch2Extension`, `WKWatchKitApp`) 구조를 modern single-target SwiftUI watchOS app(`product: .app` + watchOS destinations + `WKApplication: true`)로 교체.
   - WatchExtension 폴더는 제거하고 `App/WatchApp/Sources/`로 통합. `WatchCompanionConfiguration`의 extension 필드(`extensionName/Bundle/Display/BuildableFolders/Resources/Dependencies`)도 모두 삭제.
   - Tuist의 `.watch2App` 제품 타입은 "embed binary from extension" 래핑 빌드 페이즈를 강제해 modern flat layout과 `Multiple commands produce …/<binary>` 충돌을 발생시킴 → `.app` 제품 타입 + watchOS destination만 사용. `WKApplication = true`와 watchOS-only destination 조합이 설치기에 워치 앱임을 알림.
   - iOS Simulator 설치 차단 해소 확인 ([InnoSampleAppUITests.swift](../App/UITests/InnoSampleAppUITests.swift)) — `testAppLaunchesAndSupportsCoreFlows`가 iPhone 17 Pro 시뮬레이터에서 ~36초로 통과.
   - 워치 app에 실제 콘텐츠 노출 — `WatchHomeView`가 `Domain.UserSummary` 기반 People 리스트를 렌더하고, 셀 탭 시 `WatchPersonDetailView`로 push. 데이터는 [WatchSamplePeople.swift](../App/WatchApp/Sources/WatchSamplePeople.swift) 고정 fixture(스코프 한정 — production은 `WatchConnectivity` 또는 App Group SwiftData로 동기화). watchCompanion 의존성에 `.layer(.domain)` 추가.

3. platform destination 정책 미세 조정 — 진행됨
   - ThirdParty 헬퍼(`Project.thirdParty`)의 기본 destination을 `sharedModuleDestinations`(iPhone/iPad/Mac/TV/Watch/Vision)에서 `defaultDestinations`(iPhone/iPad/Mac)로 좁힘. SDK 어댑터 대부분이 iOS-first이고 워치 app은 Analytics를 import하지 않으므로 platform parity를 과도하게 주장하지 않도록 조정.
   - 확장이 필요한 ThirdParty는 호출부에서 `destinations: Manifest.sharedModuleDestinations`를 명시적으로 전달하는 opt-in 방식.
   - `Domain`은 멀티플랫폼 유지 — 실제로 워치 app이 `UserSummary`를 사용하기 때문.

4. UI test actor 경고 정리 — 진행됨
   - `InnoSampleAppUITests` 클래스에 `@MainActor`를 부여해 `XCUIApplication` / `XCUIElement` MainActor isolation 경고 20여 개를 모두 해소했습니다 ([InnoSampleAppUITests.swift:3](../App/UITests/InnoSampleAppUITests.swift:3)).
   - iOS Simulator(iPhone 17 Pro)에서 `testAppLaunchesAndSupportsCoreFlows`가 People → Settings → People 왕복, modal sheet, navigation push 시나리오를 ~37초에 완주합니다. B2의 polling 제거가 race-free임을 함께 검증합니다.

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
- 사용 중인 4.x 추가 패턴:
  - `@InnoFlow(phaseManaged: true)` + `PhaseMap` DSL — `PeopleFeatureReducer`, `SettingsFeatureReducer`에서 idle/loading/loaded/failed FSM 선언.
  - `IdentifiedArrayOf<UserSummary>` — `PeopleFeatureReducer.State.people`에서 O(1) id lookup. `state.people[id: userID]` 패턴 사용 ([PeopleFeatureReducer.swift](../Features/PeopleFeature/Logics/Reducer/PeopleFeatureReducer.swift)).
  - `@BindableField` — `SettingsFeatureReducer.State.showsCompletedOnly` 토글 상태. Reducer는 `case setShowsCompletedOnly(Bool)` 액션으로만 업데이트.
  - `StoreInstrumentation` — `PeopleFeatureModel.init`에서 `.combined(.osLog, .signpost)` 어댑터를 DEBUG 빌드 한정으로 Store에 주입 ([PeopleFeatureModel.swift](../Features/PeopleFeature/Logics/Model/PeopleFeatureModel.swift)). Instruments + Console에서 effect lifecycle 추적 가능.
- 의도된 단순화: `ForEachIdentifiedReducer` + `scope(collection:id:action:)` + `store.binding(\.$field, to:)` 같은 collection-routing/binding 패턴은 InnoSample의 `Logic / UI` 모듈 분리와 `@InnoFlow` 매크로 호환성 제약(매크로가 생성하는 `func reduce(into:action:)`가 internal 고정이라 reducer struct를 public으로 노출할 수 없음)으로 직접 데모하지 않습니다. 대신 SwiftUI `Binding(get:set:)`을 통한 Model facade 패턴으로 동일 상태 동기화를 보여줍니다. 단일 모듈 구조에선 라이브러리 README/Examples의 canonical 사용을 권장합니다.

### InnoRouter

- child coordinator를 상위 `EntireTabCoordinator`가 조립하고, cross-feature intent도 상위에서 중재하는 사용법은 좋습니다.
- `People -> Settings -> People` 예제로 “런타임 이동 순환은 허용하되 컴파일 의존 순환은 막는 패턴”이 분명하게 드러납니다.
- 세 가지 host 패턴을 의도적으로 sample 안에 공존:
  - **PeopleFeature** — `FlowStore<PeopleRoute>` + `FlowHost`: push + sheet 통합 path 투영.
  - **PostsFeature** — `NavigationStore<PostsRoute>` + `NavigationSplitHost` + `ModalHost`: iPad/macOS에서 sidebar(list) + detail(column) 자동 분리, iPhone에서는 SwiftUI가 NavigationStack으로 collapse해 push 흐름 유지.
  - **SettingsFeature** — `NavigationStore` + `ModalHost` 두-스토어 패턴: 모달과 푸시 도메인 분기가 명확할 때 가장 읽기 쉬움.
  - 채택 기준: 동일 평면에 push+modal이 섞이면 FlowStore, 사이드바+detail이 유리한 list-detail이면 NavigationSplitHost, 도메인 분기가 명확한 모달/푸시 분리는 두-스토어 유지.
- `FlowStore<PeopleRoute>` 선택 도입 — PeopleFeature 한정.
  - `NavigationStore<PeopleRoute>` + `ModalStore<PeopleModalRoute>` 두 스토어를 `FlowStore<PeopleRoute>` 하나로 통합. 모달 라우트 enum(`PeopleModalRoute`)을 삭제하고 `PeopleRoute`에 `.overview([PeopleUser])` 케이스를 합침. dispatch는 `flowStore.send(.replaceStack([.detail(user)]))` / `.send(.presentSheet(.overview(users)))` / `.send(.dismiss)`로 단일 entry. View는 `ModalHost { NavigationHost { ... } ... }` 중첩에서 `FlowHost(store:destination:root:)` 한 줄로 단순화.
  - Posts/Settings는 기존 두-스토어 패턴을 유지해 InnoSample 안에서 두 스타일을 나란히 비교할 수 있게 함. 의도된 의사결정.
  - 채택 기준: 모달/푸시가 같은 dispatch 평면에 있고 단일 path 투영(`flowStore.path: [RouteStep<R>]`)이 디버깅/관찰성에 유리한 feature. 모달과 푸시가 서로 다른 도메인 분기로 명확히 갈리는 feature는 두-스토어 유지가 더 읽기 쉬울 수 있음.
  - 처음 plan의 가설("FlowStore가 cross-feature mediation 폴링을 없앨 수 있다")은 부정확했음. FlowStore는 per-feature 추상이고 EntireTabCoordinator의 cross-tab intent 중재 패턴은 그대로.
- 과거 polling Task로 맞추던 deferred external navigation은 두 단계로 정리됨:
  1. `*RouteHost`의 `.onChange(of:initial: true)` — view mount 시점이 selection arrival 이후여도 push가 한 번에 일어남.
  2. `*FeatureCoordinator.awaitDeferredSelection()` — `withObservationTracking` 기반 이벤트 wait. view-독립적이라 시뮬 cold-start 및 unit test에서도 동일하게 동작.
- DeepLinkMatcher 기반 URL 진입을 추가:
  - `innosample://host/people/{id}` → People 탭 + user detail push
  - `innosample://host/settings/{id}` → Settings 탭 + assignee detail push
  - 매칭 + 디스패치는 [SampleDeepLink](../Features/EntireTabFeature/Router/DeepLink/SampleDeepLink.swift), [SampleDeepLinkMatcher](../Features/EntireTabFeature/Router/DeepLink/SampleDeepLinkMatcher.swift), `EntireTabCoordinator.handleDeepLink(_:)`에 위치. 앱 진입은 `FeatureRootScene`의 `.onOpenURL`이 담당. URL scheme은 `App/Project.swift`의 `CFBundleURLTypes`로 등록.
  - 검증: `EntireTabFeatureTests`에 매처/디스패처 단위 테스트 4개 + `xcrun simctl openurl FF66... innosample://host/{people|settings}/N` 콜드/웜 진입 모두 통과.

### InnoNetwork

- `Remote`가 `APIDefinition`과 `NetworkClient.request(_:)`를 직접 사용해 최신 public surface를 보여줍니다.
- base URL, retry, timeout, metadata interceptor, logger, remote failure mapping은 외부 API 호출 layer인 `Remote` 내부에 모읍니다.
- 4.x 권장 surface 추가 적용:
  - `Auth = AuthRequiredScope` 타입 마커 — [FetchTodosRequest](../Layers/Remote/Sources/Todo/Requests/FetchTodosRequest.swift)에 표기. `NetworkConfiguration`에 `refreshTokenPolicy`가 없는 상태로 인증 endpoint를 호출하면 transport 이전에 `NetworkError.configuration`로 거절되어 컴파일·런타임 양쪽에서 가드.
  - `RefreshTokenPolicy` + single-flight refresh — [RemoteClientFactory.makeRefreshTokenPolicy](../Layers/Remote/Sources/Infrastructure/RemoteClientFactory.swift)에서 `RemoteTokenStore` actor를 currentToken/refreshToken 클로저로 위임. 401 → refresh → replay 한 번 수행, 동시 401 요청은 단일 refresh task로 결합.
  - `HTTPHeaderName<SingleValueHeader>` phantom-typed 헤더 — `X-Sample-Feature` / `X-Request-ID`를 [RemoteHeaderNames.swift](../Layers/Remote/Sources/Infrastructure/RemoteHeaderNames.swift)에 typed name으로 선언하고 `headers[.sampleFeature] = featureName` 형태로 사용. `add` vs `update`를 컴파일 단계에서 강제.
- 검증: `RemotePolicyTests`에 3개 추가 — `testAuthRequiredRequestAttachesBearerTokenAndRefreshesOn401`, `testConcurrentAuthRequiredRequestsCollapseRefreshIntoOneFlight`, `testHeadersUseTypedSampleFeatureName`. JSONPlaceholder는 `Authorization` 헤더를 무시하므로 production 런타임 회귀는 없음 — iOS UI test 통과 확인.
- `InnoNetworkCodegen`이 public dependency surface로 소비 가능해지면 request 선언을 `@APIDefinition` 기반으로 줄이는 것이 다음 단계입니다.

## Recommended Next Sequence

1. Watch app `Domain` 모델 동기화 (현재는 fixture → `WatchConnectivity` 또는 App Group SwiftData로 production-ready 경로)
2. `InnoNetwork` persistent cache wrapping (`rfc9111Compliant(wrapping:)`) — offline-first 시나리오 추가 시
3. `InnoNetworkCodegen` 공개 시 `@APIDefinition` 매크로로 request 선언 축소
4. InnoFlow row scoping (`ForEachIdentifiedReducer` + `ScopedStore`) — Logic 모듈 통합 또는 매크로 측 public reducer 지원 후

## Conclusion

현재 `InnoSample`은 구조적으로 충분히 좋은 편입니다.
지금 필요한 것은 “다시 뜯어고치기”보다, 운영 서비스 품질 기준에서 링크 전략, 테스트 밀도, 플랫폼 세부 정책을 더 단단하게 만드는 정리 작업입니다.
