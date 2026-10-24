# AGENTS.md

Guide for agents working in this repo — Oscar°, a SwiftUI weather app (iOS + Apple Watch).

## Project shape

- Single Xcode project, **no Package.swift**. Targets: `Oscar°` (app), `Oscar°Watch Watch App`, `Oscar°Widget`, `Oscar°WatchWidget`, `Oscar°Tests`, `Oscar°UITests`, plus a `Oscar°Screenshots` UI-test target used only for App Store screenshots.
- Swift 6.0, `SWIFT_STRICT_CONCURRENCY = complete`, deployment target iOS/watchOS 26.0. Expect Sendable/isolation errors to be real errors, not noise.
- Shared targets read/write state through the app group `group.cloud.bolte.Oscar` (`Oscar°/Storage/AppGroup.swift`). Anything widgets or Live Activities need at runtime must go through it.

## OpenAPI network code is generated

`Oscar°/Networking/openapi.yml` is the source of truth for the API client (Open-Meteo and the Oscar companion server). swift-openapi-generator is an Xcode **build plugin** — generated types are not committed. Never edit generated files; edit `openapi.yml` and the code regenerates on next build. Find "file not found: client types" style errors → just build again.

## Commands

```sh
# Build / unit tests (project has no SPM; use xcodebuild)
xcodebuild test -project Oscar°.xcodeproj -scheme "Oscar°" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -quiet
# Single test class:
xcodebuild test ... -only-testing:Oscar°Tests/OfflineCacheTests
```

- The `Oscar°` scheme launches with the `Oscar.storekit` StoreKit configuration (local IAP testing: `cloud.bolte.Oscar.supporter.{monthly,yearly}`, `cloud.bolte.Oscar.tip.{small,medium,large}`).
- Localizable strings are in `Localizable.xcstrings` / `InfoPlist.xcstrings` string catalogs, one shared catalog per target.

## Screenshot / fastlane pipeline (read before touching)

- **Always run it through `bin/screenshots.sh`, never `fastlane snapshot` directly.** snapshot is configured `test_without_building`; only `bin/screenshots.sh` does the single up-front `build-for-testing` into `fastlane/derived_data` that all language passes reuse, and it sets `DEVELOPER_DIR` to the current Xcode.
- `--skip-build` is valid only with zero code changes — screenshot fixtures are **compiled into the app** (`Oscar°/Debug/Screenshots`).
- Live Activity consent (`com.apple.liveactivitiesd`) and fresh-install behavior: the script resets consent and reinstalls per language pass; don't bypass.
- Snapfile pins **stable** iOS runtime (bump `ios_version`/device names when installing a new stable runtime) because snapshot cold-boots a simulator per pass and beta runtimes cost tens of minutes of silent preparation.
- Lanes: `bin/screenshots.sh [locale]`, `bin/frame-compose.sh` (re-frame only), `fastlane upload_screenshots` (needs `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_PATH`; mirrors en-US to en-GB/CA/AU itself).

## Conventions

- There is no CLI/Makefile/SPM shortcut — verification means xcodebuild or Xcode. Unit tests live in `Oscar°Tests` (pure logic tests, fast, no simulator services needed).
- Commit style is conventional commits (`feat:`, `fix:`).
- The dark-only look is intentional (see Snapfile note); don't add light-mode branches.
