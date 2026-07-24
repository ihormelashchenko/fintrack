import Foundation

enum Settings {
    static let languages = ["English", "Spanish", "French", "German", "Italian"]
    static let currencies = ["(USD) US dollar", "(EUR) Euro"]
    static var selectedLanguage = languages[0]
    static var selectedCurrency = currencies[0]
}
