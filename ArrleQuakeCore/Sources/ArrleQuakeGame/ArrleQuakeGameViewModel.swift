import SwiftUI

final class StateViewModel: ObservableObject {
    enum State {
        case mainMenu
        case game
        case pause
    }

    @Published private(set) var state: State = .mainMenu

    func setState(_ state: State) {
        if state != self.state {
            withAnimation {
                self.state = state
            }
        }
    }
}

public final class ArrleQuakeGameViewModel: ObservableObject, IGameControl {
    @Published var image: Image? = nil

    let game: ArrleQuakeGame
    let state: StateViewModel = .init()

    public init(game: ArrleQuakeGame) {
        self.game = game
        DispatchQueue.main.async {
            self.loop()
        }
    }

    public func loop() {
        if let image = game.loop() {
            #if canImport(UIKit)
            self.image = Image(uiImage: UIImage(cgImage: image))
            #else
            self.image = Image(nsImage: NSImage(cgImage: image, size: .init(width: image.width, height: image.height)))
            #endif
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 / 30.0) {
            self.loop()
        }
    }

    func pause() {
        state.setState(.pause)
    }

    func move(_ point: CGPoint) {
        game.move(point)
    }

    func rotate(_ point: CGPoint) {
        game.rotate(point)
    }

    func gun(_ down: Bool) {
        game.gun(down: down)
    }
}
