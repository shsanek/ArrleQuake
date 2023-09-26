import SwiftUI

public final class ArrleQuakeGameViewModel: ObservableObject {
    let game: ArrleQuakeGame
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

struct ControllerSwiftUI: UIViewControllerRepresentable {
    let game: ArrleQuakeGame

    func makeUIViewController(context: Self.Context) -> Controller {
        .init(game: game)
    }

    func updateUIViewController(_ uiViewController: Controller, context: Self.Context) {
        uiViewController.game = game
    }
}

public struct ArrleQuakeGameView: View {
    @ObservedObject var viewModel: ArrleQuakeGameViewModel

    public init(viewModel: ArrleQuakeGameViewModel) {
        self.viewModel = viewModel
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
            } else {
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: 10)
        .overlay {
            ControllerSwiftUI(game: viewModel.game)
        }
    }
}
