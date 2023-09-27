import Foundation
import ArrleQuakeC
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

let path = CommandLine.arguments[1]
let tmp = CommandLine.arguments[2]

//let path = URL(filePath: #file)
//    .deletingLastPathComponent()
//    .deletingLastPathComponent()
//    .deletingLastPathComponent()
//    .deletingLastPathComponent()
//    .appending(path: "ArrleQuake/Resource")
//    .path()
//let tmp = URL(filePath: CommandLine.arguments[0]).deletingLastPathComponent().appending(path: "tmp").path()
//
//try? FileManager.default.createDirectory(
//    atPath: tmp,
//    withIntermediateDirectories: true,
//    attributes: nil
//)

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

let args = [
    path,
    "-basedir",
    path,
    "-game",
    tmp,
    "-dedicated"
]
CArgument(args).run { count, args in
    qInit(count, args)
}

let targetFPS = 60
var avgFrameCount = 10

let rate: Double = 1 / Double(targetFPS)
var oldTime = Sys_FloatTime()
var frameIndex = 0
var scale: Double = 1

Cbuf_AddText ("listen 0\n")
Cbuf_AddText ("maxplayers \(4)\n")
Cbuf_AddText ("map start\n")

while true {
    let startTime = Sys_FloatTime()
    qLoop()
    let endTime = Sys_FloatTime()
    let delta = endTime - startTime
    frameIndex += 1
    if frameIndex == avgFrameCount {
        let bigDelta = (endTime - oldTime) / Double(avgFrameCount)
        let fps = Int(1 / bigDelta)
        frameIndex = 0
        oldTime = endTime
        let delta = Double(fps - targetFPS) / Double(targetFPS)
        let k: Double = delta < 0 ? -1 : 1
        scale += (delta * delta * k)
        scale = min(max(scale, 0.5), 2)
    }
    if rate > delta {
        usleep(UInt32((rate - delta) * 1000000 * scale))
    }

}
