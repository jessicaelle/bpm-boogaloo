//
//  BPM_BoogalooApp.swift
//  BPM Boogaloo
//
//  Created by Jessica Elle on 8/26/24.
//

import SwiftUI

@main
struct BPM_BoogalooApp: App {
    @State private var showSettings = false

    var body: some Scene {
        WindowGroup {
            NavView(showSettings: $showSettings)
        }
    }
}


