# AGENTS.md

Guide for agents working in this repo — Wetter, a SwiftUI weather app (iOS + Apple Watch).

## Project shape

- Single Xcode project, **no Package.swift**. Targets: `Wetter` (app), `WetterWatch Watch App`, `WetterWidget`, `WetterWatchWidget`, `WetterTests`.
- The user-facing app name is localized: `Wetter` (de), `Weather` (en), `天氣` (zh-Hant), `Tempo` (pt-BR). Targets and products stay `Wetter`.
- Swift 6.0, `SWIFT_STRICT_CONCURRENCY = complete`, deployment target iOS/watchOS 26.0. Expect Sendable/isolation errors to be real errors, not noise.
- Shared targets read/write state through the app group `group.weather.schindlerfelix.de` (`Wetter/Storage/AppGroup.swift`). Anything widgets or Live Activities need at runtime must go through it.

## OpenAPI network code is generated

`Wetter/Networking/openapi.yml` is the source of truth for the API client (Open-Meteo and the Oscar companion server). swift-openapi-generator is an Xcode **build plugin** — generated types are not committed. Never edit generated files; edit `openapi.yml` and the code regenerates on the next build. "file not found: client types" style errors usually mean a stale build — ask the human to build again.

## Never build or run the app

**Do not build, test, or run this app yourself.** The human owns all builds and runs and will paste back the error messages, logs, screenshots, and test output you need. That means:

- No `xcodebuild` (build, test, archive, resolve, etc.), no Xcode, no simulator boot, no launching the app, widgets, or previews, and no `swift`/`swiftc` compilation checks.
- Do not install tooling or work around the restriction (e.g. a temporary `Package.swift`, `swift build`, or CI pipeline) to compile anything.
- When a change needs verification, ask for it: request the specific error text, screenshot, or test result, and keep editing until the human reports it green.

Repo facts you may still rely on:

- Unit tests live in `WetterTests` (pure logic tests) and are run by the human.
- Local IAP testing uses the supporter/tip products under `weather.schindlerfelix.de` (`supporter.{monthly,yearly}`, `tip.{small,medium,large}`).
- Localizable strings are in `Localizable.xcstrings` / `InfoPlist.xcstrings` string catalogs, one shared catalog per target.

## Conventions

- Verification only happens through the human's build/test run (there is no CLI/Makefile/SPM shortcut and you must not create one). Write code that you are confident in by inspection, then ask for the build result.
- Commit style is conventional commits (`feat:`, `fix:`).
- The dark-only look is intentional; don't add light-mode branches.
