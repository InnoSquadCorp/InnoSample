# InnoSample Architecture Review

기준일: 2026-10-10. 공개 stable release의 버전과 commit을 확인하고 해당 태그의 코드·전용 스킬을 기준으로 소비 API를 선택합니다.

## Resolved release contract

| Library | Version | Reviewed release commit |
| --- | --- | --- |
| InnoDI | 7.0.1 | `ce47cf4b207c3b8810b2a7d7d622a2f8ead3ed96` |
| InnoFlow | 6.0.2 | `1176de1e4783b638c03a9334f43cc49378957148` |
| InnoNetwork | 6.1.1 | `44e4ca28c50c03f817231a077c0f3bdfdbc859c8` |
| InnoRouter | 7.0.0 | `33b0da7639105cfa8e6f5acffa3badb91b5e0254` |

각 project는 exact remote package를 소비합니다. 로컬 library checkout이나 moving main을 제품 의존성으로 사용하지 않습니다. `make verify-versions`는 manifest와 실제 generated lockfile을 대조합니다. Xcode 27.1 / Swift 6.4 / SwiftSyntax 604.0.0 / Tuist 4.202.5를 검증 도구로 사용합니다.

## Ownership and module boundaries

- App: UI actor 위의 root container, analytics와 Layers/Features 연결.
- Layers: Remote → Data → Domain의 순차 조립과 feature-facing concrete use case 노출.
- Features: leaf coordinator와 EntireTab coordinator 조립.
- Logic: domain state/action/effect/output. SwiftUI와 InnoRouter를 import하지 않습니다.
- UI: renderable model과 callback. Domain/Remote/Data/InnoRouter를 직접 import하지 않습니다.
- Router: host, route, presentation result, URL와 sibling mediation의 경계.

DI role은 실제 graph ownership과 일치시킵니다. App은 `ContainerRole.root`, `@SubContainer`로 마운트하는 FeatureContainer/EntireTabContainer는 `component`, 순차 provider composition과 leaf의 local factory는 `local`입니다. 7.0.1 factory root parameter는 `@Input`/`@Provide` member를 참조합니다. 하위 container에서 다시 interface를 뽑아 다른 provider에 전달하는 순차 조립은 typed provider/factory로 선언합니다. 모든 container 선언 target과 test fixture target에 DAG plugin을 연결합니다.

Coordinator와 feature Store는 container의 shared scope를 유지합니다. 같은 container를 다시 읽어도 새 navigation/business authority를 만들지 않습니다. People/Settings의 leaf host는 default store가 navigation state를 소유합니다. 탭 선택은 shared coordinator의 generated `SampleTab.Tab` 값이며 `@Bindable`로 native TabView에 연결합니다. Posts의 shared coordinator는 하나의 configured store를 소유하므로 host가 다시 생성돼도 상세 이력을 유지합니다. 탭 viewport에서 너비를 관찰해 800pt 미만에서는 stack, 넓은 화면에서는 두 column을 표시하는 split으로 렌더링합니다. `replaceHost`로 descriptor와 전체 detail stack을 함께 전환합니다. 활성 presentation이 있으면 기존 host와 captured handle을 유지하며, 닫힌 뒤 마지막 너비 요청을 적용합니다. 모든 leaf coordinator 환경은 tab host의 공통 ancestor에 주입합니다.

## InnoDI surfaces

| Capability | Sample usage and verification |
| --- | --- |
| Role/input/provider macros | App, Layers, Domain/Data/Remote, 모든 feature container. `@DIContainerRole`, `@Input`, typed/factory `@Provide` |
| Hierarchy and feature root | App → FeatureContainer → EntireTabContainer의 `@SubContainer`; canonical parent `\Self.member`; generated dependency protocol과 root-view helper |
| On-demand and effect metadata | analytics/network client의 `.onDemand`와 `.sideEffect`; deferred construction을 뜻하며 service shutdown을 대신하지 않습니다 |
| Overrides and prewarm | `DIAdvancedSurfaceTests`: shared copy cache, typed selective prewarm, optional nil의 `set(_:to:)`, live factory bypass |
| Async owned lifetime | 같은 tests: `makeOwned`, report의 `isReady`, `retryAndRequireReady`, value override, 반복 `close`, close 뒤 read 실패 |
| Collection | test fixture `@Multibinding`으로 contributor 순서와 shared/transient provider 합성 |
| Generated mocks | Domain의 test-only `@GenerateMock` + InnoDITesting. Sendable protocol의 call/stub storage를 generated locking으로 관리. generated shape는 experimental이며 production API로 노출하지 않습니다 |
| Validation | target macro diagnostics, DAG plugin, exact-release graph CLI, consumer build를 각각 실행 |

Async-owned fixture는 명시적인 readiness/retry/close 사용 예입니다. 앱의 동기 구성에는 이를 일괄 적용하지 않습니다. assisted factory, environment bridge, hosted child lifecycle은 현재 앱에 해당하는 runtime 요구가 없어 추가하지 않았습니다.

