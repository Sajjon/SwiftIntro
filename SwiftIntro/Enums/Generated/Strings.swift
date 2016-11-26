// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation

// swiftlint:disable file_length
// swiftlint:disable type_body_length
enum L10n {
  /// my first memory
  case title
  /// Play!
  case startGame
  /// How good are you at memory?
  case level
  /// username
  case usernamePlaceholder
  /// What's your Instagram username?
  case username
  /// n00b
  case easy
  /// A-OK!
  case normal
  /// Kick-Ass
  case hard
  /// Pairs found %d of %d
  case pairsFoundUnformatted(Int, Int)
  /// Well done!
  case gameOverTitle
  /// You made it ^__^,\nyour click count was:
  case gameOverSubtitle
  /// %d
  case clickScore(Int)
  /// Lets try to get an\neven better score!
  case tryHarder
  /// Quit
  case quit
  /// Restart
  case restart
  /// Loading...
  case loading
}
// swiftlint:enable type_body_length

extension L10n: CustomStringConvertible {
  var description: String { return self.string }

  var string: String {
    switch self {
      case .title:
        return L10n.tr(key: "Title")
      case .startGame:
        return L10n.tr(key: "StartGame")
      case .level:
        return L10n.tr(key: "Level")
      case .usernamePlaceholder:
        return L10n.tr(key: "UsernamePlaceholder")
      case .username:
        return L10n.tr(key: "Username")
      case .easy:
        return L10n.tr(key: "Easy")
      case .normal:
        return L10n.tr(key: "Normal")
      case .hard:
        return L10n.tr(key: "Hard")
      case .pairsFoundUnformatted(let p0, let p1):
        return L10n.tr(key: "PairsFoundUnformatted", p0, p1)
      case .gameOverTitle:
        return L10n.tr(key: "GameOverTitle")
      case .gameOverSubtitle:
        return L10n.tr(key: "GameOverSubtitle")
      case .clickScore(let p0):
        return L10n.tr(key: "ClickScore", p0)
      case .tryHarder:
        return L10n.tr(key: "TryHarder")
      case .quit:
        return L10n.tr(key: "Quit")
      case .restart:
        return L10n.tr(key: "Restart")
      case .loading:
        return L10n.tr(key: "Loading")
    }
  }

  private static func tr(key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

func tr(key: L10n) -> String {
  return key.string
}
