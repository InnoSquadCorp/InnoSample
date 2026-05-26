# InnoSample Linkage Policy

기준일: 2026-05-26

이 문서는 현재 `InnoSample` 모듈들의 `framework` / `static library` 선택 기준을 짧게 고정하는 문서입니다.

## Policy

### Root Composition

- `Features`: framework
- `Layers`: framework

이 두 모듈은 여러 상위 타깃이 직접 소비하는 composition root 역할이라 dynamic artifact로 유지합니다.

### Shared Contract / Infrastructure

- `Domain`: framework
- `AnalyticsInterface`: framework

이 모듈들은 여러 상위 모듈이 직접 소비하는 shared 계약 또는 공용 인프라입니다.
특히 `Domain`은 leaf feature와 root `Features`가 함께 소비하므로 shared framework가 더 안전합니다.

### Leaf Implementation

- `Data`: static library
- `Remote`: static library
- `FeatureLogic`: static library
- `FeatureUI`: static library
- `FeatureRouter`: static library
- `FeatureTesting`: static library
- `Analytics`: static library

이 모듈들은 구현체에 가깝고 상위 composition이 조립하는 leaf입니다.
가능한 한 static으로 두어 duplication과 런타임 중복 로드 위험을 줄입니다.
`Remote`는 외부 API 호출 정책과 InnoNetwork client 조립을 소유하지만, 소비자는 `Data`의 remote data source contract만 봅니다.

## Rationale

- shared contract는 여러 상위 모듈이 직접 import하므로 framework가 더 자연스럽습니다.
- leaf implementation은 공개 surface보다 구현 공유 비용이 작고, static으로 둘 때 링크 전략이 단순해집니다.
- `Layers` root는 과거 static일 때 duplicate-link 경고가 있었기 때문에 framework 유지가 baseline입니다.

## External Package Product Types

`Tuist/Package.swift`의 `PackageSettings.productTypes`는 Inno 계열 SPM product 중 **여러 leaf 모듈이 직접 또는 transitively 소비하는 runtime product를 `.framework`로 승격**합니다.

- `InnoDI`, `InnoDISwiftUI`
- `InnoFlow`
- `InnoNetwork`, `InnoNetworkPersistentCache`
- `InnoRouter`, `InnoRouterCore`, `InnoRouterSwiftUI`, `InnoRouterDeepLink`

이유는 다음과 같습니다.

- `InnoRouter` umbrella는 `InnoRouterCore / InnoRouterSwiftUI / InnoRouterDeepLink`에 의존합니다.
- umbrella만 `.framework`로 두면 sub-target은 Tuist 기본값 `.staticFramework`로 빌드돼, dynamic umbrella가 sub-target 심볼을 정적 임베드합니다.
- leaf `*Router` static library가 `import InnoRouter` 만 하더라도, umbrella의 `@_exported import`를 따라가면서 InnoRouterSwiftUI 심볼을 다시 정적으로 끌어옵니다.
- 결과적으로 같은 ObjC class / Swift metadata가 dynamic umbrella 내부 사본과 leaf static 사본 양쪽에 등록돼 “Class is implemented in both …” warning이 발생합니다.
- sub-product를 함께 `.framework`로 승격하면 각자 단일 dynamic artifact가 되어 dyld가 한 번만 로드합니다.

예외:

- `InnoDICore`: `.staticLibrary`
  - `InnoDIMacros` Swift macro target이 `InnoDICore`에 의존하므로, Tuist graph에서는 macro target이 dynamic framework에 의존하지 않도록 core product를 static으로 둡니다.
  - `InnoDI` umbrella와 `InnoDISwiftUI`는 앱/feature runtime에서 직접 import되는 surface라 `.framework` 유지가 기준입니다.
- macro/codegen product:
  - route enum은 `InnoRouterMacros`의 `@Routable`을 사용하지만, macro target은 build-time toolchain surface라 runtime duplicate-link 문제의 대상이 아닙니다.
  - `InnoNetworkCodegen`은 현재 샘플의 pinned root package에서 runtime/public product로 소비하지 않으므로 productTypes에 추가하지 않습니다.

## Known Issue

- 현재 알려진 link warning 없음. `InnoRouterSwiftUI` duplicate class warning은 위 ProductTypes 조정으로 해소되었습니다.
- 새로운 Inno 계열 runtime sub-product를 import 하거나 transitively 의존하게 되면, 같은 패턴으로 `productTypes`에 `.framework`로 추가해야 합니다.
- macro target이 직접 소비하는 helper/core product는 dynamic 승격 전에 Tuist graph lint를 먼저 확인해야 합니다.
