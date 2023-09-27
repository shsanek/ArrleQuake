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
            }.padding(.init(top: 16, leading: 16, bottom: 16, trailing: 16))

            VStack {
                MenuButton(text: "Setting") {
                    stateViewModel.pushState(.setting)
                }
                MenuButton(text: "Main menu") {
                    stateViewModel.setState(.mainMenu)
                }
            }
        }
    }
}
