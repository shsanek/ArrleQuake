import SwiftUI

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