## InnoFlow surfaces

| Capability | Sample usage and verification |
| --- | --- |
| Feature authoring | 모든 production reducer와 clock fixture가 `@InnoFlow` + nested State/Action/body를 사용 |
| Phase ownership | production reducer는 `phaseManaged: true, strictPhaseTotality: true`; macro가 PhaseMap을 한 번 적용. body는 phase를 직접 변경하지 않음 |
| Error and cancellation | `.perform(operation:success:failure:)`와 domain별 cancellation ID, cancel-in-flight. throw된 error의 타입과 accepted cancellation을 구분 |
| Typed outputs | People의 openSettings / Settings의 openPeople는 `Self.output`; dispatch 전에 설치되는 bounded capture를 모델이 소비한 뒤 `finish()` |
| Persistent navigation intent | 데이터가 아직 없는 외부 detail ID, renderable selection/summary는 state에 보관. sibling event는 typed output으로 전달 |
| Case paths | Action/Output의 macro-generated paths를 PhaseMap과 exhaustive output assertions에 사용 |
| Bindable state | Settings의 `@BindableField`가 generated action을 제공. UI는 private Logic Store를 노출하지 않는 writable Observable model에 `@Bindable`을 적용하고 `$model.showsCompletedOnly`로 연결 |
| Instrumentation | People의 OSLog/signpost는 action payload를 redacted 상태로 기록 |
| Testing | send/receive/receiveOutput/finish를 exhaustive로 사용. phase는 reducer가 이미 적용하므로 test helper로 다시 적용하지 않음. ManualTestClock은 등록된 sleeper 수를 기다린 후 진행 |
| Regression | 완료된 초기 load 뒤 refresh 실패 시 onAppear가 effect 없이 loading phase로 바뀌지 않도록 resolver와 guard 검증 |

Scene callback은 navigation command를 보내며 business effect를 직접 수행하지 않습니다. typed output capture는 replay나 영구 queue가 아닙니다. 모델이 소비한 cross-feature request는 상위 coordinator가 한 번 가져갑니다.

## InnoRouter surfaces

| Capability | Sample usage and verification |
| --- | --- |
| Routes and destinations | 모든 destination/tab/link enum이 `@Router`; payload route는 Codable |
| Stack / tab / split | People/Settings는 RouterHost, Posts는 좁은 화면에서 RouterHost, 넓은 화면에서 RouterSplitHost. EntireTab은 generated routerTabs catalog로 native TabView를 조립. watchOS 분기는 stack |
| Throwing setup | Posts의 configured store/split host를 initializer의 Result에서 준비하고 body에서 setup failure를 표시. split closure에는 안정적인 `posts.list`/`posts.detail` declaration ID. compact 초기 column은 sidebar이고 선택은 detail scope의 stack을 바꾼 뒤 root preferredCompactColumn을 detail로 변경 |
| Stable tabs | `@TabItem(id:)`와 generated SampleTab.Tab을 선택 authority로 사용 |
| Action/state environment | `@EnvironmentRouter` focused action/dispatch; Settings는 `@EnvironmentRouterState`로 presentation 존재 확인 |
| Typed presentation | Digest의 `@PresentationResult(Bool.self)` generated request. completion(value), interactive dismissal, caller cancellation, rejection을 구분. failure UI와 acknowledgement action |
| Deep link | `@DeepLink` + scheme/host allowlist의 generated resolver. unknown path, missing/invalid payload, foreign origin을 거부 |
| State/draft/budget | 테스트에서 read-only RouterState의 별도 draft를 만들고 bounded build 실패와 원본 보존 검증. Posts는 explicit replaceHost로 compact/split 전환과 동일 store/detail history 보존을 검증 |
| Snapshot | PeopleRoute payload의 RouterSnapshotCodec round trip을 테스트. 앱 시작 시 디스크 복원 기능은 아직 없음 |
| Tests | RouterTestStore의 async send, started/committed, state, revision, finish. typed presentation의 caller cancellation, interactive dismissal, result 완료를 구분. Posts 양방향 host 전환 중 sheet state/revision/handle 보존과 최신 너비 우선 적용 검증 |

Host-less tests는 native sheet/tab/split 동작을 대신하지 않습니다. iPad mini를 세로·가로로 실제 회전하는 UI gate에서 상세 상태, Highlights, 닫기 권한과 상세 복귀를 검증합니다. 너비 관찰은 native detail에 가려지지 않는 탭 ancestor에 둡니다. scene/window/immersive driver, UIKit bridge, inspector, policy-deferred auth restoration은 이 sample의 현재 기능이 아닙니다.

RouterTabHost는 각 탭에 native NavigationStack을 만듭니다. 이 앱처럼 leaf feature가 이미 stack/split host를 소유할 때 그 밖에 RouterTabHost를 추가하면 중첩된 host가 탭 전환 중 child path를 초기화합니다. 따라서 production 탭 renderer는 generated `@Router`/`@TabItem` catalog와 `@Bindable` 선택을 소비하는 native TabView입니다. 별도의 tab enum이나 destination table을 수동으로 복제하지 않습니다.

