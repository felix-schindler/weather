# AGENTS.md

Guide for agents working in this repo — Oscar°, a SwiftUI weather app (iOS + Apple Watch).

## Project shape

- Single Xcode project, **no Package.swift**. Targets: `Oscar°` (app), `Oscar°Watch Watch App`, `Oscar°Widget`, `Oscar°WatchWidget`, `Oscar°Tests`.
- Swift 6.0, `SWIFT_STRICT_CONCURRENCY = complete`, deployment target iOS/watchOS 26.0. Expect Sendable/isolation errors to be real errors, not noise.
- Shared targets read/write state through the app group `group.cloud.bolte.Oscar` (`Oscar°/Storage/AppGroup.swift`). Anything widgets or Live Activities need at runtime must go through it.

## OpenAPI network code is generated

`Oscar°/Networking/openapi.yml` is the source of truth for the API client (Open-Meteo and the Oscar companion server). swift-openapi-generator is an Xcode **build plugin** — generated types are not committed. Never edit generated files; edit `openapi.yml` and the code regenerates on next build. Find "file not found: client types" style errors → just build again.

## Commands

```sh
# Build / unit tests (project has no SPM; use xcodebuild)
xcodebuild test -project Oscar°.xcodeproj -scheme "Oscar°" \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' -quiet
# Single test class:
xcodebuild test ... -only-testing:Oscar°Tests/OfflineCacheTests
```

- The `Oscar°` scheme launches with the `Oscar.storekit` StoreKit configuration (local IAP testing: `cloud.bolte.Oscar.supporter.{monthly,yearly}`, `cloud.bolte.Oscar.tip.{small,medium,large}`).
- Localizable strings are in `Localizable.xcstrings` / `InfoPlist.xcstrings` string catalogs, one shared catalog per target.

## Conventions

- There is no CLI/Makefile/SPM shortcut — verification means xcodebuild or Xcode. Unit tests live in `Oscar°Tests` (pure logic tests, fast, no simulator services needed).
- Commit style is conventional commits (`feat:`, `fix:`).
- The dark-only look is intentional; don't add light-mode branches.
