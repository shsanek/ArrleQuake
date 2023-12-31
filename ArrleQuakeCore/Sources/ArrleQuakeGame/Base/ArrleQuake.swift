import Foundation
#if canImport(UIKit)
import UIKit
#endif
import ArrleQuakeC
import CoreGraphics
import AVFAudio
import AVFoundation

struct CArgument {
    let arguments: [String]

    init(_ arguments: [String]) {
        self.arguments = arguments
    }

    func run(_ block: (Int32, UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>) -> Void) {
        let args = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: arguments.count)
        for con in arguments.enumerated() {
            let cString = con.element.cString(using: .utf8) ?? []
            args[con.offset] = UnsafeMutablePointer<CChar>.allocate(capacity: cString.count + 1)
            for symbol in cString.enumerated() {
                args[con.offset]?[symbol.offset] = symbol.element
            }
            args[con.offset]?[cString.count] = 0
        }
        block(Int32(arguments.count), args)
        for index in 0..<arguments.count {
            args[index]?.deallocate()
        }
        args.deallocate()
    }
}

public final class ArrleQuakeGame {
    #if canImport(UIKit)
    let path = Bundle.main.resourceURL!
    #else
    let path = Bundle.main.bundlePath + "/Contents/Resources"
    #endif
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

    public init() {
        start()
    }

    private lazy var baseDir = documentsPath + "/game"

    private func copyFromURL(_ url: URL) throws {
        let targetURL = URL(filePath: baseDir)
//        if FileManager.default.fileExists(atPath: baseDir) {
//            return
//        }
        try? FileManager.default.createDirectory(
            at: targetURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
        let files = try JSONDecoder().decode([String].self, from: Data(contentsOf: url.appending(path: "resource.json")))
        for file in files {
            let fileURL = url.appending(path: file)
            let data = try Data(contentsOf: fileURL)
            try data.write(to: targetURL.appending(path: file))
        }
    }

    func start() {
        let gamePath = baseDir + "/tmp"
        try? FileManager.default.createDirectory(
            atPath: gamePath,
            withIntermediateDirectories: true,
            attributes: nil
        )
        try! copyFromURL(path)

        let args = [
            baseDir,
            "-basedir",
            baseDir,
            "-game",
            gamePath

        ]
        print(args)
        CArgument(args).run { count, args in
            qInit(count, args)
        }
        #if canImport(UIKit)
        // let scale: CGFloat = 1.0 / UIScreen.main.scale
        let size = UIScreen.main.bounds.size.applying(.init(scaleX: 1, y: 1))
        VID_SetSize(Int32(size.width), Int32(size.height))
        #else
        VID_SetSize(640, 480)
        #endif
    }

    func loop() -> CGImage? {
        if gunLoop {
            Cbuf_AddText("+attack\n")
        }
        qLoop()
        if gunLoop && !gunDown {
            gunLoop = false
            Cbuf_AddText("-attack\n")
        }
        var image: CGImage?
        autoreleasepool {
            image = renderImage()?.takeRetainedValue()
        }
        if let image {
            let copyImage = image
            return copyImage
        } else {
            return nil
        }
    }

    func pressed(key: Int, down: Bool) {
        Key_Event(Int32(key), down ? 1 : 0)
    }

    func startNewGame() {
        Cbuf_AddText("disconnect\nmaxplayers 1\nmap start\n")
    }

    func move(_ move: CGPoint) -> Void {
        g_control_move_y = Float(move.y)
        g_control_move_x = Float(move.x)
    }

    func rotate(_ angle: CGPoint) -> Void {
        g_control_rotate_x = Float(angle.x)
        g_control_rotate_y = Float(angle.y)
    }


    var gunDown: Bool = true
    var gunLoop: Bool = false

    func gun(down: Bool) {
        gunDown = down
        gunLoop = gunLoop || down
    }


    func multiplayer() {
        let command = "connect \"89.223.68.8:26000\"\n"
        Cbuf_AddText(command)
    }
}
