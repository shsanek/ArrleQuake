import SwiftUI

struct MainMenu: View {
    let game: ArrleQuakeGame
    let stateViewModel: StateViewModel

    var body: some View {
        ZStack {
            VStack {
                MenuButton(text: "New game") {
                    game.startNewGame()
                    stateViewModel.setState(.game)
                }
                MenuButton(text: "Setting") {
                    stateViewModel.pushState(.setting)
                }
                MenuButton(text: "Multiplayer") {
                    game.multiplayer()
                    stateViewModel.setState(.game)
                }
            }
        }
        .padding(.init(top: 16, leading: 16, bottom: 16, trailing: 16))
    }
}
