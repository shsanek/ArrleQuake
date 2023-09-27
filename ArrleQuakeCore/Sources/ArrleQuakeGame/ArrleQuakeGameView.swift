import SwiftUI

public struct ArrleQuakeGameView: View {
    @ObservedObject var viewModel: ArrleQuakeGameViewModel
    @ObservedObject var stateViewModel: StateViewModel

    public init(viewModel: ArrleQuakeGameViewModel) {
        self.viewModel = viewModel
        self.stateViewModel = viewModel.state
    }

    public var size: CGSize {
        #if canImport(UIKit)
        UIScreen.main.bounds.size
        #else
        return CGSize(width: 640, height: 320)
        #endif
    }

    public var body: some View {
        ZStack {
            if let image = viewModel.image {
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .ignoresSafeArea()
                    .frame(
                        width: size.width,
                        height: size.height
                    )
                    .overlay {
                        Group {
                            if stateViewModel.state == .game {
                                KeyboardController(game: viewModel.game)
                            }
                        }
                    }
                    .blur(radius: stateViewModel.state != .game ? 8 : 0)
            } else {
                EmptyView()
            }
            if stateViewModel.state != .game {
                Color.white.opacity(0.2)
                    .transition(.opacity)
            }
            switch stateViewModel.state {
            case .mainMenu:
                MainMenu(game: viewModel.game, stateViewModel: stateViewModel)
                    .transition(.opacity)
            case .game:
                ControlView(gameControll: viewModel)
            case .pause:
                PauseMenu(game: viewModel.game, stateViewModel: stateViewModel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: 10)
    }
}
