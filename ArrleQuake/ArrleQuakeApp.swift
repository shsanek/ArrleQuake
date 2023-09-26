//
//  ArrleQuakeApp.swift
//  ArrleQuake
//
//  Created by Alex Shipin on 9/26/23.
//

import SwiftUI
import ArrleQuakeGame

@main
struct ArrleQuakeApp: App {
    var body: some Scene {
        WindowGroup {
            ArrleQuakeGameView(viewModel: .init(game: .init())).background(.black)
        }
    }
}
