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
    let path = Bundle.main.bundlePath
    #else
    let path = Bundle.main.bundlePath + "/Contents/Resources"
    #endif
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

    public init() {
        start()
        // try! audioSessionInitialization(rate: 22050)
    }

    func start() {
        let gamePath = documentsPath + "/game"
        try? FileManager.default.createDirectory(
            atPath: gamePath,
            withIntermediateDirectories: true,
            attributes: nil
        )

        CArgument([
            path,
            "-basedir",
            path,
            "-game",
            gamePath

        ]).run { count, args in
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
        qLoop()
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

    func audioSessionInitialization(rate: Double) throws -> Double {
        #if canImport(UIKit)
        let session = AVAudioSession.sharedInstance()
        #else
        let session = AVAudioSession()
        #endif
        try session.setActive(false)
        try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
        try session.setPreferredSampleRate(rate)
        try session.setActive(true)
        loadAudioEngine(with: session)

        try engine.start()

        return session.sampleRate
     }

    private let engine = AVAudioEngine()

    func pressed(key: Int, down: Bool) {
        Key_Event(Int32(key), down ? 1 : 0)
    }

    func loadAudioEngine(with session: AVAudioSession) {
        let inputNode = engine.inputNode
        let outputNode = engine.outputNode

        engine.connect(inputNode, to: outputNode, format: inputNode.inputFormat(forBus: 0))


        var asbd_player = AudioStreamBasicDescription();
        asbd_player.mSampleRate = session.sampleRate;
        asbd_player.mFormatID = kAudioFormatLinearPCM;
        asbd_player.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        asbd_player.mFramesPerPacket = 1;
        asbd_player.mChannelsPerFrame = 2;
        asbd_player.mBitsPerChannel = 16;
        asbd_player.mBytesPerPacket = 4;
        asbd_player.mBytesPerFrame = 4;

        guard let audioUnit = inputNode.audioUnit else {
            return
        }
        var status = AudioUnitSetProperty(
            audioUnit,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Input,
            0,
            &asbd_player,
            UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        );
        print("\(status)")


        // Add the render callback for the ioUnit: for playing
        var callbackStruct = AURenderCallbackStruct(
            inputProc: recordingCallback,
            inputProcRefCon: nil
        )
        status = AudioUnitSetProperty(
            audioUnit,
            kAudioUnitProperty_SetRenderCallback,
            kAudioUnitScope_Input,
            0,
            &callbackStruct,
            UInt32(MemoryLayout<AURenderCallbackStruct>.size)
        );
        print("\(status)")

        engine.prepare()
    }
}

func recordingCallback(
    inRefCon:UnsafeMutableRawPointer,
    ioActionFlags:UnsafeMutablePointer<AudioUnitRenderActionFlags>,
    inTimeStamp:UnsafePointer<AudioTimeStamp>,
    inBusNumber:UInt32,
    inNumberFrames:UInt32,
    ioData:UnsafeMutablePointer<AudioBufferList>?
) -> OSStatus {
    return noErr
}
