import UIKit

enum AppTheme {
    /// The brighter value keeps black text legible on the tinted Liquid Glass button.
    static let incomeAccent = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.25, green: 0.82, blue: 0.88, alpha: 1)
            : UIColor(red: 0.20, green: 0.75, blue: 0.68, alpha: 1)
    }

    /// A deeper light-mode teal maintains contrast when the color is used for text.
    static let incomeText = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.38, green: 0.84, blue: 0.90, alpha: 1)
            : UIColor(red: 0.00, green: 0.38, blue: 0.34, alpha: 1)
    }
}

enum CurrencyOption: String, CaseIterable {
    case usd = "USD"
    case eur = "EUR"

    var title: String {
        switch self {
        case .usd: "US Dollar (USD)"
        case .eur: "Euro (EUR)"
        }
    }

    var localeIdentifier: String {
        switch self {
        case .usd: "en_US"
        case .eur: "en_IE"
        }
    }
}

enum AppearanceOption: String, CaseIterable {
    case system
    case light
    case dark

    var title: String {
        rawValue.capitalized
    }

    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: .unspecified
        case .light: .light
        case .dark: .dark
        }
    }
}

final class AppSettings {
    static let shared = AppSettings()
    static let didChangeNotification = Notification.Name("AppSettingsDidChange")

    private enum Key {
        static let currency = "fintrack.settings.currency"
        static let appearance = "fintrack.settings.appearance"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var currency: CurrencyOption {
        get {
            guard
                let rawValue = defaults.string(forKey: Key.currency),
                let value = CurrencyOption(rawValue: rawValue)
            else {
                return .usd
            }
            return value
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.currency)
            notify()
        }
    }

    var appearance: AppearanceOption {
        get {
            guard
                let rawValue = defaults.string(forKey: Key.appearance),
                let value = AppearanceOption(rawValue: rawValue)
            else {
                return .system
            }
            return value
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.appearance)
            applyAppearance()
            notify()
        }
    }

    func formatMoney(_ amount: Decimal, showSign: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        formatter.locale = Locale(identifier: currency.localeIdentifier)
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        let value = formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
        guard showSign, amount > 0 else { return value }
        return "+\(value)"
    }

    func applyAppearance() {
        let style = appearance.interfaceStyle
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .forEach { $0.overrideUserInterfaceStyle = style }
    }

    private func notify() {
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
    }
}
