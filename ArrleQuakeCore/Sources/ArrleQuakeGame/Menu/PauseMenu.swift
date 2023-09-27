import SwiftUI

struct PauseMenu: View {
    let game: ArrleQuakeGame
    let stateViewModel: StateViewModel

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    RoundedButton("gear") {
                        stateViewModel.setState(.game)
                    }
                    Spacer()
                }
                Spacer()
            }.safeAreaPadding()
            VStack {
                MenuButton(text: "Save") {
                }
                MenuButton(text: "Load") {
                }
                MenuButton(text: "Main menu") {
                    stateViewModel.setState(.mainMenu)
                }
            }
        }
    }
}
