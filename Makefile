SHELL := /bin/bash

ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
WORKSPACE := $(ROOT)/InnoSample.xcworkspace
DERIVED_DATA ?= /tmp/innosample-make
PACKAGE_VALIDATION_FLAGS := -skipPackagePluginValidation -skipMacroValidation

.PHONY: help install-dependencies generate open verify-versions verify-boundaries verify-di test-domain test-data test-remote test-leaf-features test-layers test-features test-analytics test-app test-ui build-app build-macos verify-ci verify

help:
	@echo "Available targets:"
	@echo "  make install-dependencies # Resolve Tuist package dependencies"
	@echo "  make generate             # Regenerate Tuist workspace/projects"
	@echo "  make open                 # Open the generated workspace"
	@echo "  make verify-boundaries    # Check layer import boundaries"
	@echo "  make verify-di            # Validate InnoDI container DAG"
	@echo "  make verify-versions      # Verify exact release revisions in the resolved graph"
	@echo "  make test-domain          # Run Domain tests"
	@echo "  make test-data            # Run Data tests"
	@echo "  make test-remote          # Run Remote tests"
	@echo "  make test-leaf-features   # Run People/Posts/Settings/EntireTab feature tests"
	@echo "  make test-layers          # Run Layers tests"
	@echo "  make test-features        # Run root Features tests"
	@echo "  make test-app             # Run InnoSampleApp macOS tests"
	@echo "  make test-analytics       # Run the Analytics wrapper tests"
	@echo "  make test-ui              # Run native UI regressions on a dedicated iPad mini"
	@echo "  make build-app            # Build InnoSampleApp for iOS"
	@echo "  make verify-ci            # Run the CI gate used by pull requests"
	@echo "  make verify               # Run the full local gate"

install-dependencies:
	cd "$(ROOT)" && tuist install

generate:
	cd "$(ROOT)" && tuist generate --no-open

open:
	open "$(WORKSPACE)"

verify-boundaries:
	cd "$(ROOT)" && ./Scripts/check-layer-boundaries.sh

verify-di:
	cd "$(ROOT)" && ./Scripts/check-di-graph.sh validate

verify-versions:
	cd "$(ROOT)" && python3 ./Scripts/check-library-versions.py

test-domain:
	cd "$(ROOT)" && xcodebuild $(PACKAGE_VALIDATION_FLAGS) -workspace "$(WORKSPACE)" -scheme Domain -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)" test

test-data:
	cd "$(ROOT)" && xcodebuild $(PACKAGE_VALIDATION_FLAGS) -workspace "$(WORKSPACE)" -scheme Data -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)" test

test-remote:
	cd "$(ROOT)" && xcodebuild $(PACKAGE_VALIDATION_FLAGS) -workspace "$(WORKSPACE)" -scheme Remote -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)" test

test-leaf-features:
	cd "$(ROOT)" && xcodebuild $(PACKAGE_VALIDATION_FLAGS) -workspace "$(WORKSPACE)" -scheme PeopleFeature -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)" test
	cd "$(ROOT)" && xcodebuild $(PACKAGE_VALIDATION_FLAGS) -workspace "$(WORKSPACE)" -scheme PostsFeature -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)" test
	cd "$(ROOT)" && xcodebuild $(PACKAGE_VALIDATION_FLAGS) -workspace "$(WORKSPACE)" -scheme SettingsFeature -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)" test
	cd "$(ROOT)" && xcodebuild $(PACKAGE_VALIDATION_FLAGS) -workspace "$(WORKSPACE)" -scheme EntireTabFeature -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)" test

test-layers:
	cd "$(ROOT)" && xcodebuild $(PACKAGE_VALIDATION_FLAGS) -workspace "$(WORKSPACE)" -scheme Layers -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)" test

test-features:
	cd "$(ROOT)" && xcodebuild $(PACKAGE_VALIDATION_FLAGS) -workspace "$(WORKSPACE)" -scheme Features -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)" test

test-app:
	cd "$(ROOT)" && xcodebuild $(PACKAGE_VALIDATION_FLAGS) -workspace "$(WORKSPACE)" -scheme InnoSampleAppUnitTests -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)" test

test-analytics:
	cd "$(ROOT)" && xcodebuild $(PACKAGE_VALIDATION_FLAGS) -workspace "$(WORKSPACE)" -scheme Analytics -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)" test

test-ui:
	cd "$(ROOT)" && SIMULATOR_ID="$(SIMULATOR_ID)" DERIVED_DATA="$(DERIVED_DATA)" ./Scripts/run-ui-tests.sh

build-app:
	cd "$(ROOT)" && xcodebuild $(PACKAGE_VALIDATION_FLAGS) -workspace "$(WORKSPACE)" -scheme InnoSampleApp -destination 'generic/platform=iOS' -derivedDataPath "$(DERIVED_DATA)" build

build-macos:
	cd "$(ROOT)" && xcodebuild $(PACKAGE_VALIDATION_FLAGS) -workspace "$(WORKSPACE)" -scheme InnoSampleApp -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)" build

verify-ci: verify
	$(MAKE) test-ui DERIVED_DATA="$(DERIVED_DATA)"

verify: install-dependencies generate verify-versions verify-boundaries verify-di test-domain test-data test-remote test-leaf-features test-layers test-features test-analytics test-app build-app build-macos
