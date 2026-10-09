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

Coordinator와 feature Store는 container의 shared scope를 유지합니다. 같은 container를 다시 읽어도 새 navigation/business authority를 만들지 않습니다. People/Settings와 tab host는 default store가 navigation state를 소유합니다. Posts는 하나의 configured store를 명시적으로 소유합니다. 800pt 미만에서는 stack, 넓은 화면에서는 split으로 렌더링하고 `replaceHost`로 descriptor와 state를 함께 전환하며 detail history를 유지합니다. host와 detail scope는 같은 authority를 사용합니다. 모든 leaf coordinator 환경은 tab host의 공통 ancestor에 주입합니다.

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
| Bindable state | Settings의 `@BindableField`. UI는 private Logic Store를 노출하지 않는 model getter/action adapter를 통해 Binding 구성 |
| Instrumentation | People의 OSLog/signpost는 action payload를 redacted 상태로 기록 |
| Testing | send/receive/receiveOutput/finish를 exhaustive로 사용. phase는 reducer가 이미 적용하므로 test helper로 다시 적용하지 않음. ManualTestClock은 등록된 sleeper 수를 기다린 후 진행 |
| Regression | 완료된 초기 load 뒤 refresh 실패 시 onAppear가 effect 없이 loading phase로 바뀌지 않도록 resolver와 guard 검증 |

Scene callback은 navigation command를 보내며 business effect를 직접 수행하지 않습니다. typed output capture는 replay나 영구 queue가 아닙니다. 모델이 소비한 cross-feature request는 상위 coordinator가 한 번 가져갑니다.

## InnoRouter surfaces

| Capability | Sample usage and verification |
| --- | --- |
| Routes and destinations | 모든 destination/tab/link enum이 `@Router`; payload route는 Codable |
| Stack / tab / split | People/Settings는 RouterHost, EntireTab은 RouterTabHost, Posts는 좁은 화면에서 RouterHost, 넓은 화면에서 RouterSplitHost. watchOS 분기는 stack |
| Throwing setup | tab/split host를 initializer의 Result에서 준비하고 body에서 setup failure를 표시. split closure에는 안정적인 `posts.list`/`posts.detail` declaration ID. compact 초기 column은 sidebar이고 선택은 detail scope의 stack을 바꾼 뒤 root preferredCompactColumn을 detail로 변경 |
| Stable tabs | `@TabItem(id:)`와 generated SampleTab.Tab을 선택 authority로 사용 |
| Action/state environment | `@EnvironmentRouter` focused action/dispatch; Settings는 `@EnvironmentRouterState`로 presentation 존재 확인 |
| Typed presentation | Digest의 `@PresentationResult(Bool.self)` generated request. completion(value), interactive dismissal, caller cancellation, rejection을 구분. failure UI와 acknowledgement action |
| Deep link | `@DeepLink` + scheme/host allowlist의 generated resolver. unknown path, missing/invalid payload, foreign origin을 거부 |
| State/draft/budget | 테스트에서 read-only RouterState의 별도 draft를 만들고 bounded build 실패와 원본 보존 검증. Posts는 explicit replaceHost로 compact/split 전환과 동일 store/detail history 보존을 검증 |
| Snapshot | PeopleRoute payload의 RouterSnapshotCodec round trip을 테스트. 앱 시작 시 디스크 복원 기능은 아직 없음 |
| Tests | RouterTestStore의 async send, started/committed, state, revision, finish. typed presentation의 caller cancellation과 result 완료도 검증 |

Host-less tests는 native sheet/tab/split 동작을 대신하지 않습니다. 현재 iOS 27.1에서 compact detail을 띄운 채 펼치면 상세는 stack으로 유지되고, root를 다시 드러낸 뒤 wide split으로 전환됩니다. 이 native lifecycle 경계는 UI 검증에서 확인했으며, 상세와 뒤로 가기 이력은 양쪽 전환에서 보존됩니다. deterministic UI test와 screenshot/hierarchy 검증을 별도로 수행합니다. scene/window/immersive driver, UIKit bridge, inspector, policy-deferred auth restoration은 이 sample의 현재 기능이 아닙니다.

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

`make verify-ci`와 `make verify`는 같은 전체 gate입니다: install/generate → resolved revision → import boundary → exact-release DI DAG → Domain/Data/Remote/4 leaf feature/Layers/Features/Analytics/App macOS tests → generic iOS app/watch companion → macOS app build.

`make test-ui SIMULATOR_ID=<UDID>`는 별도의 iOS native gate입니다. Debug `--uitesting`에서 generated root override로 fixture repository를 주입하며 실제 feature/reducer/router 구성은 유지합니다.

CLI는 repository의 기존 package/macro trust confirmation skip flags를 사용합니다. macro compiler와 graph validation은 실행됩니다. Xcode UI trust 승인, 실제 device 기능, CI remote 실행, merge/release는 별개의 확인 항목입니다.

### 2026-10-10 local results

- `make verify-ci DERIVED_DATA=/tmp/innosample-latest-surface`: exit 0.
- exact remote version/revision, SwiftSyntax 604.0.0, import boundary, DI DAG: 통과.
- 11개 macOS test suite, 총 81개 테스트: 통과.
- generic iOS 앱 + watchOS companion build, macOS 앱 build: 통과. signing은 비활성 상태이며 배포 검증이 아닙니다.
- 같은 iOS 27.1 시뮬레이터의 native UI test 3개: 실패 0, 77.405초, exit 0.
- 별도 native hierarchy/screenshot으로 compact Posts, wide split, 상세 이력 보존, Closed 복귀, Settings 필터 확인.
- active compact detail에서 펼친 직후에는 stack을 유지하고 root가 다시 드러나면 split으로 전환되는 동작을 확인.

| macOS suite | Passed |
| --- | ---: |
| Domain | 7 |
| Data | 8 |
| Remote | 21 |
| PeopleFeature | 9 |
| PostsFeature | 6 |
| SettingsFeature | 9 |
| EntireTabFeature | 6 |
| Layers | 1 |
| Features | 9 |
| Analytics | 1 |
| InnoSampleAppUnitTests | 4 |

검증 증거는 ignored `.codex-artifacts/verify-ci-final.log`, `.codex-artifacts/device/ui-tests-confirmed.log`, `.codex-artifacts/verification-summary.json`에 있습니다. UI는 Debug fixture 경로를 사용합니다. live 서버/TLS, physical device, 원격 CI 실행, PR/merge/release는 이 local 결과에 포함되지 않습니다.
