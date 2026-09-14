# iOS compatibility verification

Verification date: 15 September 2026.

## Support and toolchain

- Minimum deployment target: iOS 26.0 for the project, app, and test targets.
- Xcode 27.0, build 27A266a; iOS and iOS Simulator SDK 27.0.
- Host: macOS 27.0, build 26A428, Apple silicon.
- iOS 27 test device: iPhone 18 Pro, runtime 27.0 (24A434).
- iOS 26 test device: iPhone 17 Pro, runtime 26.5 (23F77).

## Compatibility change

The overview now observes its preferred-content-size trait directly and applies
its adaptive layout when appearing. Previously, changing text size while the
screen was open could leave the action buttons side by side at accessibility
sizes, wrapping their titles into narrow columns. The buttons and totals now
stack vertically, and return to a horizontal layout at standard text sizes.

A regression test changes text size on a visible overview and checks button
positions and widths in both directions. No iOS 27-only APIs, data-format changes,
or third-party dependencies were introduced.

## Build results

All four Xcode 27 builds passed with code signing disabled:

| Configuration | Device | Simulator |
| --- | --- | --- |
| Debug | Passed | Passed |
| Release | Passed | Passed |

## Runtime verification

- iOS 27.0: **7 passed, 0 failed, 0 skipped** using Xcode 27.
  Four finance-store tests, one live text-size layout regression, and two UI tests.
- iOS 26.5: **7 passed, 0 failed, 0 skipped** using the same Xcode 27 build.
  The first simulator boot reported a data-migration failure. After restarting
  and successfully launching the app, the complete suite passed.

Local result bundles on the verification machine:

- iOS 27: `/private/tmp/fintrack-ios27-serial.xcresult`
- iOS 26: `/private/tmp/fintrack-ios26-retry.xcresult`

Build logs use `/private/tmp/fintrack-final-*.log`. These are local verification
artifacts, not repository files.

## Visual and accessibility checks

Reviewed iOS 27 screenshots of the overview, transaction editor sheet, activity,
custom categories, and settings in light and dark appearances. Confirmed euro
formatting on the overview and system appearance changes. Confirmed that changing
to the largest accessibility text size while the overview is open stacks its
actions and totals vertically; returning to standard text restores the row layout.

The interface tests exercise decimal-keyboard entry, persistence across relaunch,
editing, deletion, appearance selection, and custom-category creation. Accessibility
labels expose balance and transaction summaries, including signed amounts.

A full spoken VoiceOver navigation review and physical-device testing remain
outstanding. Screenshot inspection and accessible labels do not establish those
checks. An exploratory UI test at the largest text size could not find the system
“Select All” menu item; the standard-size suite and the dedicated live text-size
regression are reported separately rather than claiming full large-text UI coverage.

## CI

The existing GitHub Actions workflow remains unchanged. It uses the default
Xcode on `macos-26` to build for a generic simulator. Its success does not establish
which iOS SDK was used or prove runtime compatibility with iOS 27. Use the explicit
simulator destinations in the README to repeat both runtime checks.
