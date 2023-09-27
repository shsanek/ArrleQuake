import SwiftUI

final class StateViewModel: ObservableObject {
    enum State {
        case mainMenu
        case game
        case pause
        case setting
    }

    static let canShowInterface: Bool = {
        #if os(macOS)
        return false
        #endif
        if ProcessInfo().isMacCatalystApp {
            return false
        }
        return true
    }()

    @Published var showInterface: Bool = StateViewModel.canShowInterface
    @Published private(set) var state: State = .mainMenu

    var states: [State] = [.mainMenu]

    private func update() {
        if let state = states.last, state != self.state {
            UIApplication.shared.isIdleTimerDisabled = state == .game
            withAnimation {
                self.state = state
            }
        }
    }

    func setState(_ state: State) {
        states = [state]
        update()
    }

    func pushState(_ state: State) {
        states.append(state)
        update()
    }

    func pop() {
        guard states.count > 0 else {
            return
        }
        states.removeLast()
        update()
    }
}

public final class ArrleQuakeGameViewModel: ObservableObject {
    @Published var image: Image? = nil

    let game: ArrleQuakeGame
    let state: StateViewModel = .init()
    private(set) lazy var joystickController = JoystickController(pool: self)

    public init(game: ArrleQuakeGame) {
        self.game = game
        joystickController.run()
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
}

extension ArrleQuakeGameViewModel: IGamesControlPoll {
    func getGameControlForNewPlayer() -> IGameControl {
        return self
    }

    func removeGameControl(_ game: IGameControl) {
    }
}

extension ArrleQuakeGameViewModel: IGameControl {
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
