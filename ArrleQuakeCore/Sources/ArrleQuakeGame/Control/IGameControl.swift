import CoreGraphics

protocol IGameControl: AnyObject {
    func pause()

    func move(_ point: CGPoint)
    func rotate(_ point: CGPoint)

    func gun(_ down: Bool)
}

protocol IGamesControlPoll {
    func getGameControlForNewPlayer() -> IGameControl
    func removeGameControl(_ game: IGameControl)
}
