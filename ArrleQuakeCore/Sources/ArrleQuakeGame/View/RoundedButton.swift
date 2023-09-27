import SwiftUI

struct RoundedButton<Content: View>: View {
    let label: Content
    let handler: (Bool) -> Void

    @State var down: Bool = false

    init(label: () -> Content, handler: @escaping (Bool) -> Void) {
        self.label = label()
        self.handler = handler
    }

    init(_ image: String, handler: @escaping (Bool) -> Void) where Content == AnyView {
        self.label = AnyView(
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.fontColor)
        )
        self.handler = handler
    }

    init(label: () -> Content, handler: @escaping () -> Void) {
        self.label = label()
        self.handler = { if !$0 { handler() } }
    }

    init(_ image: String, handler: @escaping () -> Void) where Content == AnyView {
        self.label = AnyView(
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.fontColor)
        )
        self.handler = { if !$0 { handler() } }
    }

    var body: some View {
        ZStack {
            label
                .opacity(down ? 0.8 : 1.0)
                .frame(width: 44, height: 44)
                .fixedSize()
        }
        .frame(width: 50, height: 50)
        .fixedSize()
        .contentShape(Rectangle().size(width: 50, height: 50))
        .gesture(DragGesture(minimumDistance: 0).onChanged({ _ in
            if !down {
                down = true
                handler(true)
            }
        }).onEnded({ _ in
            down = false
            handler(false)
        }))
    }
}
