# Design and accessibility

FinTrack is intentionally small and native. Its hierarchy, controls, motion,
and accessibility behaviour follow Apple platform conventions instead of
introducing a custom design system that users must learn.

## Liquid Glass

- Standard iOS 26 navigation bars, tab bars, menus, sheets, and alerts provide
  the system Liquid Glass treatment and adapt automatically to accessibility
  settings.
- Prominent Glass buttons are used only for the two primary actions: adding an
  expense or income.
- Content cards use semantic grouped backgrounds rather than extra glass
  layers, preserving hierarchy and legibility.
- There are no custom motion effects, so Reduce Motion does not remove needed
  context. System materials handle Reduce Transparency and Increase Contrast.

This follows Apple's guidance for
[adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass).

## Rising Track icon

The symbol combines an upward financial path, three milestones, and the
negative-space suggestion of an `F`. Its overlapping translucent bands echo
Liquid Glass without relying on small decorative detail.

The asset catalogue contains the iOS 26 default, dark, and tinted appearances:

| Appearance | Repository asset | Purpose |
| --- | --- | --- |
| Default/light | `branding/fintrack-logo-light.png` | Luminous background with blue/teal glass |
| Dark | `branding/fintrack-logo-dark.png` | Deep navy background with brighter edges |
| Tinted | `branding/fintrack-logo-tinted.png` | Monochrome source for tinted Home Screen styles |

The same default and dark artwork is available to the launch screen and About
screen through appearance-aware image sets. The source artwork is square,
full-bleed, and does not contain a baked rounded-corner mask, in line with
Apple's [app icon guidance](https://developer.apple.com/design/human-interface-guidelines/app-icons).

## Human Interface Guidelines checklist

- **Navigation:** Three familiar destinations use a native tab bar; pushed
  detail screens use standard back navigation.
- **Typography:** Text uses Dynamic Type. At accessibility sizes, dashboard
  metrics and actions switch from two columns to a single readable column.
- **Touch targets:** Primary buttons and editor controls are at least 44 points
  high; navigation controls use system hit regions.
- **Colour:** Semantic system colours support light and dark appearances. The
  income text colour has separate contrast-aware light and dark values, and
  colour is reinforced by labels and SF Symbols.
- **VoiceOver:** Balances, totals, and transactions expose complete spoken
  summaries rather than disconnected numbers.
- **Feedback:** Invalid input receives a clear alert; successful saves use a
  restrained system haptic.
- **Destructive actions:** Bulk deletion requires confirmation. Individual
  deletion uses the familiar trailing swipe action.
- **Privacy:** Transactions and categories remain on-device. The app requires
  no login, analytics permission, or network connection.
- **Adaptivity:** Layout uses safe areas, scroll views, automatic table sizing,
  current locale-aware dates, and system light/dark appearance.

The implementation is intended to align with Apple's
[accessibility guidance](https://developer.apple.com/design/human-interface-guidelines/accessibility)
and should continue to be checked with Accessibility Inspector and on physical
devices before an App Store release.
