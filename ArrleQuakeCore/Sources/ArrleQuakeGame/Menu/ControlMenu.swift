import SwiftUI

struct SettingMenu: View {
    let game: ArrleQuakeGame
    let stateViewModel: StateViewModel

    var body: some View {
        ZStack {
            VStack {
                if StateViewModel.canShowInterface {
                    ToggleButton(text: "Show ui control", handler: { isOn in
                        stateViewModel.showInterface = isOn
                    }, isOn: stateViewModel.showInterface)
                }
                MenuButton(text: "< Back") {
                    stateViewModel.pop()
                }
            }
        }
        .padding(.init(top: 16, leading: 16, bottom: 16, trailing: 16))
    }
}
