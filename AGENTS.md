# AGENTS.md

Guide for agents working in this repo — Felix°, a SwiftUI weather app (iOS + Apple Watch).

## Project shape

- Single Xcode project, **no Package.swift**. Targets: `Felix°` (app), `Felix°Watch Watch App`, `Felix°Widget`, `Felix°WatchWidget`, `Felix°Tests`.
- The user-facing app name is `Felix°` in every language (CFBundleName/DisplayName). Targets and products stay `Felix°`; the app Swift module is `Felix` (PRODUCT_MODULE_NAME — `°` is not a valid identifier character).
- Swift 6.0, `SWIFT_STRICT_CONCURRENCY = complete`, deployment target iOS/watchOS 26.0. Expect Sendable/isolation errors to be real errors, not noise.
- Shared targets read/write state through the app group `group.de.schindlerfelix.weather` (`Felix°/Storage/AppGroup.swift`). Anything widgets or Live Activities need at runtime must go through it.

## OpenAPI network code is generated

`Felix°/Networking/openapi.yml` is the source of truth for the API client (Open-Meteo). swift-openapi-generator is an Xcode **build plugin** — generated types are not committed. Never edit generated files; edit `openapi.yml` and the code regenerates on the next build. "file not found: client types" style errors usually mean a stale build — ask the human to build again.

## Never build or run the app

**Do not build, test, or run this app yourself.** The human owns all builds and runs and will paste back the error messages, logs, screenshots, and test output you need. That means:

- No `xcodebuild` (build, test, archive, resolve, etc.), no Xcode, no simulator boot, no launching the app, widgets, or previews, and no `swift`/`swiftc` compilation checks.
- Do not install tooling or work around the restriction (e.g. a temporary `Package.swift`, `swift build`, or CI pipeline) to compile anything.
- When a change needs verification, ask for it: request the specific error text, screenshot, or test result, and keep editing until the human reports it green.

Repo facts you may still rely on:

- Unit tests live in `Felix°Tests` (pure logic tests) and are run by the human.
- Local IAP testing uses the supporter/tip products under `de.schindlerfelix.weather` (`supporter.{monthly,yearly}`, `tip.{small,medium,large}`).
- Localizable strings are in `Localizable.xcstrings` / `InfoPlist.xcstrings` string catalogs, one shared catalog per target.

## Conventions

- Verification only happens through the human's build/test run (there is no CLI/Makefile/SPM shortcut and you must not create one). Write code that you are confident in by inspection, then ask for the build result.
- Commit style is conventional commits (`feat:`, `fix:`).
- Light and dark appearance are both supported on iOS — never hard-code dark-only colours. Prefer semantic styles (`.primary`, `.secondary`, `.systemBackground`) or `Color.adaptiveGray(dark:light:)`, and branch on `colorScheme` only where contrast demands it (chart labels, widget symbols). Only the Watch app is dark-only (`.preferredColorScheme(.dark)` in `WatchRootView`); widgets follow the system appearance and cannot opt out of it.
