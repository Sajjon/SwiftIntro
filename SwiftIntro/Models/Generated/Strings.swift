// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable function_parameter_count identifier_name line_length type_body_length
internal enum L10n {
  /// %d
  internal static func clickScore(_ p1: Int) -> String {
    return L10n.tr("Localizable", "ClickScore", p1, fallback: "%d")
  }
  /// n00b
  internal static let easy = L10n.tr("Localizable", "Easy", fallback: "n00b")
  /// You made it ^__^,
  /// your click count was:
  internal static let gameOverSubtitle = L10n.tr("Localizable", "GameOverSubtitle", fallback: "You made it ^__^,\nyour click count was:")
  /// Well done!
  internal static let gameOverTitle = L10n.tr("Localizable", "GameOverTitle", fallback: "Well done!")
  /// Kick-Ass
  internal static let hard = L10n.tr("Localizable", "Hard", fallback: "Kick-Ass")
  /// How good are you at memory?
  internal static let level = L10n.tr("Localizable", "Level", fallback: "How good are you at memory?")
  /// Loading...
  internal static let loading = L10n.tr("Localizable", "Loading", fallback: "Loading...")
  /// A-OK!
  internal static let normal = L10n.tr("Localizable", "Normal", fallback: "A-OK!")
  /// Pairs found %d of %d
  internal static func pairsFoundUnformatted(_ p1: Int, _ p2: Int) -> String {
    return L10n.tr("Localizable", "PairsFoundUnformatted", p1, p2, fallback: "Pairs found %d of %d")
  }
  /// Quit
  internal static let quit = L10n.tr("Localizable", "Quit", fallback: "Quit")
  /// Restart
  internal static let restart = L10n.tr("Localizable", "Restart", fallback: "Restart")
  /// Play!
  internal static let startGame = L10n.tr("Localizable", "StartGame", fallback: "Play!")
  /// my first memory
  internal static let title = L10n.tr("Localizable", "Title", fallback: "my first memory")
  /// Lets try to get an
  /// even better score!
  internal static let tryHarder = L10n.tr("Localizable", "TryHarder", fallback: "Lets try to get an\neven better score!")
  /// Search for images:
  internal static let username = L10n.tr("Localizable", "Username", fallback: "Search for images:")
  /// e.g. cats, mountains, space
  internal static let usernamePlaceholder = L10n.tr("Localizable", "UsernamePlaceholder", fallback: "e.g. cats, mountains, space")
}
// swiftlint:enable function_parameter_count identifier_name line_length type_body_length

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
