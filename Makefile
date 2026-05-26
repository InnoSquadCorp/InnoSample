SHELL := /bin/bash

ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
WORKSPACE := $(ROOT)/InnoSample.xcworkspace
DERIVED_DATA ?= /tmp/innosample-make

.PHONY: help install-dependencies generate open verify-boundaries verify-di test-domain test-data test-remote test-leaf-features test-layers test-features test-app build-app verify-ci verify

help:
	@echo "Available targets:"
	@echo "  make install-dependencies # Resolve Tuist package dependencies"
	@echo "  make generate             # Regenerate Tuist workspace/projects"
	@echo "  make open                 # Open the generated workspace"
	@echo "  make verify-boundaries    # Check layer import boundaries"
	@echo "  make verify-di            # Validate InnoDI container DAG"
	@echo "  make test-domain          # Run Domain tests"
	@echo "  make test-data            # Run Data tests"
	@echo "  make test-remote          # Run Remote tests"
	@echo "  make test-leaf-features   # Run People/Posts/Settings/EntireTab feature tests"
	@echo "  make test-layers          # Run Layers tests"
	@echo "  make test-features        # Run root Features tests"
	@echo "  make test-app             # Run InnoSampleApp macOS tests"
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

test-domain:
	cd "$(ROOT)" && xcodebuild -workspace "$(WORKSPACE)" -scheme Domain -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)/Domain" test

test-data:
	cd "$(ROOT)" && xcodebuild -workspace "$(WORKSPACE)" -scheme Data -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)/Data" test

test-remote:
	cd "$(ROOT)" && xcodebuild -workspace "$(WORKSPACE)" -scheme Remote -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)/Remote" test

test-leaf-features:
	cd "$(ROOT)" && xcodebuild -workspace "$(WORKSPACE)" -scheme PeopleFeature -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)/PeopleFeature" test
	cd "$(ROOT)" && xcodebuild -workspace "$(WORKSPACE)" -scheme PostsFeature -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)/PostsFeature" test
	cd "$(ROOT)" && xcodebuild -workspace "$(WORKSPACE)" -scheme SettingsFeature -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)/SettingsFeature" test
	cd "$(ROOT)" && xcodebuild -workspace "$(WORKSPACE)" -scheme EntireTabFeature -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)/EntireTabFeature" test

test-layers:
	cd "$(ROOT)" && xcodebuild -workspace "$(WORKSPACE)" -scheme Layers -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)/Layers" test

test-features:
	cd "$(ROOT)" && xcodebuild -workspace "$(WORKSPACE)" -scheme Features -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)/Features" test

test-app:
	cd "$(ROOT)" && xcodebuild -workspace "$(WORKSPACE)" -scheme InnoSampleApp -destination 'platform=macOS' -derivedDataPath "$(DERIVED_DATA)/InnoSampleAppTests" test

build-app:
	cd "$(ROOT)" && xcodebuild -workspace "$(WORKSPACE)" -scheme InnoSampleApp -destination 'generic/platform=iOS' -derivedDataPath "$(DERIVED_DATA)/InnoSampleAppBuild" build

verify-ci: install-dependencies generate verify-boundaries verify-di test-remote test-leaf-features test-features build-app

verify: generate verify-boundaries verify-di test-domain test-data test-remote test-leaf-features test-layers test-features test-app build-app
