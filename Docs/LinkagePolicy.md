# InnoSample Linkage Policy

기준일: 2026-07-21

이 문서는 현재 `InnoSample` 모듈과 remote Swift package product의 linkage 기준을 고정합니다.

## Module Products

### Shared composition and contracts

- `Features`, `Layers`, `Domain`, `AnalyticsInterface`: framework

여러 상위 타깃이 직접 소비하는 composition root 또는 shared contract이므로 dynamic artifact로 유지합니다. 특히 `Domain`은 leaf feature, root Features, watch app이 함께 소비합니다.

### Leaf implementations

- `Data`, `Remote`
- 각 feature의 `Logic`, `UI`, `Router`, `Testing`
- `Analytics`

구현 leaf는 static library가 기본입니다. public runtime contract보다 composition 시점의 조립 대상에 가깝고, 단일 상위 그래프 안에서 링크 전략이 단순합니다.

## Remote Package Declaration

- exact package requirement는 `Tuist/ProjectDescriptionHelpers/Dependency/TargetDependency+.swift`에서 선언합니다.
- 각 `Project.swift`가 실제 필요한 package만 `packages:`에 추가합니다.
- `Tuist/Package.swift`의 dependency 목록과 `PackageSettings.productTypes`는 비워 둡니다. project-scoped package resolution에 별도 global linkage override를 겹치지 않습니다.
- generated `Package.resolved`는 추적하지 않으며, fresh generation에서 exact requirement를 다시 검증합니다.

## Macro and Plugin Products

- `InnoRouterMacros`는 `.macro` dependency로 연결된 compile-time surface입니다.
- `InnoDIDAGValidationPlugin`은 `.plugin` dependency로 연결된 build-tool surface입니다.
- `InnoFlowTesting`과 `InnoRouterTesting`은 test target에만 직접 연결합니다.

이 product들은 runtime duplicate-link 문제를 해결하기 위한 dynamic framework 승격 대상이 아닙니다. runtime product와 compile-time/test product를 manifest에서 명시적으로 구분합니다.

## Validation

- `tuist generate --no-open`으로 project-scoped package graph가 생성되는지 확인합니다.
- `make build-app`으로 generic iOS app의 runtime linkage와 duplicate symbol 여부를 확인합니다.
- `make test-leaf-features`로 testing product가 production target으로 새지 않고 test bundle에서만 링크되는지 확인합니다.
- package shape 또는 target product가 바뀌면 `make verify-ci` 전체 gate를 다시 실행합니다.

현재 baseline에는 알려진 InnoRouter duplicate-class 또는 duplicate-symbol warning이 없습니다. 새 runtime sub-product를 직접 추가할 때만 별도의 linkage override가 필요한지 실제 link 결과를 근거로 재평가합니다.
