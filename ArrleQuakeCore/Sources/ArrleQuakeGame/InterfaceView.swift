import SwiftUI

struct InterfaceView: View {
    @ObservedObject var stateViewModel: StateViewModel
    let viewModel: ArrleQuakeGameViewModel

    public init(viewModel: ArrleQuakeGameViewModel) {
        self.viewModel = viewModel
        self.stateViewModel = viewModel.state
    }

    var body: some View {
        switch stateViewModel.state {
        case .mainMenu:
            MainMenu(game: viewModel.game, stateViewModel: stateViewModel)
                .transition(.opacity)
        case .game:
            ControlView(gameControll: viewModel, showControl: stateViewModel.showInterface)
                .transition(.opacity)
        case .pause:
            PauseMenu(game: viewModel.game, stateViewModel: stateViewModel)
                .transition(.opacity)
        case .setting:
            SettingMenu(game: viewModel.game, stateViewModel: stateViewModel)
                .transition(.opacity)
        }
    }
}
