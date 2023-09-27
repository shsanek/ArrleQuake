import SwiftUI

struct MenuButton: View {
    let text: String
    let handler: () -> Void

    var body: some View {
        Button(action: {
            handler()
        }, label: {
            ZStack {
                Text(text).font(.myFont).foregroundStyle(Color.fontColor)
            }
            .frame(width: UIScreen.main.bounds.size.width, height: 64)
            .fixedSize()
            .contentShape(Rectangle())
        })
        .frame(width: UIScreen.main.bounds.size.width, height: 64)
        .fixedSize()
        .contentShape(Rectangle())
    }
}

struct ToggleButton: View {
    let text: String
    let handler: (_ isOn: Bool) -> Void

    @State var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn, label: {
            Text(text).font(.myFont).foregroundStyle(Color.fontColor)
        })
        .tint(Color.fontColor)
        .frame(height: 64)
        .fixedSize()
        .contentShape(Rectangle())
        .onDisappear {
            handler(isOn)
        }
    }
}
