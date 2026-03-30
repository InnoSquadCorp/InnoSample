# InnoSample Linkage Policy

기준일: 2026-03-24

이 문서는 현재 `InnoSample` 모듈들의 `framework` / `static library` 선택 기준을 짧게 고정하는 문서입니다.

## Policy

### Root Composition

- `Features`: framework
- `Layers`: framework

이 두 모듈은 여러 상위 타깃이 직접 소비하는 composition root 역할이라 dynamic artifact로 유지합니다.

### Shared Contract / Infrastructure

- `Domain`: framework
- `CoreNetwork`: framework
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

## Rationale

- shared contract는 여러 상위 모듈이 직접 import하므로 framework가 더 자연스럽습니다.
- leaf implementation은 공개 surface보다 구현 공유 비용이 작고, static으로 둘 때 링크 전략이 단순해집니다.
- `Layers` root는 과거 static일 때 duplicate-link 경고가 있었기 때문에 framework 유지가 baseline입니다.

## Known Issue

- `InnoRouterSwiftUI` duplicate class 경고는 아직 known issue입니다.
- 현재 구조에선 leaf 구현 타깃을 static으로 둬도, 공통 dynamic dependency 배치에 따라 경고가 남을 수 있습니다.
- 향후에는 truly shared dynamic artifact 전략 또는 더 엄격한 static/dynamic 재배치를 검토할 수 있습니다.
