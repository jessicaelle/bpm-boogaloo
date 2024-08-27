import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    @AppStorage("sliderPosition") var sliderPosition: String = "Right" // New setting for slider position
    @Binding var showSettings: Bool // Binding to control the modal presentation

    let sliderPositions = ["Left", "Right"]

    var body: some View {

            Form {
                // Dark Mode Toggle
                Toggle(isOn: $isDarkMode) {
                    Text("Dark Mode")
                }

                // Slider Position Picker
                Picker("Pitch Slider Position", selection: $sliderPosition) {
                    ForEach(sliderPositions, id: \.self) {
                        Text($0)
                    }
                }

                // Donate Link
                Link("Donate!", destination: URL(string: "https://apple.com")!)
                    .foregroundColor(.blue)
            }
            .navigationTitle("Settings")
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }



struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSettings: .constant(true))
    }
}
