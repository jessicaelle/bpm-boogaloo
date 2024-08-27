import SwiftUI

@main
struct BPM_BoogalooApp: App {
    @State private var showSettings = false
    @State private var countdownTime: TimeInterval? = nil

    var body: some Scene {
        WindowGroup {
            NavView(showSettings: $showSettings, countdownTime: $countdownTime)
        }
    }
}
