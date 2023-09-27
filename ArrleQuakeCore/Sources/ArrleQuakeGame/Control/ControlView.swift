import SwiftUI

struct ControlView: View {
    let gameControll: IGameControl

    var body: some View {
        VStack {
            HStack {
                RoundedButton("gear") {
                    gameControll.pause()
                }
                Spacer()
            }
            Spacer()
            HStack {
                Spacer()
                RoundedButton("slowmo") {
                    gameControll.gun($0)
                }
            }.offset(y: -10)
            HStack {
                TrigerView { point in
                    gameControll.move(point.normalization(maxValue: 122))
                }.shadow(radius: 5.0)
                Spacer()
                TrigerView { point in
                    gameControll.rotate(point.normalization(maxValue: 122))
                }.shadow(radius: 5.0)
            }
        }.safeAreaPadding()
    }
}


struct TrigerView: View {
    let updateState: (CGPoint?) -> Void
    @State private var offset = CGSize.zero
    @State private var isDragging = false

    var body: some View {
        // a drag gesture that updates offset and isDragging as it moves around
        let dragGesture = DragGesture(minimumDistance: 0.0)
            .onChanged { value in
                isDragging = true
                offset = value.translation
                updateState(.init(x: offset.width, y: -offset.height))
            }
            .onEnded { _ in
                withAnimation {
                    updateState(nil)
                    offset = .zero
                    isDragging = false
                }
            }


        HStack {
            Spacer()
            VStack {
                Spacer()
                Circle()
                    .fill(.red)
                    .frame(width: 40, height: 40)
                    .scaleEffect(isDragging ? 0.8 : 1)
                    .offset(offset)
                Spacer()
            }.frame(height: 120)
            Spacer()
        }
        .frame(width: 120)
        .contentShape(Rectangle())
        .gesture(dragGesture)
    }
}
