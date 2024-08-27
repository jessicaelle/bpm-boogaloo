import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    @Binding var showSettings: Bool // Binding to control the modal presentation

    var body: some View {
        VStack {
            HStack {
                // AbstractShape in the top left corner to close the modal
                AbstractShape()
                    .onTapGesture {
                        showSettings = false // Dismiss the modal
                    }
                    .padding()

                Spacer()
            }

            Form {
                // Dark Mode Toggle
                Toggle(isOn: $isDarkMode) {
                    Text("Dark Mode")
                }

                // Donate Link
                Link("Donate!", destination: URL(string: "https://apple.com")!)
                    .foregroundColor(.blue)
            }
            .navigationTitle("Settings")
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSettings: .constant(true))
    }
}
