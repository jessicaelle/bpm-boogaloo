import SwiftUI

struct NavView: View {
    @Binding var showSettings: Bool
    @State private var countdownTime: TimeInterval? = nil
    
    var body: some View {
        TabView {
            ContentView(showSettings: $showSettings, countdownTime: $countdownTime)
                .tabItem {
                    Label("BPM", systemImage: "metronome")
                }

            ClockView(countdownTime: $countdownTime)
                .tabItem {
                    Label("Clock", systemImage: "clock")
                }

            SettingsView(showSettings: $showSettings)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct NavView_Previews: PreviewProvider {
    static var previews: some View {
        NavView(showSettings: .constant(false))
    }
}
