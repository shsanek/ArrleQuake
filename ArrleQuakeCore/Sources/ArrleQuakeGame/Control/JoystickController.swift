//
//  File.swift
//  
//
//  Created by Alex Shipin on 9/27/23.
//

import Foundation
import GameController

final class JoystickController {
    final class Control {
        let game: IGameControl
        let controller: GCController

        var rightTrigger: Bool = false

        init(game: IGameControl, controller: GCController, index: GCControllerPlayerIndex) {
            self.game = game
            controller.playerIndex = index
            self.controller = controller
            controller.extendedGamepad?.valueChangedHandler = { [weak self] in
                self?.controllerInputDetected(gamepad: $0, element: $1)
            }
        }
    }

    private let pool: IGamesControlPoll
    private var controls: [Control] = []

    init(pool: IGamesControlPoll) {
        self.pool = pool
    }

    func run() {
        update()
        observeForGameControllers()
    }

    func observeForGameControllers() {
        NotificationCenter.default.addObserver(self, selector: #selector(connectControllers), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectControllers), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }

    private func getIndex() -> GCControllerPlayerIndex {
        for i in 0..<5 {
            guard let index = GCControllerPlayerIndex(rawValue: i) else {
                assertionFailure("Unrange player index")
                return .indexUnset
            }
            if !GCController.controllers().contains(where: { $0.playerIndex == index }) {
                return index
            }
        }
        assertionFailure("Unrange player index")
        return .indexUnset
    }

    private func update() {
        var controls: [Control] = []
        for controller in GCController.controllers() {
            if controller.extendedGamepad != nil {
                controls.append(
                    self.controls.first(where: { $0.controller == controller }) ??
                        .init(game: pool.getGameControlForNewPlayer(), controller: controller, index: getIndex())
                )
            }
        }
        for control in self.controls {
            if !controls.contains(where: { $0.controller == control.controller }) {
                pool.removeGameControl(control.game)
            }
        }
        self.controls = controls
    }

    @objc func connectControllers() {
        update()
    }

    @objc func disconnectControllers() {
        update()
    }

}

extension JoystickController.Control {
    func controllerInputDetected(gamepad: GCExtendedGamepad, element: GCControllerElement) {
        game.move(.init(x: CGFloat(gamepad.leftThumbstick.xAxis.value), y: CGFloat(gamepad.leftThumbstick.yAxis.value)))
        game.rotate(.init(x: CGFloat(gamepad.rightThumbstick.xAxis.value), y: CGFloat(gamepad.rightThumbstick.yAxis.value)))
        if (gamepad.rightTrigger == element) {
            let rightTrigger = gamepad.rightTrigger.value > 0
            if rightTrigger != self.rightTrigger {
                self.rightTrigger = rightTrigger
                game.gun(rightTrigger)
            }
        }
    }
}
