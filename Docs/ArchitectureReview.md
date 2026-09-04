# InnoSample Architecture Review

기준일: 2026-09-04 (InnoDI 6.0 pre-release pilot 포함)

이 문서는 현재 `InnoSample`이 Inno 라이브러리의 macro-first surface를 실제 구조와 테스트에서 얼마나 활용하는지 기록합니다. 검증 결과는 설계 평가와 분리하며, 마지막 전체 gate를 다시 통과한 시점에만 확정합니다. 현재 checkout은 2026-09-04 Xcode 27.0에서 `make verify-ci`를 통과했습니다.

## Scorecard

| Area | Assessment | Current usage |
| --- | --- | --- |
| Architecture | Strong | `App -> Layers / Features / ThirdParty`와 feature 다중 타깃 경계 |
| InnoDI 6.0 pilot | Macro-first + experimental | strict hierarchy + assisted child factory + DAG validation plugin |
| InnoFlow 5.1 | Macro-first | phase-managed reducers + deterministic testing surface |
| InnoRouter 5.2.1 | Macro-first | generated routers, hosts, tabs, deep links, environment routing |
| InnoNetwork 5.0 | Macro-first | generated endpoint contracts, explicit auth, advanced packs, persistent cache, consumer test support |

## Current Dependency Surface

| Package | Version | Current sample usage |
| --- | --- | --- |
| `InnoDI` | `e1f0d12` revision | 공개 `@Input(.assisted)`·`@AssistedFactory`·`@SubContainerFactory`, `InnoDIDAGValidationPlugin` |
| `InnoFlow` | `5.1.0` | `@InnoFlow(phaseManaged: true)`, `PhaseMap`, cancellable effects, `@BindableField`, `StoreInstrumentation`, `TestStore`, `ManualTestClock` |
| `InnoNetwork` | `5.0.0` | `@APIDefinition`, `NetworkClient.request(_:)`, explicit auth, scoped refresh, typed headers, persistent cache, `InnoNetworkTestSupport` |
| `InnoRouter` | `5.2.1` | `@Router`, `@TabItem`, `@DeepLink`, macro hosts, `@EnvironmentRouter`, `FlowTestStore` |

의존성은 각 project manifest가 remote package requirement로 선언합니다. InnoDI만 6.0 파일럿 revision을 고정하고 나머지는 exact release를 사용합니다. `Tuist/Package.swift`는 per-project package 선언과 중복되지 않도록 dependency 목록을 비워 두며, generated `Package.resolved`는 저장소에 추적하지 않습니다.

## Architecture Assessment

현재 구조의 강점은 다음과 같습니다.

- leaf feature를 `Interface / Logic / UI / Router / Testing / Tests`로 나누어 import 경계를 컴파일 단계에서 강제합니다.
- `AppContainer -> FeatureContainer -> EntireTabContainer` strict hierarchy를 매크로가 생성하는 dependency contract로 검증합니다.
- `Remote -> Data -> Domain -> LayerContainer` 조립을 root layer가 숨기고 feature에는 concrete stateless use case만 전달합니다.
- `People -> Settings -> People` 런타임 이동은 상위 `EntireTabCoordinator`가 중재하므로 sibling 간 컴파일 의존 순환이 없습니다.
- routing state 소유권은 generated router 환경에 있고 coordinator는 business intent와 cross-feature mediation에 집중합니다.

## InnoDI 6.0 Pilot

- `AppContainer`는 `@DIHierarchyRoot`와 `@DIContainer(root: true, mainActor: true)`를 함께 사용합니다.
- cross-module child인 `FeatureContainer`와 `EntireTabContainer`는 `@DIComponent`로 strict hierarchy 참여를 명시합니다.
- `@Provide(...self, with:)`의 type-based factory dependency와 `@SubContainer(bindings:)` edge를 사용합니다.
- 각 relevant target은 `InnoDIDAGValidationPlugin`을 연결해 declaration/DAG validation을 빌드에 포함합니다.
- People 상세 화면은 route의 `PeopleUser`를 assisted input으로 받아 child container를 생성합니다. 서로 다른 route 값은 독립된 shared session을 가지며, 같은 child 내부에서는 identity를 유지하고 테스트 override도 적용됩니다.
- 파일럿은 공개 6.0 preparation surface와 InnoDI revision `e1f0d12ee0d8077d4077dca8718aa372553a6277`에 의도적으로 고정합니다. RFC 0006이 Draft인 동안 최종 6.0 정식 API로 간주하지 않습니다.

revision `e1f0d12`에서는 child 선언이 source-visible nested `AssistedFactory`를 소유하고 parent가 `@SubContainerFactory`로 ordinary input을 바인딩합니다. 같은 Xcode target의 다른 source file에서도 actor-isolated generated initializer와 assisted call이 노출되어 기존 `PeopleDetailFactoryPilot` wrapper와 `_spi(Experimental)` import를 제거했습니다. child의 `PeopleFeatureInput`은 parent가 고정하고 `PeopleUser`는 route 호출 시 전달되며, 서로 다른 호출의 `.shared` session 격리와 override 흐름을 테스트합니다.

