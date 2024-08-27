import SwiftUI

struct NavView: View {
    @Binding var showSettings: Bool
    @Binding var countdownTime: TimeInterval?

    var body: some View {
        TabView {
            // ContentView Tab
            ContentView(showSettings: $showSettings, countdownTime: $countdownTime)
                .tabItem {
                    Label("BPM", systemImage: "metronome")
                }
            
            // ClockView Tab
            ClockView(countdownTime: $countdownTime)
                .tabItem {
                    Label("Clock", systemImage: "clock")
                }

            // SettingsView Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

struct NavView_Previews: PreviewProvider {
    static var previews: some View {
        NavView(showSettings: .constant(false), countdownTime: .constant(nil))
    }
}
