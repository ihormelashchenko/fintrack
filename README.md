# FinTrack

[![CI](https://github.com/ihormelashchenko/FinTrack/actions/workflows/ci.yml/badge.svg)](https://github.com/ihormelashchenko/FinTrack/actions/workflows/ci.yml)

FinTrack is a focused UIKit app for recording everyday income and expenses. It
provides a clear running balance, a persistent transaction history, flexible
categories, and a native interface supporting iOS 26 and iOS 27.

> **Project status:** Currently paused. The repository remains buildable and documented, but no active feature development is planned.

## What it does

- Records income and expense transactions with an amount, category, and date
- Persists transaction history and custom categories between launches
- Shows the current balance, income, expenses, and recent activity at a glance
- Supports editing, swipe-to-delete, and confirmed bulk deletion
- Includes built-in categories and user-created categories
- Formats values in US dollars or euros
- Follows the system appearance by default, with optional Light and Dark modes
- Keeps all finance data locally on the device

## Native iOS design

FinTrack uses standard UIKit navigation, tab bars, menus, sheets, alerts, SF
Symbols, semantic colours, and Dynamic Type. Liquid Glass is reserved for the
primary transaction actions and system navigation layer so the content stays
clear and familiar.

The new Rising Track identity is supplied as an adaptive icon family:

<p>
  <img src="branding/fintrack-logo-light.png" width="150" alt="FinTrack Rising Track light icon">
  <img src="branding/fintrack-logo-dark.png" width="150" alt="FinTrack Rising Track dark icon">
  <img src="branding/fintrack-logo-tinted.png" width="150" alt="FinTrack Rising Track tinted icon">
</p>

- **Default/light:** translucent blue and teal glass on a luminous background
- **Dark:** a higher-luminance mark on deep midnight navy
- **Tinted:** a monochrome version for iOS tinted icon appearances

See [Design and accessibility](docs/design-and-accessibility.md) for the design
decisions and Human Interface Guidelines checklist.

## Screenshots

<p>
  <img src="docs/screenshots/overview.png" width="220" alt="FinTrack overview with a recorded income transaction">
  <img src="docs/screenshots/transaction-editor.png" width="220" alt="FinTrack new transaction editor">
  <img src="docs/screenshots/settings.png" width="220" alt="FinTrack settings in light mode">
  <img src="docs/screenshots/settings-dark.png" width="220" alt="FinTrack settings in dark mode">
</p>

## Requirements

- macOS with Xcode 27 for iOS 27 development and verification
- iOS 26 or later (the minimum deployment target remains iOS 26.0)

## Run locally

1. Clone the repository:

   ```sh
   git clone https://github.com/ihormelashchenko/FinTrack.git
   cd FinTrack
   ```

2. Open `FinTrack/FinTrack.xcodeproj` in Xcode.
3. Select the `FinTrack` scheme and an iPhone simulator or connected device.
4. Build and run the app.

The project has no third-party dependencies or account setup.

## Verify the project

Build for the simulator:

```sh
xcodebuild \
  -project FinTrack/FinTrack.xcodeproj \
  -scheme FinTrack \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Run the unit and interface tests on **both** an iOS 26 and an iOS 27 simulator.
List installed devices and choose a device identifier for each runtime:

```sh
xcrun simctl list devices available
xcodebuild \
  -project FinTrack/FinTrack.xcodeproj \
  -scheme FinTrack \
  -destination 'platform=iOS Simulator,id=<SIMULATOR-UUID>' \
  -parallel-testing-enabled NO \
  -derivedDataPath /tmp/fintrack-verification \
  -resultBundlePath '/tmp/fintrack-tests-<OS-VERSION>.xcresult' \
  CODE_SIGNING_ALLOWED=NO \
  test
```

Replace the placeholders and use a fresh result bundle path for each run. Install
missing runtimes through Xcode Settings > Components. For release verification,
repeat the build with `-configuration Release` and also build with
`-destination 'generic/platform=iOS'` for devices.

The shared scheme runs four finance-store tests, one live text-size layout
regression test, and two end-to-end interface tests. GitHub Actions builds using
the default Xcode on its `macos-26` runner; this does not by itself establish
iOS 27 runtime compatibility.

See [iOS compatibility verification](docs/ios-compatibility.md) for the tested
toolchain, results, and remaining checks.

## Project structure

```text
FinTrack/
├── branding/                         # Source logo appearances
├── docs/
│   ├── design-and-accessibility.md
│   └── screenshots/
└── FinTrack/
    ├── FinTrack.xcodeproj/
    ├── FinTrack/                     # UIKit app and adaptive assets
    ├── FinTrackTests/                # Finance model and persistence tests
    └── FinTrackUITests/              # Core user-flow tests
```

## Author

Created by [Ihor Melashchenko](https://ihormelashchenko.com).