## InnoNetwork surfaces

| Capability | Sample usage and verification |
| --- | --- |
| Endpoint macros | named GET와 test POST는 explicit struct + `@APIDefinition(method:path:auth:)`; 기본 Macros trait 유지 |
| Auth | anonymous / required 구분, `/todos`에만 token refresh/replay; mock single-flight와 401 replay 검사 |
| Resilience | bounded retry와 Retry-After clamp, unsafe POST는 idempotency key 없이 retry하지 않는 테스트 |
| Cache | RFC 9111 policy와 optional persistent cache; 안정적인 metadata header로 GET reuse 검증 |
| Operation | public OperationNetworkClient handle의 typed JSON value, expired deadline의 pre-transport failure, shutdown의 terminal cancellation |
| Encoded request | custom binary bytes의 explicit auth/content type, deferred encoder, request/response byte bound; JSON과 동일 operation path |
| Observability | secureDefault logger와 method/status/numeric code. raw URL, arbitrary error text, action payload를 public log에 남기지 않음 |
| Testing | MockURLSession / StubNetworkClient public products만 사용. package-internal/SPI clock/transport를 소비하지 않음 |

WebSocket/download/upload/OpenAPI/AWS/trust는 필요한 target이 선택하는 optional product입니다. InnoStream과 Protobuf는 별도 package/release입니다. 현재 People/Posts/Todos sample에 별도 서버나 미디어 lifecycle을 붙이지 않았으며 이 기능들의 소비/기기 검증을 완료했다고 주장하지 않습니다. InnoBase도 현재 의존성에 포함되지 않습니다.

## Verification contract

`make verify`는 install/generate → resolved revision → import boundary → exact-release DI DAG → Domain/Data/Remote/4 leaf feature/Layers/Features/Analytics/App macOS tests → generic iOS app/watch companion → macOS app build를 실행합니다. `make verify-ci`는 이 전체 gate 후 native iOS UI 회귀 테스트까지 실행합니다.

`make test-ui`는 최신 설치 runtime이 지원하는 전용 iPad mini를 선택하는 native gate입니다. `SIMULATOR_ID`로 다른 기기를 지정할 수 있으나 폭 전환 테스트는 iPad mini에서 실행해야 합니다. Debug `--uitesting`에서 generated root override로 fixture repository를 주입하며 실제 feature/reducer/router 구성은 유지합니다. CI는 `xcode-27` runner의 Xcode 27.1과 iOS 27.0 runtime을 고정하고 xcresult를 artifact로 보관합니다.

CLI는 repository의 기존 package/macro trust confirmation skip flags를 사용합니다. macro compiler와 graph validation은 실행됩니다. Xcode UI trust 승인, 실제 device 기능, CI remote 실행, merge/release는 별개의 확인 항목입니다.

### 2026-10-10 local results

- `make verify DERIVED_DATA=/tmp/innosample-latest-surface`와 `make test-ui`: 각각 exit 0.
- exact remote version/revision, SwiftSyntax 604.0.0, import boundary, DI DAG: 통과.
- 11개 macOS test suite, 총 86개 테스트: 통과.
- generic iOS 앱 + watchOS companion build, macOS 앱 build: 통과. signing은 비활성 상태이며 배포 검증이 아닙니다.
- iPad mini / iOS 27.0 native UI test 6개: 실패 0, skip 0, 216.744초, exit 0.
- UI gate: People → Settings → People, Posts 탭 왕복·compact/split 양방향 전환·Highlights와 Close 뒤 상세/Back, Settings filter·Digest Close와 제스처 종료를 검증.
- iPhone Duo / iOS 27.1 native hierarchy/screenshot: 실제 탭 왕복과 Closed/Open/Partially Open 전환, 활성 Highlights와 닫기 권한, 상세/Back 보존. InnoDI runtime 중복 class 경고 0건.

| macOS suite | Passed |
| --- | ---: |
| Domain | 7 |
| Data | 8 |
| Remote | 21 |
| PeopleFeature | 9 |
| PostsFeature | 10 |
| SettingsFeature | 10 |
| EntireTabFeature | 6 |
| Layers | 1 |
| Features | 9 |
| Analytics | 1 |
| InnoSampleAppUnitTests | 4 |

검증 증거는 ignored `.codex-artifacts/verify-posts-final.log`, `.codex-artifacts/ui-single-host-regression.log`, 해당 xcresult, `.codex-artifacts/posts-regression/device-single-host/`, `.codex-artifacts/posts-regression/verification-summary.json`에 있습니다. UI는 Debug fixture 경로를 사용합니다. live 서버/TLS, physical device, 원격 CI 실행, PR/merge/release는 이 local 결과에 포함되지 않습니다.
