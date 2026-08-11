# FinTrack

[![CI](https://github.com/ihormelashchenko/FinTrack/actions/workflows/ci.yml/badge.svg)](https://github.com/ihormelashchenko/FinTrack/actions/workflows/ci.yml)

FinTrack is a UIKit iOS app for recording income and expenses, monitoring a
running balance, and organising transactions by category.

> **Project status:** Currently paused. The repository remains buildable and documented, but no active feature development is planned.

Transaction data is held in memory for the current app session and is not
persisted between launches.

## Features

- Record income and expense transactions
- Track the current balance and latest transaction date
- Categorise transactions with built-in or custom categories
- Review and clear the in-session transaction log
- Choose a language and currency preference in the settings interface

## Screenshots

<p>
  <img src="https://user-images.githubusercontent.com/73532651/152638782-0de97282-0607-4883-beae-6f096f6e3ecc.png" width="220" alt="FinTrack balance and transaction entry screen">
  <img src="https://user-images.githubusercontent.com/73532651/152638780-c89faf40-e64e-41a3-9f6e-143ad4131380.png" width="220" alt="FinTrack transaction log screen">
  <img src="https://user-images.githubusercontent.com/73532651/152638778-96a04995-2d59-4822-899d-a629abb860e5.png" width="220" alt="FinTrack settings screen">
  <img src="https://user-images.githubusercontent.com/73532651/152638775-f88c5dab-0e6b-42a2-bc80-af5322b78a1a.png" width="220" alt="FinTrack custom category screen">
</p>

## Requirements

- macOS with Xcode 26 or later
- iOS 26 or later

## Run Locally

1. Clone the repository:

   ```sh
   git clone https://github.com/ihormelashchenko/FinTrack.git
   cd FinTrack
   ```

2. Open `FinTrack/FinTrack.xcodeproj` in Xcode.
3. Select the `FinTrack` scheme and an iPhone simulator or connected device.
4. Build and run the app.

The project has no third-party dependencies.

## Verify the Project

```sh
xcodebuild \
  -project FinTrack/FinTrack.xcodeproj \
  -scheme FinTrack \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

GitHub Actions runs the same build for pushes to `main` and for pull requests.

## Project structure

```text
FinTrack/
├── FinTrack.xcodeproj/
└── FinTrack/
    ├── Assets.xcassets/
    ├── Base.lproj/
    ├── Settings/
    ├── Transaction/
    └── ViewControllers/
```

There is currently no automated test target; verification is performed by
compiling the shared `FinTrack` scheme.

## Author

Created by [Ihor Melashchenko](https://ihormelashchenko.com).
