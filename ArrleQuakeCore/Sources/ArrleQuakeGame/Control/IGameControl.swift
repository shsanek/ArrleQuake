import CoreGraphics

protocol IGameControl {
    func pause()

    func move(_ point: CGPoint)
    func rotate(_ point: CGPoint)

    func gun(_ down: Bool)
}
