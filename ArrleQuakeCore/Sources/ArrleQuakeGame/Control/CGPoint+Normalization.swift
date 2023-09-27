import CoreGraphics

extension CGPoint {
    func normalization(maxValue: CGFloat) -> CGPoint {
        let y = self.y / maxValue
        let x = self.x / maxValue
        var scale: CGFloat = CGFloat(1) / sqrt(x * x + y * y)
        if scale > 1 {
            scale = 1
        }
        return .init(x: max(min(x * scale, 1), -1), y: max(min(y * scale, 1), -1))
    }
}

extension Optional where Wrapped == CGPoint {
    func normalization(maxValue: CGFloat) -> CGPoint {
        self?.normalization(maxValue: maxValue) ?? .zero
    }
}
