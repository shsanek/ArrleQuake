import SwiftUI

#if canImport(UIKit)
import UIKit

final class KeyboardControllerVC: UIViewController {
    var game: ArrleQuakeGame

    init(game: ArrleQuakeGame) {
        self.game = game
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if var key = press.key?.keyCode {
                if key == .keyboardNonUSBackslash {
                    key = .keyboardEscape
                }
                game.pressed(key: key.rawValue, down: true)
            }
        }
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if var key = press.key?.keyCode {
                if key == .keyboardNonUSBackslash {
                    key = .keyboardEscape
                }
                game.pressed(key: key.rawValue, down: false)
            }
        }
    }
}

struct KeyboardController: UIViewControllerRepresentable {
    let game: ArrleQuakeGame

    func makeUIViewController(context: Self.Context) -> KeyboardControllerVC {
        .init(game: game)
    }

    func updateUIViewController(_ uiViewController: KeyboardControllerVC, context: Self.Context) {
        uiViewController.game = game
    }
}
#endif
