import SwiftUI

public final class ArrleQuakeGameViewModel: ObservableObject {
    let game: ArrleQuakeGame
    let state: StateViewModel = .init()
    @Published var image: Image? = nil

    public init(game: ArrleQuakeGame) {
        self.game = game
        DispatchQueue.main.async {
            self.loop()
        }
    }

    public func loop() {
        if let image = game.loop() {
            #if canImport(UIKit)
            self.image = Image(uiImage: UIImage(cgImage: image))
            #else
            self.image = Image(nsImage: NSImage(cgImage: image, size: .init(width: image.width, height: image.height)))
            #endif
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 / 30.0) {
            self.loop()
        }
    }
}

final class Controller: UIViewController {
    var game: ArrleQuakeGame

    init(game: ArrleQuakeGame) {
        self.game = game
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            game.pressed(key: press.key!.keyCode.rawValue, down: true)
        }
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            game.pressed(key: press.key!.keyCode.rawValue, down: false)
        }
    }
}

final class ButtonController: UIControl {
    var handler: ((Bool) -> Void)?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return self.point(inside: point, with: event) ? self : nil
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        handler?(true)
        return true
    }

    override func cancelTracking(with event: UIEvent?) {
        handler?(false)

    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        handler?(false)
    }
}

struct ButtonControllerSwiftUI: UIViewRepresentable {
    let handler: ((Bool) -> Void)

    func makeUIView(context: Self.Context) -> ButtonController {
        let result = ButtonController(frame: .zero)
        result.handler = handler
        return result
    }

    func updateUIView(_ view: ButtonController, context: Self.Context) {
        view.handler = handler
    }
}

struct ControllerSwiftUI: UIViewControllerRepresentable {
    let game: ArrleQuakeGame

    func makeUIViewController(context: Self.Context) -> Controller {
        .init(game: game)
    }

    func updateUIViewController(_ uiViewController: Controller, context: Self.Context) {
        uiViewController.game = game
    }
}

extension Font {
    private static let fontURL = Bundle.main.url(forResource: "quakecyr", withExtension: "ttf")!
    private static let fd = CTFontManagerCreateFontDescriptorsFromURL(fontURL as CFURL) as! [CTFontDescriptor]

    static let myFont: Font = Font(CTFontCreateWithFontDescriptor(fd[0], 18.0, nil))
    static let bigFont: Font = Font(CTFontCreateWithFontDescriptor(fd[0], 240, nil))
}
extension Color {
    static let fontColor: Color = RGB(207, 86, 53)
}

func componentNormalize(_ value: Int) -> CGFloat {
    CGFloat(value) / CGFloat(255.0)
}

func RGB(_ r: Int, _ g: Int, _ b: Int) -> Color {
    .init(red: componentNormalize(r), green: componentNormalize(g), blue: componentNormalize(b))
}

public struct ArrleQuakeGameView: View {
    @ObservedObject var viewModel: ArrleQuakeGameViewModel
    @ObservedObject var stateViewModel: StateViewModel

    public init(viewModel: ArrleQuakeGameViewModel) {
        self.viewModel = viewModel
        self.stateViewModel = viewModel.state
    }

    public var size: CGSize {
        #if canImport(UIKit)
        UIScreen.main.bounds.size
        #else
        return CGSize(width: 640, height: 320)
        #endif
    }

    public var body: some View {
        ZStack {
            if let image = viewModel.image {
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .ignoresSafeArea()
                    .frame(
                        width: size.width,
                        height: size.height
                    )
                    .overlay {
                        Group {
                            if stateViewModel.state == .game {
                                ControllerSwiftUI(game: viewModel.game)
                            }
                        }
                    }
                    .blur(radius: stateViewModel.state != .game ? 8 : 0)
            } else {
                EmptyView()
            }
            if stateViewModel.state != .game {
                Color.white.opacity(0.2)
                    .transition(.opacity)
            }
            switch stateViewModel.state {
            case .mainMenu:
                MainMenu(game: viewModel.game, stateViewModel: stateViewModel)
                    .transition(.opacity)
            case .game:
                ControlView(game: viewModel.game, stateViewModel: stateViewModel)
            case .pause:
                PauseMenu(game: viewModel.game, stateViewModel: stateViewModel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: 10)
    }
}

final class StateViewModel: ObservableObject {
    enum State {
        case mainMenu
        case game
        case pause
    }

    @Published private(set) var state: State = .mainMenu

    func setState(_ state: State) {
        if state != self.state {
            withAnimation {
                self.state = state
            }
        }
    }
}

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

struct MainMenu: View {
    let game: ArrleQuakeGame
    @ObservedObject var stateViewModel: StateViewModel

    var body: some View {
        ZStack {
//            HStack {
//                Text("Q").font(.bigFont).foregroundStyle(Color.fontColor)
//                    .offset(x: 50, y: -40)
//                Spacer()
//            }
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

struct PauseMenu: View {
    let game: ArrleQuakeGame
    @ObservedObject var stateViewModel: StateViewModel

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

final class GameControl {
    let game: ArrleQuakeGame

    init(game: ArrleQuakeGame) {
        self.game = game
    }
}

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

struct ControlView: View {
    let game: ArrleQuakeGame
    @ObservedObject var stateViewModel: StateViewModel

    var body: some View {
        VStack {
            HStack {
                RoundedButton("gear") {
                    stateViewModel.setState(.pause)
                }
                Spacer()
            }
            Spacer()
            HStack {
                Spacer()
                RoundedButton("slowmo") {
                    game.gun(down: $0)
                }
            }.offset(y: -10)
            HStack {
                TrigerView { point in
                    game.move(point)
                }.shadow(radius: 5.0)
                Spacer()
                TrigerView { point in
                    game.rotate(point)
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
                updateState(.init(x: offset.width, y: offset.height))
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
