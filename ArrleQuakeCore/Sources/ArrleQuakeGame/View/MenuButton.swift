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
