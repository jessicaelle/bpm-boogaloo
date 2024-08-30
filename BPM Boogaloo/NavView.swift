import SwiftUI

internal struct NavView: View {
    @Binding internal var showSettings: Bool
    @Binding internal var countdownTime: TimeInterval?

    internal var body: some View {
        TabView {
            ContentView(showSettings: $showSettings, countdownTime: $countdownTime)
                .tabItem {
                    Label("BPM", systemImage: "metronome")
                }
            
            ClockView(countdownTime: $countdownTime)
                .tabItem {
                    Label("Clock", systemImage: "clock")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

internal struct NavView_Previews: PreviewProvider {
    static var previews: some View {
        NavView(showSettings: .constant(false), countdownTime: .constant(nil))
    }
}
