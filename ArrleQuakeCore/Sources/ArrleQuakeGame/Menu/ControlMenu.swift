import SwiftUI

struct ControlMenu: View {
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
        .padding(.init(top: 16, leading: 16, bottom: 16, trailing: 16))
    }
}
