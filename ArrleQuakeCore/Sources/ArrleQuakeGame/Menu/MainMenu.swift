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
                MenuButton(text: "Load") {

                }
                MenuButton(text: "Multiplayer") {

                }
            }
        }
        .safeAreaPadding()
    }
}