제약도 명시적으로 남깁니다. Xcode build-tool plugin fallback은 전체 source declaration과 dependency DAG를 검증하지만, Xcode plugin API가 Tuist의 cross-project target topology를 완전하게 전달하지는 않습니다. 따라서 exact module-edge hierarchy 검증은 topology-aware SwiftPM/CI gate가 최종 증거이며, 로컬 Xcode gate만으로 그 범위를 과장하지 않습니다.

## InnoFlow 5.1

- 모든 leaf reducer는 `@InnoFlow(phaseManaged: true)`와 `PhaseMap`으로 상태 전이를 선언합니다.
- effect는 `EffectTask.run`과 `cancellable(cancelInFlight:)`로 lifecycle을 드러냅니다.
- production state surface는 `@BindableField`, `IdentifiedArray`, `StoreInstrumentation`을 사용합니다.
- reducer tests는 `InnoFlowTesting.TestStore`의 `send`, `receive(through:)`, `finish()`로 effect와 phase transition을 결정적으로 검증합니다.
- clock 기반 effect test는 `ManualTestClock.advance(by:onceSleepersReach:)`를 사용합니다.
- `Task.yield`, wall-clock sleep, polling helper는 feature tests에서 사용하지 않습니다.

## InnoRouter 5.2.1

- People/Posts/Settings route enum은 모두 `@Router`가 destination과 store를 생성합니다.
- People/Settings는 `RouterHost`, Posts는 지원 플랫폼에서 `RouterSplitHost`를 사용합니다.
- feature view와 route destination은 `@EnvironmentRouter`로 push/sheet/dismiss command를 전송합니다.
- `SampleTab`은 `@Router` + `@TabItem`, root shell은 `RouterTabHost`를 사용합니다.
- `SampleDeepLink`는 scheme/host allowlist를 가진 `@Router`와 route별 `@DeepLink`를 사용하고 generated `resolveDeepLink(_:)`로 URL을 해석합니다.
- route tests는 `InnoRouterTesting.FlowTestStore`로 command, navigation path, modal state, interception을 검증합니다.

`EntireTabCoordinator`는 generated tab router를 직접 소유하지 않습니다. child coordinator의 typed business intent를 소비하고, root bridge가 environment tab router로 실제 탭 선택을 수행합니다.

## InnoNetwork 5.0

- 모든 named endpoint는 root product의 default `Macros` trait가 제공하는 `@APIDefinition(method:path:auth:)`으로 conformance, method, path, auth, empty parameter witness를 생성합니다.
- public endpoint는 `auth: .anonymous`, 인증 endpoint는 `auth: .required`를 선언하고 `RefreshTokenPolicy(appliesTo:)`로 `/todos`만 refresh/replay 대상에 포함합니다.
- production client는 concrete `URLSession` 경계를 사용하고, test target만 `InnoNetworkTestSupport`를 연결해 `MockURLSession`과 `StubNetworkClient`를 사용합니다.
- request metadata adapter는 5.0 역할 구분에 맞춰 `AuthPack.additionalRequestInterceptors`로 구성합니다.
- typed `HTTPHeaderName`, RFC 9111 cache policy, `InnoNetworkPersistentCache`를 app 조립 경로에 적용합니다.
- `RemotePolicyTests`와 `RemoteTransportTests`가 macro-generated contract, typed stub, retry, decoding, auth single-flight, header, cache 동작을 검증합니다.

## Validation Contract

`make verify-ci`는 다음을 한 번에 수행합니다.

1. exact remote package resolve 및 fresh Tuist generate
2. layer import boundary check
3. InnoDI declaration/DAG validation
4. Remote tests
5. People/Posts/Settings/EntireTab leaf feature tests
6. root Features tests
7. generic iOS app build

generated workspace가 InnoDI revision `e1f0d12ee0d8077d4077dca8718aa372553a6277`와 나머지 exact release를 resolve하는지도 별도로 확인합니다. 현재 최종 변경 기준으로 Remote 16개와 feature 25개, 총 41개 테스트 및 generic iOS app/embedded watch app build를 포함한 전체 gate가 통과했습니다.

## Recommended Next Sequence

1. InnoDI RFC 0006이 Accepted되면 exact revision pin을 6.0.0 exact tag로 교체
2. Watch app fixture를 `WatchConnectivity` 또는 App Group storage 기반 동기화로 교체
3. persistent cache telemetry/statistics를 debug surface에 노출
4. InnoNetwork request/cache event를 app debug observability surface에 연결
5. topology-aware hierarchy gate를 InnoSample CI의 명시적 검증 결과로 노출

## Conclusion

현재 구조는 runtime과 testing 양쪽에서 released macro-first surface를 적극 사용하고, InnoDI 6.0 공개 preparation API의 parent-owned assisted factory를 exact revision에 고정해 실제 route flow로 검증합니다. 정식 6.0 전에는 RFC 승인과 exact tag 전환이 남아 있고, 이후 개선은 watch 동기화, cache 관측성, topology-aware CI 증거 강화 같은 운영 hardening 영역입니다.
